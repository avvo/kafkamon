defmodule Kafkamon.TopicChannel do
  use Phoenix.Channel

  def join("topic:" <> _topic_name, _params, socket) do
    send self, :after_join
    {:ok, socket}
  end

  def handle_in(name, payload, socket) do
    broadcast! socket, name, payload
    {:noreply, socket}
  end

  def handle_out(name, payload, socket) do
    push socket, name, payload
    {:noreply, socket}
  end

  def handle_info(:after_join, %{topic: "topic:" <> topic_name} = socket) do
    Reader.EventQueue.join(topic_name)
    {:noreply, socket}
  end

  def terminate(_reason, %{topic: "topic:" <> topic_name}) do
    Reader.EventQueue.leave(topic_name)
    :ok
  end
end
