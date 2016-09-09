# Kafkamon

[![CircleCI](https://circleci.com/gh/avvo/kafkamon.svg?style=svg)](https://circleci.com/gh/avvo/kafkamon)

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

iex --name console@127.0.0.1 --cookie kafkamon --remsh kafkamon@127.0.0.1

### Test kafka message
```
KafkaEx.produce "users", 0, Avrolixr.Codec.encode!(%{event: %{app_id: "a", name: "n", timestamp: 0}, lawyer_id: 0}, File.read!("test/data/AvvoProAdded.avsc"), 'AvvoEvent.AvvoProAdded')
```
