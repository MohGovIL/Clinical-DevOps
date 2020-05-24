#!/bin/bash

# Check if we need to force an openemr upgrade
if ! [ -f "initialized" ] && [ "$FORCE_OPENEMR_UPGRADE" == "yes" ];then
    echo -n 0 > openemr/sites/default/docker-version
fi

# Script from openemr image
cd openemr
. autoconfig.sh
cd ../

# Only run on initial container start
if ! [ -f "initialized" ];then
    #If we're running an installation
    if [ -z $UPGRADE ]; then
        echo "Installing Clinikal Modules"
        while read module || [ -n "$module" ]; do
            echo "Installing $module Module..."
            php openemr/interface/modules/zend_modules/public/index.php register --mtype=zend --modname=$module
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=install --modname=$module
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=disable --modname=$module
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=install_acl --modname=$module
        done < modules.txt 
    fi

    # If we're running an upgrade
    if [ "$UPGRADE" == "yes" ]; then        
        echo "Updating Clinikal Modules"
        while read module; do
            echo "Updating $module Module..."
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=upgrade_sql --modname=$module
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=upgrade_acl --modname=$module
        done < modules.txt 
    fi

    echo "Adding Translations"
    mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASS} -h${MYSQL_HOST}  ${MYSQL_DATABASE} < translation.sql

    echo "Building Client Application"
    cd clinikal-react
    printf 'REACT_APP_API_BASE_URL='$SERVER_ADDRESS:$OPENEMR_PORT >> .env.local
    npm run build
    npm cache clear --force 
    rm -fr node_modules
    chown -R apache .
    #set all directories to 500
    find . -type d -print0 | xargs -0 chmod 500
    #set all file access to 400
    find . -type f -print0 | xargs -0 chmod 400
    cd ../

    # Create file as a flag that container was run for the first time
    touch initialized
else
    echo "Skipping container initialization"
fi

echo "Starting cron daemon!"
crond

echo "Starting apache!"
/usr/sbin/httpd -D FOREGROUND
