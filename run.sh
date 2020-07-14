#!/bin/bash

CLINIKAL_DEVOPS_PATH=$( cd $( dirname ${BASH_SOURCE[0]} ) && pwd )

. $CLINIKAL_DEVOPS_PATH/container.cfg

. $CLINIKAL_DEVOPS_PATH/configs/${ENVIRONMENT}.cfg

FULL_HOST_CODEBASE_PATH=${HOST_CODEBASE_PATH}/${INSTALLATION_NAME}


# we want to use containerized mariadb
if [ "$CONTAINERIZED_DB" == "true" ];then
    # for use in docker run command
    MYSQL_HOST=$DB_CONTAINER_NAME
    NETWORK="--network=$DOCKER_CUSTOM_NETWORK_NAME"

    # run mariadb container
    . $CLINIKAL_DEVOPS_PATH/mariadb/run.sh

# we want to use host machine mariadb
else
    MYSQL_HOST=$BRIDGE_HOST_IP
fi



case $ENVIRONMENT in
  dev)
    if ! [ "$LOCAL_IMAGE" == "yes" ];then
        docker pull israelimoh/clinikal:$VERTICAL-$VERTICAL_VERSION-dev
    fi

    # this is an installation
    if ! [ -d $FULL_HOST_CODEBASE_PATH/openemr ];then
        . $CLINIKAL_DEVOPS_PATH/dev-environment/scripts/initialize-codebase.sh
    else
        # this is an upgrade
        docker rm -f $INSTALLATION_NAME
    fi

    S3_PATH=$DEVELOPER_NAME/$INSTALLATION_NAME

    docker run \
        --name $INSTALLATION_NAME \
        -p $OPENEMR_PORT:80 \
        --env EASY_DEV_MODE=yes \
        --env EASY_DEV_MODE_NEW=yes \
        --env FORCE_NO_BUILD_MODE=yes \
        --env MYSQL_HOST=$MYSQL_HOST \
        $NETWORK \
        --env MYSQL_DATABASE=$INSTALLATION_NAME \
        --env MYSQL_USER=$INSTALLATION_NAME \
        --env CLINIKAL_SETTING_clinikal_storage_method=$STORAGE_METHOD \
        --env CLINIKAL_SETTING_s3_region=$S3_BUCKET_REGION \
        --env CLINIKAL_SETTING_s3_bucket_name=$BUCKET_NAME \
        --env CLINIKAL_SETTING_s3_path=$S3_PATH \
        --env-file $CLINIKAL_DEVOPS_PATH/creds.cfg \
        -v $FULL_HOST_CODEBASE_PATH/openemr:/openemr:ro \
        -v $FULL_HOST_CODEBASE_PATH/openemr:/var/www/localhost/htdocs/openemr \
        --restart=always \
        israelimoh/clinikal:$VERTICAL-$VERTICAL_VERSION-dev
    ;;

  test)
    if ! [ "$LOCAL_IMAGE" == "yes" ];then
        docker pull israelimoh/clinikal:$VERTICAL-$VERTICAL_VERSION-test
    fi

    # this is an installation
    if ! [ "$(docker ps -aq -f name=$INSTALLATION_NAME)" ]; then
        docker volume create ${INSTALLATION_NAME}_sites
        docker volume create ${INSTALLATION_NAME}_logs

    # if this is an upgrade
    else
        docker rm -f $INSTALLATION_NAME
    fi

    S3_PATH=$INSTALLATION_NAME

    docker run \
        --name $INSTALLATION_NAME \
        --env DOMAIN_NAME=$DOMAIN_NAME \
        --env MYSQL_HOST=$MYSQL_HOST \
        $NETWORK \
        --env MYSQL_DATABASE=$INSTALLATION_NAME \
        --env MYSQL_USER=$INSTALLATION_NAME \
        --env CLINIKAL_SETTING_clinikal_storage_method=$STORAGE_METHOD \
        --env CLINIKAL_SETTING_s3_region=$S3_BUCKET_REGION \
        --env CLINIKAL_SETTING_s3_bucket_name=$BUCKET_NAME \
        --env CLINIKAL_SETTING_s3_path=$S3_PATH \
        --env-file $CLINIKAL_DEVOPS_PATH/creds.cfg \
        --mount source=${INSTALLATION_NAME}_sites,target=/var/www/localhost/htdocs/openemr/sites \
        --mount source=${INSTALLATION_NAME}_logs,target=/var/log \
        --restart=always \
        israelimoh/clinikal:$VERTICAL-$VERTICAL_VERSION-test
    ;;

  prod)
    echo "prod"
    ;;

esac