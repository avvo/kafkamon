#!/bin/bash

APP_NAME=kafkamon
VERSION=${1:-latest}

docker push avvo/$APP_NAME:$VERSION
