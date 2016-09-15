#!/bin/bash

APP_NAME=kafkamon
VERSION=${1:-`git rev-parse --short HEAD`}

docker build --rm -t $APP_NAME:$VERSION .
