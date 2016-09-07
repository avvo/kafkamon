defmodule Kafkamon do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    [
      #supervisor(Reader.Supervisor, []),
      supervisor(Kafkamon.Endpoint, []),
      worker(Kafkamon.TopicsSubscriber, []),
    ]
    |> Supervisor.start_link(strategy: :one_for_one, name: Kafkamon.Supervisor)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Kafkamon.Endpoint.config_change(changed, removed)
    :ok
  end
end
