#!/bin/bash
APP_NAME=kafkamon
VERSION=${1:-latest}

docker tag $APP_NAME:$VERSION avvo/$APP_NAME:$VERSION
docker push avvo/$APP_NAME:$VERSION
