FROM elixir:1.3.2-slim

# update and install some software requirements
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
  curl \
  git \
  make \
  mysql-client \
  wget \
  erlang-xmerl

RUN mix do local.hex --force, local.rebar --force, hex.info

EXPOSE 80
ENV PORT=80 \
    MIX_ENV=prod \
    APP_HOME=/srv/kafkamon/current

RUN mkdir -p /var/log/kafkamon
RUN mkdir -p $APP_HOME/lib
WORKDIR $APP_HOME

ADD mix.exs mix.lock deps ./
RUN mix deps.compile

ADD . .

RUN mix do compile, release

RUN mv rel /rel && cd /rel
WORKDIR /rel

ENTRYPOINT ["/rel/kafkamon/bin/kafkamon", "foreground"]
