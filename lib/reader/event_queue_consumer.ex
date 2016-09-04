defmodule Reader.EventQueueConsumer do
  require Logger
  use GenServer

  def start_link(topic) do
    GenServer.start_link(__MODULE__, topic, name: server_name(topic))
  end

  def terminate(parent, topic) do
    Supervisor.terminate_child(parent, server_name(topic))
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
    GenServer.cast(server_name(topic), :begin_streaming)
    {:ok, topic}
  end

  def handle_cast(:begin_streaming, topic) do
    Task.async(fn ->
      for message <- Kafka.stream(topic, 0, offset: latest_offset(topic), worker_name: worker_name(topic)) do
        try do
          message.value
          |> Avrolixr.Codec.decode!
          |> Reader.EventQueueBroadcast.notify(topic, message.offset)
        rescue
          error -> Reader.EventQueueBroadcast.notify({:error, error}, topic, message.offset)
        end
      end
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

  defp worker_name(topic), do: :"worker_#{topic}"
  defp server_name(topic), do: {:via, :gproc, {:n, :l, {:topic_reader, topic}}}

end
