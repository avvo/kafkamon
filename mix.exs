defmodule Kafkamon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kafkamon,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Kafkamon.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ~w[lib test/support]
  defp elixirc_paths(_),     do: ~w[lib]

  defp deps do
    [
      {:avrolixr, "~> 0.2"},
      {:cowboy, "~> 1.1"},
      {:erlavro, github: "avvo/erlavro", override: true},
      {:gettext, "~> 0.13"},
      {:kafka_ex, "~> 0.6"},
      {:kafka_impl, "~> 0.4"},
      {:logger_file_backend, "~> 0.0"},
      {:phoenix, "~> 1.3"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_slime, "~> 0.8"},
      {:poolboy, "~> 1.5"},

      # NON-PRODUCTION DEPS
      {:distillery, "~> 1.5"},
      {:junit_formatter, "~> 2.0", only: :test},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:progress_bar, "~> 1.6", only: [:test, :dev]},
      {:mix_test_watch, "~> 0.5", only: :dev},
    ]
  end
end
