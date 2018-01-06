defmodule Kafkamon.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Phoenix.PubSub.PG2, [KafkamonInternal, [name: KafkamonInternal]]),
      supervisor(Reader.Supervisor, []),
      supervisor(KafkamonWeb.Endpoint, []),
      worker(Kafkamon.TopicsSubscriber, []),
    ]

    opts = [strategy: :one_for_one, name: Kafkamon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    KafkamonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
