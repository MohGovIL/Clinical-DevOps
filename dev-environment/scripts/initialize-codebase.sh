#!/bin/bash

# create codebase path on host machine if does not yet exist
mkdir -p $FULL_HOST_CODEBASE_PATH

# download openemr
git -C  $FULL_HOST_CODEBASE_PATH clone https://github.com/matrix-israel/openemr.git openemr
git -C  $FULL_HOST_CODEBASE_PATH/openemr fetch origin $OPENEMR_BRANCH
git -C  $FULL_HOST_CODEBASE_PATH/openemr checkout $OPENEMR_BRANCH

# configure openemr git
git -C $FULL_HOST_CODEBASE_PATH/openemr update-index --assume-unchanged  sites/default/images/logo_1.png sites/default/images/logo_2.png
git -C $FULL_HOST_CODEBASE_PATH/openemr update-index --assume-unchanged  sites/default/sqlconf.php
if [ -a $FULL_HOST_CODEBASE_PATH/openemr/interface/modules/zend_modules/config/application.config.php  ]
    then
    git -C $FULL_HOST_CODEBASE_PATH/openemr update-index --assume-unchanged  interface/modules/zend_modules/config/application.config.php
fi

# install openemr node modules
npm install --prefix $FULL_HOST_CODEBASE_PATH/openemr
npm run --prefix $FULL_HOST_CODEBASE_PATH/openemr build

# download clinikal modules using composer
php $CLINIKAL_DEVOPS_PATH/dev-environment/scripts/create-composer-file.php $FULL_HOST_CODEBASE_PATH/openemr $CLINIKAL_DEVOPS_PATH/dev-environment/verticals_configurations/$VERTICAL/composer.json
cp $FULL_HOST_CODEBASE_PATH/openemr/composer.lock $FULL_HOST_CODEBASE_PATH/openemr/composer-clinikal.lock
sed -i -e "s@<GENERIC_BRANCH>@dev-$GENERIC_BRANCH@" $FULL_HOST_CODEBASE_PATH/openemr/composer-clinikal.json
sed -i -e "s@<VERTICAL_BRANCH>@dev-$VERTICAL_BRANCH@" $FULL_HOST_CODEBASE_PATH/openemr/composer-clinikal.json
sed -i -e "s@<INSTALL_NAME>@$INSTALLATION_NAME@" $FULL_HOST_CODEBASE_PATH/openemr/composer-clinikal.json
COMPOSER=composer-clinikal.json composer install -d $FULL_HOST_CODEBASE_PATH/openemr --no-progress
COMPOSER=composer-clinikal.json composer update -d $FULL_HOST_CODEBASE_PATH/openemr --no-progress clinikal/*
composer dump-autoload -o -d $FULL_HOST_CODEBASE_PATH/openemr

# download client application
git -C  $FULL_HOST_CODEBASE_PATH clone git@github.com:israeli-moh/clinikal-react.git
git -C  $FULL_HOST_CODEBASE_PATH/clinikal-react fetch origin $CLIENT_APP_BRANCH
git -C  $FULL_HOST_CODEBASE_PATH/clinikal-react checkout $CLIENT_APP_BRANCH

# install client application node modules
npm install --prefix $FULL_HOST_CODEBASE_PATH/clinikal-react

# add client application environment variables
printf 'REACT_APP_API_BASE_URL='localhost:$OPENEMR_PORT >> $FULL_HOST_CODEBASE_PATH/clinikal-react/.env.local
