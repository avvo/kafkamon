defmodule Reader.EventQueue.Consumer do
  require Logger
  use GenServer

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

  defmodule Message do
    @type t :: %{
      value: map(),
      topic: String.t,
      offset: integer,
      partition: integer,
    }
    defstruct [:value, :topic, :offset, :partition]
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

  def handle_info(:fetch, state) do
    [response] = KafkaImpl.fetch(
      state.topic_name,
      state.partition_number,
      [
        offset: state.offset,
        worker_name: state.worker_pid,
        auto_commit: false,
      ]
    )

    %{partitions: [%{last_offset: last_offset, message_set: messages}]} = response

    first_offset = (last_offset || 0) - length(messages) + 1

    messages
    |> Enum.with_index
    |> Enum.each(fn {msg, index} ->
      broadcast_message(state.topic_name, state.partition_number, first_offset + index, msg)
    end)

    next_offset = case last_offset do
      nil -> state.offset
      last_offset -> last_offset + 1
    end

    Process.send_after self, :fetch, @stream_wait_time_ms

    {:noreply, %{state | offset: next_offset}}
  end

  defp latest_offset(%{offset: offset}) when is_integer(offset), do: offset
  defp latest_offset(%{topic_name: topic, partition_number: partition, worker_pid: pid}) do
    case KafkaImpl.latest_offset(topic, partition, pid) |> KafkaImpl.Util.extract_offset do
      {:ok, offset} -> offset
      {:error, msg} ->
        Logger.error msg
        0
    end
  end

  defp broadcast_message(topic, partition, offset, value) do
    with {:ok, decoded} <- decode(value) do
      %Message{
        value: decoded,
        topic: topic,
        offset: offset,
        partition: partition,
      }
      |> broadcast()
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
    send self, :fetch
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
end
