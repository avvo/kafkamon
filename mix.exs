defmodule Kafkamon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kafkamon,
      version: "0.0.1",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      elixir: "~> 1.4",
      deps: deps(),
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Kafkamon, []}]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:avrolixr, ">= 0.1.3"},
      {:cowboy, "~> 1.0"},
      {:erlavro, github: "avvo/erlavro", override: true},
      {:gettext, "~> 0.11"},
      {:junit_formatter, "~> 1.1.0", only: :test},
      {:kafka_ex, "~> 0.6.0"},
      {:kafka_impl, "~> 0.1"},
      {:logger_file_backend, "~> 0.0"},
      {:mix_docker, "~> 0.3"},
      {:phoenix, "~> 1.2.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_slime, "~> 0.7.0"},
      {:poolboy, "~> 1.5"},
      {:progress_bar, "> 0.0.0", only: [:test, :dev]},
    ]
  end
end
