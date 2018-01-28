# Kafkamon

[![CircleCI](https://circleci.com/gh/avvo/kafkamon.svg?style=svg)](https://circleci.com/gh/avvo/kafkamon)

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `KAFKA_HOSTS=172.17.0.1:9092 iex -S mix phoenix.server`

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
mix kafkamon.test_producer
```

## Releasing

Using **edib** building a docker image is super great! Just run
`./bin/build.sh` and then `./bin/publish.sh` to publish.

Obviously publishing only works if you have rights ;)

To use, you can run with docker:

```
docker run --rm \
-e "PORT=4000" \
-e "KAFKA_HOSTS=172.17.0.1:9092" \
-e "KAFKAMON_HOST=localhost" \
-e "KAFKAMON_PORT=4000" \
-p 4000:4000 \
avvo/kafkamon:latest
```

* `PORT` is the port phoenix listens to inside the container
* `KAFKA_HOSTS` is a comma-separated list of kafka host:port pairs.
* `KAFKAMON_HOST` is the name you use in the browser to connect to the server.
  This is important for websockets/javascript/CORS security.
* `KAFKAMON_PORT` is the public port you use in your browser to connect to the
  server. Just like `KAFKAMON_HOST` its for security.
* `-p internal:external` is the docker port exposing flag. It exposes the
  internal phoenix port to the external browser world.
