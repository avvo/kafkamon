defmodule Reader.EventQueueForeman do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(state) do
    Process.send_after(self(), :topic_subscribe, 10)
    {:ok, state}
  end

  def handle_cast({:topics, old_topics, new_topics}, state) do
    new_topics
    |> Enum.each(fn topic ->
      Reader.EventQueueSupervisor.start_child(topic)
    end)

    old_topics
    |> Enum.each(fn topic ->
      Reader.EventQueueSupervisor.terminate_child(topic)
    end)

    {:noreply, state}
  end

  def handle_info({:topics, _, _} = msg, state) do
    handle_cast(msg, state)
  end

  def handle_info(:topic_subscribe, state) do
    Reader.TopicBroadcast.subscribe()
    {:noreply, state}
  end
end
