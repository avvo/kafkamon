defmodule Kafkamon.TopicsChannel do
  require Logger

  use Phoenix.Channel

  def join("topics", _params, socket) do
    send self(), :after_join
    {:ok, socket}
  end

  def handle_in("change", payload, socket) do
    broadcast! socket, "change", payload
    {:noreply, socket}
  end

  intercept ["change"]

  def handle_out("change", payload, socket) do
    push socket, "change", payload
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    topics = Kafkamon.TopicsSubscriber.current_topics()
    push socket, "change", %{
      "all" => topics,
      "added" => topics,
      "removed" => [],
    }
    {:noreply, socket}
  end
end
