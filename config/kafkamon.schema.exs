@moduledoc """
A schema is a keyword list which represents how to map, transform, and validate
configuration values parsed from the .conf file. The following is an explanation of
each key in the schema definition in order of appearance, and how to use them.

## Import

A list of application names (as atoms), which represent apps to load modules from
which you can then reference in your schema definition. This is how you import your
own custom Validator/Transform modules, or general utility modules for use in
validator/transform functions in the schema. For example, if you have an application
`:foo` which contains a custom Transform module, you would add it to your schema like so:

`[ import: [:foo], ..., transforms: ["myapp.some.setting": MyApp.SomeTransform]]`

## Extends

A list of application names (as atoms), which contain schemas that you want to extend
with this schema. By extending a schema, you effectively re-use definitions in the
extended schema. You may also override definitions from the extended schema by redefining them
in the extending schema. You use `:extends` like so:

`[ extends: [:foo], ... ]`

## Mappings

Mappings define how to interpret settings in the .conf when they are translated to
runtime configuration. They also define how the .conf will be generated, things like
documention, @see references, example values, etc.

See the moduledoc for `Conform.Schema.Mapping` for more details.

## Transforms

Transforms are custom functions which are executed to build the value which will be
stored at the path defined by the key. Transforms have access to the current config
state via the `Conform.Conf` module, and can use that to build complex configuration
from a combination of other config values.

See the moduledoc for `Conform.Schema.Transform` for more details and examples.

## Validators

Validators are simple functions which take two arguments, the value to be validated,
and arguments provided to the validator (used only by custom validators). A validator
checks the value, and returns `:ok` if it is valid, `{:warn, message}` if it is valid,
but should be brought to the users attention, or `{:error, message}` if it is invalid.

See the moduledoc for `Conform.Schema.Validator` for more details and examples.
"""
[
  extends: [],
  import: [],
  mappings: [
    "kafka_ex.consumer_group": [
      commented: false,
      datatype: :binary,
      default: "kakfamon",
      doc: "Provide documentation for kafka_ex.consumer_group here.",
      hidden: false,
      to: "kafka_ex.consumer_group"
    ],
    "kafka_ex.disable_default_worker": [
      commented: false,
      datatype: :atom,
      default: false,
      doc: "Provide documentation for kafka_ex.disable_default_worker here.",
      hidden: false,
      to: "kafka_ex.disable_default_worker"
    ],
    "kafka_ex.sync_timeout": [
      commented: false,
      datatype: :integer,
      default: 3000,
      doc: "Provide documentation for kafka_ex.sync_timeout here.",
      hidden: false,
      to: "kafka_ex.sync_timeout"
    ],
    "kafka_ex.max_restarts": [
      commented: false,
      datatype: :integer,
      default: 10,
      doc: "Provide documentation for kafka_ex.max_restarts here.",
      hidden: false,
      to: "kafka_ex.max_restarts"
    ],
    "kafka_ex.max_seconds": [
      commented: false,
      datatype: :integer,
      default: 60,
      doc: "Provide documentation for kafka_ex.max_seconds here.",
      hidden: false,
      to: "kafka_ex.max_seconds"
    ],
    "kafka_ex.kafka_version": [
      commented: false,
      datatype: :binary,
      default: "0.8.2",
      doc: "Provide documentation for kafka_ex.kafka_version here.",
      hidden: false,
      to: "kafka_ex.kafka_version"
    ],
    "logger.console.format": [
      commented: false,
      datatype: :binary,
      default: """
      $time $metadata[$level] $message
      """,
      doc: "Provide documentation for logger.console.format here.",
      hidden: false,
      to: "logger.console.format"
    ],
    "logger.console.metadata": [
      commented: false,
      datatype: [
        list: :atom
      ],
      default: [
        :request_id
      ],
      doc: "Provide documentation for logger.console.metadata here.",
      hidden: false,
      to: "logger.console.metadata"
    ],
    "logger.level": [
      commented: false,
      datatype: :atom,
      default: :info,
      doc: "Provide documentation for logger.level here.",
      hidden: false,
      to: "logger.level"
    ],
    "logger.backends": [
      commented: false,
      datatype: [
        list: :atom
      ],
      default: [
        :console,
        :debug_log,
      ],
      doc: "Provide documentation for logger.backends here.",
      hidden: false,
      to: "logger.backends"
    ],
    "logger.debug_log.path": [
      commented: false,
      datatype: :binary,
      default: "/var/log/kafkamon/debug.log",
      doc: "Provide documentation for logger.debug_log.path here.",
      hidden: false,
      to: "logger.debug_log.path"
    ],
    "logger.debug_log.level": [
      commented: false,
      datatype: :atom,
      default: :debug,
      doc: "Provide documentation for logger.debug_log.level here.",
      hidden: false,
      to: "logger.debug_log.level"
    ],
    "kafkamon.Elixir.Kafka.impl": [
      commented: false,
      datatype: :atom,
      default: Kafka.KafkaEx,
      doc: "Provide documentation for kafkamon.Elixir.Kafka.impl here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafka.impl"
    ],
    "kafkamon.Elixir.Kafkamon.Endpoint.render_errors.view": [
      commented: false,
      datatype: :atom,
      default: Kafkamon.ErrorView,
      doc: "Provide documentation for kafkamon.Elixir.Kafkamon.Endpoint.render_errors.view here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafkamon.Endpoint.render_errors.view"
    ],
    "kafkamon.Elixir.Kafkamon.Endpoint.render_errors.accepts": [
      commented: false,
      datatype: [
        list: :binary
      ],
      default: [
        "html",
        "json"
      ],
      doc: "Provide documentation for kafkamon.Elixir.Kafkamon.Endpoint.render_errors.accepts here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafkamon.Endpoint.render_errors.accepts"
    ],
    "kafkamon.Elixir.Kafkamon.Endpoint.pubsub.name": [
      commented: false,
      datatype: :atom,
      default: Kafkamon.PubSub,
      doc: "Provide documentation for kafkamon.Elixir.Kafkamon.Endpoint.pubsub.name here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafkamon.Endpoint.pubsub.name"
    ],
    "kafkamon.Elixir.Kafkamon.Endpoint.pubsub.adapter": [
      commented: false,
      datatype: :atom,
      default: Phoenix.PubSub.PG2,
      doc: "Provide documentation for kafkamon.Elixir.Kafkamon.Endpoint.pubsub.adapter here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafkamon.Endpoint.pubsub.adapter"
    ],
    "kafkamon.Elixir.Kafkamon.Endpoint.http.port": [
      commented: false,
      datatype: {:atom, :binary},
      default: {:system, "PORT"},
      doc: "Provide documentation for kafkamon.Elixir.Kafkamon.Endpoint.http.port here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafkamon.Endpoint.http.port"
    ],
    "kafkamon.Elixir.Kafkamon.Endpoint.url.host": [
      commented: false,
      datatype: :binary,
      default: "example.com",
      doc: "Provide documentation for kafkamon.Elixir.Kafkamon.Endpoint.url.host here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafkamon.Endpoint.url.host"
    ],
    "kafkamon.Elixir.Kafkamon.Endpoint.url.port": [
      commented: false,
      datatype: :integer,
      default: 80,
      doc: "Provide documentation for kafkamon.Elixir.Kafkamon.Endpoint.url.port here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafkamon.Endpoint.url.port"
    ],
    "kafkamon.Elixir.Kafkamon.Endpoint.cache_static_manifest": [
      commented: false,
      datatype: :binary,
      default: "priv/static/manifest.json",
      doc: "Provide documentation for kafkamon.Elixir.Kafkamon.Endpoint.cache_static_manifest here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafkamon.Endpoint.cache_static_manifest"
    ],
    "kafkamon.Elixir.Kafkamon.Endpoint.server": [
      commented: false,
      datatype: :boolean,
      default: true,
      doc: "Provide documentation for kafkamon.Elixir.Kafkamon.Endpoint.server here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafkamon.Endpoint.server"
    ],
    "kafkamon.Elixir.Kafkamon.Endpoint.secret_key_base": [
      commented: false,
      datatype: :binary,
      default: "+rQn6NCWQZ7qwTlF8qjN5Np+i79HKqUzmD35chCfIf9QJ00iQ9xjVWzldJVCZucQ",
      doc: "Provide documentation for kafkamon.Elixir.Kafkamon.Endpoint.secret_key_base here.",
      hidden: false,
      to: "kafkamon.Elixir.Kafkamon.Endpoint.secret_key_base"
    ]
  ],
  transforms: [
    "kafka_ex.brokers": fn _conf ->
      System.get_env("KAFKA_HOSTS")
        |> String.split(",")
        |> Enum.map(fn pair -> String.split(pair, ":") |> List.to_tuple end)
        |> Enum.map(fn {host, port} -> {host, String.to_integer(port)} end)
    end,
    "logger.backends": fn _conf ->
      [:console, {LoggerFileBackend, :debug_log}]
    end,
    "kafkamon.Elixir.Kafkamon.Endpoint.url.host": fn _conf ->
      System.get_env("KAFKAMON_HOST") || "kafkamon.local"
    end
  ],
  validators: []
]
