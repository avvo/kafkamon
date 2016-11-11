defmodule Kafkamon.Mixfile do
  use Mix.Project

  def project do
    [app: :kafkamon,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Kafkamon, []},
      applications: applications(Mix.env)
    ]
  end

  def applications(:test) do
    applications(:all) |> Enum.reject(&(&1 == :kafka_ex))
  end

  def applications(_) do
    [
      :phoenix,
      :phoenix_pubsub,
      :phoenix_html,
      :cowboy,
      :logger,
      :gettext,
      :phoenix_slime,

      :logger_file_backend,

      :avrolixr,
      :erlavro,
      :kafka_ex,
      :xmerl,
      :kafka_impl,
      :timex,
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:distillery, "~> 0.10", override: true},

      {:xmerl, github: "otphub/xmerl", manager: :rebar},
      {:avrolixr, ">= 0.1.3"},
      {:erlavro, github: "avvo/erlavro", override: true},
      {:kafka_ex, "~> 0.6.0"},
      {:logger_file_backend, "~> 0.0"},
      {:progress_bar, "> 0.0.0", only: [:test, :dev]},
      {:junit_formatter, "~> 1.1.0", only: :test},
      {:kafka_impl, path: "../kafka_impl"},

      {:phoenix, "~> 1.2.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:phoenix_slime, "~> 0.7.0"},
      {:timex, "~> 3.1"},
    ]
  end
end
