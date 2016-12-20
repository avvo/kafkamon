defmodule Reader.Supervisor do
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    [
      Reader.KafkaPoolWorker.poolboy_worker_spec,
      supervisor(Reader.EventQueue.Supervisor, [[name: Reader.EventQueue.Supervisor]]),
      worker(Reader.EventQueue.Foreman, [[name: Reader.EventQueue.Foreman]]),
      worker(Reader.Logger, [[name: Reader.Logger]]),
      worker(Reader.Topics, [[
        auto_fetch: Application.fetch_env!(:kafkamon, :auto_topic_fetching),
        name: Reader.Topics,
      ]]),
      worker(Reader.EventQueue, [[name: Reader.EventQueue]]),
    ] |> supervise(strategy: :rest_for_one)
  end
end
