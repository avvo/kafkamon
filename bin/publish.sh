#!/bin/bash

APP_NAME=kafkamon
VERSION=${1:-latest}
GITSHA=`git rev-parse --short HEAD`

docker push dplummer1avvo/$APP_NAME:$GITSHA
docker push dplummer1avvo/$APP_NAME:$VERSION
