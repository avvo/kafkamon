defmodule Reader.EventQueue.Broadcast do
  alias Phoenix.PubSub
  alias Kafkamon.Message

  def subscribe(topic), do: PubSub.subscribe KafkamonInternal, pubsub_topic(topic)

  def unsubscribe(topic), do: PubSub.unsubscribe KafkamonInternal, pubsub_topic(topic)

  def notify(message = %Message{}) do
    PubSub.broadcast KafkamonInternal, pubsub_topic(message.topic), {:message, message}
  end

  defp pubsub_topic(topic), do: "messages_#{topic}"
end
