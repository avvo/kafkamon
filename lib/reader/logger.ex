defmodule Reader.Logger do
  require Logger

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def handle_info({:message, topic, {:error, error}}, state) do
    Logger.error "[#{topic}] Error parsing message, got #{inspect error}"
    {:noreply, state}
  end
  def handle_info({:message, topic, message}, state) do
    Logger.info "[#{topic}] #{inspect message}"
    {:noreply, state}
  end
  def handle_info(wat, state) do
    IO.inspect {:wat, wat}
    {:noreply, state}
  end
end
