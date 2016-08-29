defmodule Kafkamon.TopicsSubscriber do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init([] = known_topics) do
    Reader.TopicBroadcast.subscribe()
    {:ok, known_topics}
  end

  def handle_cast({:topics, old_topics, new_topics}, known_topics) do
    all_topics = ((known_topics |> Enum.reject(&(&1 in old_topics))) ++ new_topics) |> Enum.uniq

    Kafkamon.Endpoint.broadcast("topics", "change", %{
      "added" => new_topics,
      "removed" => old_topics,
      "all" => all_topics,
    })

    new_topics |> Enum.reject(&(&1 in known_topics)) |> Enum.each(&topic_added/1)

    old_topics |> Enum.filter(&(&1 in known_topics)) |> Enum.each(&topic_removed/1)

    {:noreply, all_topics}
  end

  def handle_cast({:message, topic, message, offset}, state) do
    Kafkamon.Endpoint.broadcast("topic:#{topic}",
      "new:message",
      %{
        "message" => message,
        "key" => "#{topic}:#{offset}"
      })

    {:noreply, state}
  end

  defp topic_added(topic) do
    Kafkamon.Endpoint.broadcast("topic:#{topic}", "subscribe", %{})
    Reader.EventQueueBroadcast.subscribe(topic)
  end

  def topic_removed(topic) do
    Reader.EventQueueBroadcast.unsubscribe(topic)
    Kafkamon.Endpoint.broadcast("topic:#{topic}", "unsubscribe", %{})
  end
end
