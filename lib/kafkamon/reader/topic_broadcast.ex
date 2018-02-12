defmodule Kafkamon.Reader.TopicBroadcast do
  alias Phoenix.PubSub
  @topic "topics"

  def subscribe() do
    PubSub.subscribe KafkamonInternal, @topic
    Kafkamon.Reader.Topics.new_subscriber()
  end

  def notify(new_topics) do
    PubSub.broadcast KafkamonInternal, @topic, {:topics, new_topics}
  end
  def notify(to, new_topics) do
    send to, {:topics, new_topics}
  end
end
