#!/bin/bash

set -e

# Fetch and compile dependencies and application code (and include testing tools)
export MIX_ENV="test"
cd $HOME/$CIRCLE_PROJECT_REPONAME
mix do deps.get, deps.compile, compile
