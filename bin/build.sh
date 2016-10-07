#!/bin/bash

GITSHA=`git rev-parse --short HEAD`

mix edib --prefix dplummer1avvo --tag $GITSHA --hex --npm
