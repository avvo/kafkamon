defmodule Kafkamon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kafkamon,
      version: "0.0.2",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      elixir: "~> 1.4",
      deps: deps()
    ]
  end

  def application do
    [mod: {Kafkamon, []}]
  end

  defp elixirc_paths(:test), do: ~w[lib web test/support]
  defp elixirc_paths(_), do: ~w[lib web]

  defp deps do
    [
      {:avrolixr, "~> 0.3.0"},
      {:cowboy, "~> 1.1"},
      {:erlavro, github: "avvo/erlavro", override: true},
      {:gettext, "~> 0.13"},
      {:kafka_ex, "~> 0.8.1"},
      {:kafka_impl, "~> 0.5.0"},
      {:logger_file_backend, "~> 0.0"},
      {:mix_docker, "~> 0.4"},
      {:phoenix, "~> 1.2"},
      {:phoenix_html, "~> 2.9"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_slime, "~> 0.8"},
      {:poolboy, "~> 1.5"},
      {:junit_formatter, "~> 1.3", only: :test},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:progress_bar, "~> 1.6", only: [:test, :dev]}
    ]
  end
end
