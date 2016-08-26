defmodule Kafkamon.RoomChannel do
  use Phoenix.Channel

  def join("room", _params, socket) do
    {:ok, socket}
  end

  def handle_in("new:msg", %{"body" => body}, socket) do
    broadcast! socket, "new:msg", %{"body" => body}
    {:noreply, socket}
  end

  def handle_out("new:msg", payload, socket) do
    push socket, "new:msg", payload
    {:noreply, socket}
  end
end
