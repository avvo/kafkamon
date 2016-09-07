defmodule Kafkamon.TopicsSubscriber do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    Reader.TopicBroadcast.subscribe()
    {:ok, []}
  end

  def handle_info({:topics, new_topics}, known_topics) do
    Kafkamon.Endpoint.broadcast("topics", "change", %{
      "previous" => known_topics,
      "now" => new_topics,
    })

    new_topics |> Enum.reject(&(&1 in known_topics)) |> Enum.each(&topic_added/1)

    known_topics |> Enum.reject(&(&1 in new_topics)) |> Enum.each(&topic_removed/1)

    {:noreply, new_topics}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  def handle_cast({:message, topic, message, offset}, state) do
    Kafkamon.Endpoint.broadcast("topic:#{topic}",
      "new:message",
      %{
        "message" => message,
        "key" => "#{topic}:#{offset}",
        "offset" => offset,
      })

    {:noreply, state}
  end

  defp topic_added(topic) do
    Kafkamon.Endpoint.broadcast("topic:#{topic}", "subscribe", %{})
    Reader.EventQueue.Broadcast.subscribe(topic)
  end

  def topic_removed(topic) do
    Reader.EventQueue.Broadcast.unsubscribe(topic)
    Kafkamon.Endpoint.broadcast("topic:#{topic}", "unsubscribe", %{})
  end
end
