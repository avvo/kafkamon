defmodule Reader.EventQueueConsumer do
  require Logger
  use GenServer

  def start_link(topic) do
    GenServer.start_link(__MODULE__, {topic, nil}, name: server_name(topic))
  end

  def init({topic, nil}) do
    GenServer.cast(server_name(topic), :begin_streaming)
    {:ok, _pid} = kafka().create_worker(worker_name(topic))
    {:ok, broadcaster} = Reader.QueueBroadcast.start_link(topic)
    {:ok, {topic, broadcaster}}
  end

  def subscribe(topic, pid) do
    GenServer.cast(server_name(topic), {:subscribe, pid})
  end

  def subscribers(topic) do
    GenServer.call(server_name(topic), :subscribers)
  end

  def handle_call(:subscribers, _from, {_topic, broadcaster} = state) do
    {:reply, Reader.QueueBroadcast.subscribers(broadcaster), state}
  end

  def handle_cast({:subscribe, pid}, {_topic, broadcaster} = state) do
    Reader.QueueBroadcast.subscribe(broadcaster, pid)
    {:noreply, state}
  end

  def handle_cast(:begin_streaming, {topic, broadcaster} = state) do
    Task.async(fn ->
      for message <- kafka().stream(topic, 0, offset: latest_offset(topic), worker_name: worker_name(topic)) do
        try do
          message.value
          |> Avrolixr.Codec.decode!
          |> (fn data ->
            Reader.QueueBroadcast.publish(broadcaster, data)
          end).()
        rescue
          error -> Reader.QueueBroadcast.publish(broadcaster, {:error, error})
        end
      end
    end)
    {:noreply, state}
  end

  defp latest_offset(topic) do
    case kafka().latest_offset(topic, 0) do
      [%{partition_offsets: [%{offset: [offset]}]}] -> offset
      wat -> IO.inspect(wat); 0
    end
  end

  defp worker_name(topic), do: :"worker_#{topic}"
  defp server_name(topic), do: :"topic_#{topic}"

  defp kafka do
    Application.fetch_env!(:kafkamon, Kafka) |> Keyword.fetch!(:impl)
  end
end
