defmodule Kafkamon.TopicsSubscriber do
  use GenServer

  alias Reader.EventQueue.Consumer.Message

  @stream_wait_time_ms Application.fetch_env!(:kafkamon, :consumer_wait_ms)

  defmodule State do
    @type t :: %{
      topics: [],
      messages: [],
    }
    defstruct topics: [], messages: []
  end

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    Reader.TopicBroadcast.subscribe()
    flush_later(10)
    {:ok, %State{}}
  end

  def current_topics(name \\ __MODULE__) do
    GenServer.call(name, :current_topics)
  end

  def handle_call(:current_topics, _from, %{topics: topics} = state) do
    {:reply, topics, state}
  end

  def handle_info({:topics, new_topic_tuples}, %{topics: known_topics} = state) do
    new_topics = new_topic_tuples |> just_names

    KafkamonWeb.Endpoint.broadcast("topics", "change", %{
      "previous" => known_topics,
      "now" => new_topics,
    })

    new_topics |> Enum.reject(&(&1 in known_topics)) |> Enum.each(&topic_added/1)

    known_topics |> Enum.reject(&(&1 in new_topics)) |> Enum.each(&topic_removed/1)

    {:noreply, %{state | topics: new_topics}}
  end
  def handle_info({:message, message = %Message{}}, %{messages: messages} = state) do
    {:noreply, %{state | messages: [message | messages]}}
  end
  def handle_info(:flush, %{messages: messages} = state) do
    broadcast(messages)
    flush_later()
    {:noreply, %{state | messages: []}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp broadcast(messages) do
    messages
    |> Enum.reverse
    |> Enum.map(fn message ->
      %{
        "value" => message.value,
        "key" => "#{message.topic}/#{message.partition}##{message.offset}",
        "partition" => message.partition,
        "offset" => message.offset,
        "topic" => message.topic,
      }
    end)
    |> Enum.group_by(& Map.get(&1, "topic"))
    |> Enum.each(fn {topic, channel_messages} ->
      KafkamonWeb.Endpoint.broadcast("topic:#{topic}",
        "new:messages",
        %{"messages" => channel_messages}
      )
    end)
  end

  defp topic_added(topic) do
    KafkamonWeb.Endpoint.broadcast("topic:#{topic}", "subscribe", %{})
    Reader.EventQueue.Broadcast.subscribe(topic)
  end

  def topic_removed(topic) do
    Reader.EventQueue.Broadcast.unsubscribe(topic)
    KafkamonWeb.Endpoint.broadcast("topic:#{topic}", "unsubscribe", %{})
  end

  defp just_names(topic_tuples) do
    topic_tuples |> Enum.map(& elem(&1, 0))
  end

  defp flush_later(delay \\ 0) do
    Process.send_after self(), :flush, @stream_wait_time_ms + delay
  end
end
