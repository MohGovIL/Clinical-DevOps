#!/bin/sh

# Script from openemr image
. autoconfig.sh

# Only run on initial container start
if ! [ -f "initialized" ];then
    #If we're running an installation
    if ! [ -f "/var/www/localhost/htdocs/openemr/sites/clinikal_installed" ]; then
        echo "Installing Clinikal Modules"
        while read module || [ -n "$module" ]; do
            echo "Installing $module Module..."
            php openemr/interface/modules/zend_modules/public/index.php register --mtype=zend --modname=$module
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=install --modname=$module
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=disable --modname=$module
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=install_acl --modname=$module
        done < modules.txt 

        # Create file as a flag that application installation process was run
        touch /var/www/localhost/htdocs/openemr/sites/clinikal_installed
        
    # If we're running an upgrade
    else
        echo "Running Openemr SQL Update"
        php run_openemr_sql_update.php
        
        echo "Updating Clinikal Modules"
        while read module || [ -n "$module" ]; do
            echo "Updating $module Module..."
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=upgrade_sql --modname=$module
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=upgrade_acl --modname=$module
        done < modules.txt 
    fi

    echo "Adding Translations"
    wget --tries=2 --no-check-certificate -O translation.sql https://40.87.137.89/clinikal-translation/pages/exportlang.php
    mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASS} -h${MYSQL_HOST}  ${MYSQL_DATABASE} < translation.sql

    # Create file as a flag that container was run for the first time
    touch initialized
else
    echo "Skipping container initialization"
fi

echo "Starting cron daemon!"
crond

echo "Starting apache!"
/usr/sbin/httpd -D FOREGROUND