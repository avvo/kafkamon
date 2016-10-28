defmodule Reader.EventQueue.Consumer do
  require Logger
  use GenServer

  alias Kafkamon.Message

  defmodule State do
    @type t :: %{
      topic_name: String.t,
      partition_number: integer,
      brokers: KafkaEx.uri(),
      worker_pid: pid,
      offset: integer,
    }
    defstruct [:topic_name, :partition_number, :brokers, :worker_pid, :offset]
  end

  @stream_wait_time_ms Application.fetch_env!(:kafkamon, :consumer_wait_ms)

  @spec start_link(State.t, [name: String.t]) :: GenServer.on_start
  def start_link(initial_state, opts \\ []) do
    GenServer.start_link(__MODULE__, initial_state, opts)
  end

  def init(state) do
    with {:ok, worker_pid} <- create_worker(state.brokers),
         state             <- state |> Map.put(:worker_pid, worker_pid),
         offset            <- latest_offset(state),
         state             <- state |> Map.put(:offset, offset),
         :ok               <- begin_streaming()
    do
      {:ok, state}
    else
      {:error, error} ->
        Logger.error "Error initializing Consumer #{inspect state}, got error: #{inspect error}"
        {:stop, error}
    end
  end

  @spec fetch_at(pid|atom, DateTime.t) :: {:ok, list} | {:error, any}
  def fetch_at(consumer, datetime = %DateTime{}) do
    GenServer.call(consumer, {:fetch_at, datetime})
  end

  def handle_call({:fetch_at, datetime}, _from, state) do
    with {:ok, offset} <- datetime |> DateTime.to_naive |> NaiveDateTime.to_erl |> offset_at(state),
         {:ok, _last_offset, messages} <- fetch_messages(%{state | offset: offset}),
         wrapped <- messages |> Enum.map(&parse_message(&1, state)) do

      {:reply, {:ok, wrapped}, state}
    else
      :no_offset ->
        Logger.warn "Topic #{state.topic_name}##{state.partition_number} had no offset"
        {:reply, {:ok, []}, state}
      error -> 
      Logger.warn "Error fetching messages at #{inspect datetime} for #{state.topic_name}##{state.partition_number}: #{inspect error}"
      {:reply, {:error, error}, state}
    end
  end

  def handle_info(:stream, state) do
    {:ok, last_offset, messages} = fetch_messages(state)

    messages
    |> Enum.map(&parse_message(&1, state))
    |> Enum.each(&broadcast/1)

    next_offset = case last_offset do
      nil -> state.offset
      last_offset -> last_offset + 1
    end

    Process.send_after self, :stream, @stream_wait_time_ms

    {:noreply, %{state | offset: next_offset}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp latest_offset(%{offset: offset}) when is_integer(offset), do: offset
  defp latest_offset(%{topic_name: topic, partition_number: partition, worker_pid: pid}) do
    case KafkaImpl.latest_offset(topic, partition, pid) |> KafkaImpl.Util.extract_offset do
      {:ok, offset} -> offset
      {:error, msg} ->
        Logger.error msg
        0
    end
  end

  def parse_message(message, state) do
    with {:ok, decoded} <- decode(message.value) do
      Message.new(
        offset: message.offset,
        partition: state.partition_number,
        topic: state.topic_name,
        value: decoded,
      )
    end
  end

  defp decode(value) do
    try do
      value |> Avrolixr.Codec.decode
    rescue
      error ->
        Logger.error "Could not decode message: #{inspect error}. Base64 encoded: #{Base.encode64(value)}"
        :error
    end
  end

  defp broadcast(encoded_message = %Message{}) do
    try do
      encoded_message |> Reader.EventQueue.Broadcast.notify
    rescue
      error -> Logger.error "Could not broadcast message: #{inspect error}"
    end
  end

  defp begin_streaming() do
    send self, :stream
    :ok
  end

  defp create_worker(brokers) do
    with {:ok, pid} <- KafkaImpl.create_no_name_worker(brokers, :no_consumer_group) do
      {:ok, pid}
    else
      error ->
        {:error, "Could not start kafka worker: #{inspect error}"}
    end
  end

  defp fetch_messages(%{topic_name: topic, partition_number: partition, offset: offset, worker_pid: pid}) do
    [response] = KafkaImpl.fetch(
      topic,
      partition,
      [
        offset: offset,
        worker_name: pid,
        auto_commit: false,
      ]
    )

    %{partitions: [%{last_offset: last_offset, message_set: messages}]} = response

    {:ok, last_offset, messages}
  end

  defp offset_at(erltime, state) do
    IO.inspect {erltime, state.topic_name, state.partition_number}
    case KafkaImpl.offset(state.topic_name, state.partition_number, erltime, state.worker_pid) do
      [%KafkaEx.Protocol.Offset.Response{partition_offsets: [%{offset: [offset]}]}] ->
        {:ok, offset}
      [%KafkaEx.Protocol.Offset.Response{partition_offsets: [%{offset: []}]}] ->
        :no_offset
      e -> e
    end
  end
end
