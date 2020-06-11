#!/bin/bash

FULL_PATH=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )

. $FULL_PATH/image.cfg

docker build \
    --tag israelimoh/clinikal:$VERTICAL-$VERTICAL_VERSION-$ENVIRONMENT \
    --build-arg CACHEBUST=$(date +%s) \
    --build-arg GITHUB_TOKEN=$GITHUB_TOKEN \
    $FULL_PATH/$VERTICAL/$VERTICAL_VERSION/$ENVIRONMENT/.
