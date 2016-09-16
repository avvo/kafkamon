defmodule Kafkamon.TopicsSubscriber do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    Reader.TopicBroadcast.subscribe()
    {:ok, []}
  end

  def current_topics(name \\ __MODULE__) do
    GenServer.call(name, :current_topics)
  end

  def handle_call(:current_topics, _from, topics) do
    {:reply, topics, topics}
  end

  def handle_info({:topics, new_topic_tuples}, known_topics) do
    new_topics = new_topic_tuples |> just_names

    Kafkamon.Endpoint.broadcast("topics", "change", %{
      "previous" => known_topics,
      "now" => new_topics,
    })

    new_topics |> Enum.reject(&(&1 in known_topics)) |> Enum.each(&topic_added/1)

    known_topics |> Enum.reject(&(&1 in new_topics)) |> Enum.each(&topic_removed/1)

    {:noreply, new_topics}
  end

  def handle_info({:message, topic, message, offset}, state) do
    Kafkamon.Endpoint.broadcast("topic:#{topic}",
      "new:message",
      %{
        "message" => message,
        "key" => "#{topic}:#{offset}",
        "offset" => offset,
      })

    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp topic_added(topic) do
    Kafkamon.Endpoint.broadcast("topic:#{topic}", "subscribe", %{})
    Reader.EventQueue.Broadcast.subscribe(topic)
  end

  def topic_removed(topic) do
    Reader.EventQueue.Broadcast.unsubscribe(topic)
    Kafkamon.Endpoint.broadcast("topic:#{topic}", "unsubscribe", %{})
  end

  defp just_names(topic_tuples) do
    topic_tuples |> Enum.map(& elem(&1, 0))
  end
end
