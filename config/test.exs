use Mix.Config

config :kafkamon, auto_topic_fetching: false

config :kafkamon, consumer_wait_ms: 1

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kafkamon, Kafkamon.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, :console, level: :error

config :kafka_impl, :impl, KafkaImpl.KafkaMock
