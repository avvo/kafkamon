defmodule Kafkamon.TopicsSubscriber do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, nil)

  def init(state) do
    :timer.sleep 1000
    Reader.Topics.topics
    |> Enum.each(fn topic ->
      Reader.EventQueueConsumer.subscribe(topic, self())
    end)
    {:ok, state}
  end

  def handle_info({:message, _topic, message}, state) do
    Kafkamon.Endpoint.broadcast("room", "new:msg", %{"body" => inspect(message)})
    {:noreply, state}
  end
end
