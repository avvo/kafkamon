use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
config :kafkamon, KafkamonWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [yarn: ["run", "watch-phx",
    cd: Path.expand("../assets", __DIR__)]]


# Watch static and templates for browser reloading.
config :kafkamon, KafkamonWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|jsx|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/kafkamon_web/views/.*(ex)$},
      ~r{lib/kafkamon_web/templates/.*(eex|slim|slime)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

config :logger, level: :debug

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
