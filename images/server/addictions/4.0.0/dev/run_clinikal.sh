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

        echo "Initializing Clinikal Globals"
        # copied logic from autoconfig.sh for OPENEMR_SETTING and applied to CLINIKAL_SETTING (but with REPLACE instead of UPDATE)
        CLINIKAL_SETTINGS=`printenv | grep '^CLINIKAL_SETTING_'`
        if [ -n "$CLINIKAL_SETTINGS" ]; then
            echo "$CLINIKAL_SETTINGS" |
            while IFS= read -r line; do
                SETTING_TEMP=`echo "$line" | cut -d "=" -f 1`
                # note am omitting the letter C on purpose
                CORRECT_SETTING_TEMP=`echo "$SETTING_TEMP" | awk -F 'LINIKAL_SETTING_' '{print $2}'`
                VALUE_TEMP=`echo "$line" | cut -d "=" -f 2`
                echo "Set ${CORRECT_SETTING_TEMP} to ${VALUE_TEMP}"
                mysql -u "$MYSQL_USER"  --password="$MYSQL_PASS" -h "$MYSQL_HOST" -e "REPLACE INTO globals (gl_name, gl_value) VALUES ('${CORRECT_SETTING_TEMP}', '${VALUE_TEMP}')" "$MYSQL_DATABASE"
            done
        fi

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

   # if ! [ -f "openemr/interface/modules/zend_modules/module/ClinikalMohIl/sql/special_queries.sql" ]; then
   #     echo "Install/update special sql queries"
   #     mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASS} -h${MYSQL_HOST}  ${MYSQL_DATABASE} < openemr/interface/modules/zend_modules/module/ClinikalMohIl/sql/special_queries.sql
   # fi
    echo "Connect to patients record DB"
    php openemr/interface/modules/zend_modules/public/index.php connect-patients-record --user=${MYSQL_ROOT_USER} --pass=${MYSQL_ROOT_PASS}

    echo "Create base_path.js file"
    echo "var BASE_PUBLIC_CLINIKAL_PATH = '';" > openemr/interface/modules/zend_modules/public/js/clinikalmohil/base_path.js

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