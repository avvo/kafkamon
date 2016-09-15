defmodule Reader.EventQueue.Consumer do
  require Logger
  use GenServer

  def start_link(topic, partition, opts \\ []) do
    GenServer.start_link(__MODULE__, {topic, partition}, Keyword.take(opts, [:name]))
  end

  def init({topic, partition}) do
    :ok = case Kafka.create_worker(worker_name(topic, partition)) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} ->
        Logger.error "Already started kafka_worker for #{topic}##{partition}"
        :ok
      error ->
        Logger.error "Could not start kafka worker for #{topic}#{partition}: #{inspect error}"
        :error
    end
    GenServer.cast(self, :begin_streaming)
    {:ok, {topic, partition}}
  end

  def handle_cast(:begin_streaming, {topic, partition}) do
    Task.async(fn ->
      Kafka.stream(topic, partition - 1,
        offset: latest_offset(topic, partition),
        worker_name: worker_name(topic, partition),
        handler: Kafka.NullHandler)
      |> Stream.each(&broadcast_message(topic, &1))
      |> Stream.run
    end)
    {:noreply, {topic, partition}}
  end

  defp latest_offset(topic, partition) do
    case Kafka.latest_offset(topic, partition - 1) do
      [%{partition_offsets: [%{offset: [offset]}]}] ->
        offset
      error ->
        Logger.warn "Error retrieving offset for '#{topic}': #{inspect error}"
        0
    end
  end

  defp worker_name(topic, partition) do
    :"worker_#{topic}_#{partition}"
  end

  defp broadcast_message(topic, %{value: value, offset: offset}) do
    value
    |> Avrolixr.Codec.decode!
    |> Reader.EventQueue.Broadcast.notify(topic, offset)
  end

end
