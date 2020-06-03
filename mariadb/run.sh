#!/bin/bash

MARIADB_PATH=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )

# creates network if it does not exist
docker network inspect $DOCKER_CUSTOM_NETWORK_NAME >/dev/null 2>&1 \
&& echo "$DOCKER_CUSTOM_NETWORK_NAME network already exists, continuing..." \
|| \
docker network create --driver bridge $DOCKER_CUSTOM_NETWORK_NAME

if ! [ "$(docker ps -aq -f name=$DB_CONTAINER_NAME)" ]; then
    docker volume create clinikal-mariadb-vol

    docker run \
        --name $DB_CONTAINER_NAME \
        -v $MARIADB_PATH/conf.d:/etc/mysql/conf.d \
        -v clinikal-mariadb-vol:/var/lib/mysql \
        -e MYSQL_ROOT_PASSWORD=pass \
        -d \
        --network=$DOCKER_CUSTOM_NETWORK_NAME \
        --restart=always \
        mariadb:10.4
else
    echo "$DB_CONTAINER_NAME container already exists, continuing..."
fi