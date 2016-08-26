#!/bin/bash

APP_NAME=kafkamon
VERSION=${1:-latest}

docker build --rm -t $APP_NAME:$VERSION .
