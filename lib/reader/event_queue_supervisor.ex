defmodule Reader.EventQueueSupervisor do
  require Logger
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    [
      worker(Reader.EventQueueConsumer, [], restart: :transient)
    ] |> supervise(strategy: :simple_one_for_one)
  end

  def start_child(topic) do
    :ok = case Supervisor.start_child(__MODULE__, [topic]) do
      {:ok, _pid} ->
        :ok
      {:error, {:already_started, _pid}} ->
        Logger.info("Reader.EventQueueSupervisor already started child for #{topic}")
        :ok
      error ->
        Logger.error("Reader.EventQueueSupervisor error #{topic}: #{inspect error}")
        :error
    end
  end

  def terminate_child(topic) do
    Reader.EventQueueConsumer.terminate(__MODULE__, topic)
  end
end
