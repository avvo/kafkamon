defmodule Reader.EventQueueSupervisor do
  require Logger
  use Supervisor

  def init([]) do
    children = [
      worker(Reader.EventQueueConsumer, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_consumer(topic) do
    case Supervisor.start_child(__MODULE__, [topic]) do
      {:ok, _pid} ->
        :ok
      error ->
        Logger.error("Got error trying to start consumer for #{topic}: #{inspect error}")
        :error
    end
  end
end
