defmodule Kafkamon.TopicChannel do
  use Phoenix.Channel

  def join("topic:" <> _topic_name, _params, socket) do
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
end
