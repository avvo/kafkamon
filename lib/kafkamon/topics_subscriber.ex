defmodule Kafkamon.TopicsSubscriber do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(known_topics) do
    Reader.TopicBroadcast.subscribe()
    {:ok, known_topics}
  end

  def handle_cast({:topics, old_topics, new_topics}, known_topics) do
    all_topics = (known_topics |> Enum.reject(&(&1 in old_topics))) ++ new_topics

    Kafkamon.Endpoint.broadcast("topics", "change", %{
      "added" => new_topics,
      "removed" => old_topics,
      "all" => all_topics,
    })

    new_topics
    |> Enum.each(fn topic ->
      Kafkamon.Endpoint.broadcast("topic:#{topic}", "subscribe", %{})
      Reader.EventQueueBroadcast.subscribe(topic)
    end)

    old_topics
    |> Enum.each(fn topic ->
      Reader.EventQueueBroadcast.unsubscribe(topic)
      Kafkamon.Endpoint.broadcast("topic:#{topic}", "unsubscribe", %{})
    end)

    {:noreply, all_topics}
  end

  def handle_cast({:message, topic, message}, state) do
    Kafkamon.Endpoint.broadcast("topic:#{topic}",
      "new:message",
      %{"message" => message})

    {:noreply, state}
  end
end
