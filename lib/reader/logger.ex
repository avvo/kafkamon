defmodule Reader.Logger do
  require Logger

  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(state) do
    Reader.TopicBroadcast.subscribe()
    {:ok, state}
  end

  def handle_cast({:topics, old, new}, state) do
    new |> Enum.each(fn topic -> Reader.EventQueueBroadcast.subscribe(topic) end)
    old |> Enum.each(fn topic -> Reader.EventQueueBroadcast.unsubscribe(topic) end)

    Logger.info "Topics changed. Removed: #{inspect old}, Added: #{inspect new}"
    {:noreply, state}
  end

  def handle_cast({:message, topic, {:error, error}, offset}, state) do
    Logger.error "[#{topic}##{offset}] Error parsing message, got #{inspect error}"
    {:noreply, state}
  end

  def handle_cast({:message, topic, message, offset}, state) do
    Logger.info "[#{topic}##{offset}] #{inspect message}"
    {:noreply, state}
  end

  def handle_cast(wat, state) do
    IO.inspect {:wat, wat}
    {:noreply, state}
  end
end
