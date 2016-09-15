#!/bin/bash

APP_NAME=kafkamon
VERSION=${1:-`git rev-parse --short HEAD`}

docker tag $APP_NAME:$VERSION dplummer1avvo/$APP_NAME:$VERSION
docker push dplummer1avvo/$APP_NAME:$VERSION
