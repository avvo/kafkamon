defmodule Reader.EventQueue.Consumer do
  require Logger
  use GenServer

  def start_link(topic, opts \\ []) do
    GenServer.start_link(__MODULE__, topic, Keyword.take(opts, [:name]))
  end

  def init(topic) do
    :ok = case Kafka.create_worker(worker_name(topic)) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} ->
        Logger.error "Already started kafka_worker for #{topic}"
        :ok
      error ->
        Logger.error "Could not start kafka worker for #{topic}: #{inspect error}"
        :error
    end
    GenServer.cast(self, :begin_streaming)
    {:ok, topic}
  end

  def handle_cast(:begin_streaming, topic) do
    Task.async(fn ->
      Kafka.stream(topic, 0, offset: latest_offset(topic), worker_name: worker_name(topic))
      |> Stream.each(&broadcast_message(topic, &1))
      |> Stream.run
    end)
    {:noreply, topic}
  end

  defp latest_offset(topic) do
    case Kafka.latest_offset(topic, 0) do
      [%{partition_offsets: [%{offset: [offset]}]}] ->
        offset
      error ->
        Logger.warn "Error retrieving offset for '#{topic}': #{inspect error}"
        0
    end
  end

  defp worker_name(topic) do
    :"worker_#{topic}"
  end

  defp broadcast_message(topic, %{value: value, offset: offset}) do
    try do
      value
      |> Avrolixr.Codec.decode!
      |> Reader.EventQueue.Broadcast.notify(topic, offset)
    rescue
      error -> Reader.EventQueue.Broadcast.notify({:error, error}, topic, offset)
    end
  end

end
