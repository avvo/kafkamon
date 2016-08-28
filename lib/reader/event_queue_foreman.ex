defmodule Reader.EventQueueForeman do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init([] = known_topics) do
    Process.send_after(self(), :topic_subscribe, 10)
    {:ok, known_topics}
  end

  def handle_cast({:topics, old_topics, new_topics}, known_topics) do
    all_topics = ((known_topics |> Enum.reject(&(&1 in old_topics))) ++ new_topics) |> Enum.uniq

    new_topics |> Enum.reject(&(&1 in known_topics)) |> Enum.each(&topic_added/1)

    old_topics |> Enum.filter(&(&1 in known_topics)) |> Enum.each(&topic_removed/1)

    {:noreply, all_topics}
  end

  def handle_info({:topics, _, _} = msg, known_topics) do
    handle_cast(msg, known_topics)
  end

  def handle_info(:topic_subscribe, known_topics) do
    Reader.TopicBroadcast.subscribe()
    {:noreply, known_topics}
  end

  defp topic_added(topic) do
    Reader.EventQueueSupervisor.start_child(topic)
  end

  def topic_removed(topic) do
    Reader.EventQueueSupervisor.terminate_child(topic)
  end
end
