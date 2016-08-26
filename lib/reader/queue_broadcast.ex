defmodule Reader.QueueBroadcast do
  use GenServer

  def start_link(topic) do
    GenServer.start_link(__MODULE__, {topic, []})
  end

  def init({topic, subscribers}) do
    {:ok, logger_pid} = Reader.Logger.start_link
    {:ok, {topic, [logger_pid | subscribers]}}
  end

  def subscribe(server, pid) do
    GenServer.cast(server, {:subscribe, pid})
  end

  def subscribers(server) do
    GenServer.call(server, :subscribers)
  end

  def publish(server, message) do
    GenServer.cast(server, {:publish, message})
  end

  def handle_call(:subscribers, _from, {_topic, subscribers} = state) do
    {:reply, subscribers, state}
  end

  def handle_cast({:subscribe, pid}, {topic, subscribers}) do
    {:noreply, {topic, [pid | subscribers]}}
  end

  def handle_cast({:publish, message}, {topic, subscribers} = state) do
    subscribers |> Enum.each(fn subscriber ->
      send subscriber, {:message, topic, message}
    end)
    {:noreply, state}
  end
end
