FROM avvo/elixir-circleci:1.5.1-1

ENV MIX_ENV=prod

COPY . .

RUN \
  curl -sL https://deb.nodesource.com/setup_6.x | bash - \
  && apt-get update -qq \
  && apt-get install -y nodejs \
  && npm install

RUN ./node_modules/brunch/bin/brunch b -p

WORKDIR /opt/app
RUN mix phx.digest

RUN mix release --env=prod --verbose

FROM avvo/elixir-release-ubuntu:xenial-4

EXPOSE 4000
ENV PORT=4000 \
  MIX_ENV=prod \
  REPLACE_OS_VARS=true \
  SHELL=/bin/sh

ARG SOURCE_COMMIT=0
RUN echo $SOURCE_COMMIT
ENV COMMIT_HASH $SOURCE_COMMIT

WORKDIR /opt/app

COPY --from=0 /opt/app/_build/prod/rel/kafkamon/releases/0.0.2/kafkamon.tar.gz .
RUN tar zxf kafkamon.tar.gz

ENTRYPOINT ["/opt/app/bin/kafkamon"]
CMD ["foreground"]
