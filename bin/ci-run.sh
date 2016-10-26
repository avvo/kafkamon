#!/bin/bash

export MIX_ENV="test"
export PATH="$HOME/dependencies/erlang/bin:$HOME/dependencies/elixir/bin:$PATH"
export KAFKA_HOSTS=127.0.0.1:9092

mix test
