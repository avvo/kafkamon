defmodule Reader.TopicSubscribers do
  use GenServer

  @name __MODULE__

  def start_link do
    GenServer.start_link(@name, [], name: @name)
  end

  def notify(topics) do
    GenServer.cast(@name, {:notify, topics})
  end

  def handle_cast({:notify, topics}, state) do
    topics |> Enum.each(fn topic ->
      Reader.EventQueueSupervisor.start_consumer(topic)
    end)
    {:noreply, state}
  end
end
