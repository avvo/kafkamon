defmodule Reader.Supervisor do
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    [
      supervisor(Reader.EventQueueSupervisor, []),
      worker(Reader.EventQueueForeman, []),
      worker(Reader.Logger, []),
      worker(Reader.Topics, []),
    ] |> supervise(strategy: :rest_for_one)
  end
end
