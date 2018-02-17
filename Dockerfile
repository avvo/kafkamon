FROM avvo/elixir-circleci:1.5.2-1c

ENV MIX_ENV=prod

COPY . .

WORKDIR assets

RUN npm install

RUN npm run deploy

WORKDIR /opt/app
RUN mix phx.digest

RUN mix release --env=prod --verbose

FROM avvo/elixir-release-ubuntu:xenial-4

EXPOSE 4000
ENV PORT=4000 \
  MIX_ENV=prod \
  REPLACE_OS_VARS=true \
  SHELL=/bin/sh

WORKDIR /opt/app

COPY --from=0 /opt/app/_build/prod/rel/kafkamon/releases/0.1.0/kafkamon.tar.gz .
RUN tar zxf kafkamon.tar.gz

ENTRYPOINT ["/opt/app/bin/kafkamon"]
CMD ["foreground"]
