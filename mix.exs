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
      applications: [
        :gproc,

        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :cowboy,
        :logger,
        :gettext,

        :conform,
        :conform_exrm,

        :avrolixr,
        :erlavro,
        :kafka_ex,
      ]
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
      {:exrm, "~> 1.0", override: true},
      {:conform, "~> 2.1", override: true},
      {:conform_exrm, "~> 1.0"},

      {:avrolixr, "~> 0.1.0"},
      {:erlavro, github: "avvo/erlavro"},
      {:kafka_ex, "~> 0.5.0"},
      {:gproc, "~> 0.5.0"},

      {:phoenix, "~> 1.2.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
    ]
  end
end
