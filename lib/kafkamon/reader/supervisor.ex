defmodule Kafkamon.Reader.Supervisor do
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    [
      Kafkamon.Reader.KafkaPoolWorker.poolboy_worker_spec,
      supervisor(Kafkamon.Reader.EventQueue.Supervisor, [[name: Kafkamon.Reader.EventQueue.Supervisor]]),
      worker(Kafkamon.Reader.EventQueue.Foreman, [[name: Kafkamon.Reader.EventQueue.Foreman]]),
      worker(Kafkamon.Reader.Logger, [[name: Kafkamon.Reader.Logger]]),
      worker(Kafkamon.Reader.Topics, [[
        auto_fetch: Application.fetch_env!(:kafkamon, :auto_topic_fetching),
        name: Kafkamon.Reader.Topics,
      ]]),
      worker(Kafkamon.Reader.EventQueue, [[name: Kafkamon.Reader.EventQueue]]),
    ] |> supervise(strategy: :rest_for_one)
  end
end
