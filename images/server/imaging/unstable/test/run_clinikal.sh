#!/bin/sh

echo "Configuring Openemr Permissions"
chown -R apache openemr/

# Check if we need to force an openemr upgrade
if ! [ -f "initialized" ] && [ -f "/var/www/localhost/htdocs/openemr/sites/clinikal_installed" ];then
    echo -n 0 > openemr/sites/default/docker-version
fi

# Script from openemr image
cd openemr
echo "Running Openemr Initialization"
. autoconfig.sh
cd ../

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
        echo "Updating Clinikal Modules"
        while read module; do
            echo "Updating $module Module..."
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=upgrade_sql --modname=$module
            php openemr/interface/modules/zend_modules/public/index.php zfc-module --site=default --modaction=upgrade_acl --modname=$module
        done < modules.txt 
    fi

    echo "Adding Translations"
    mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASS} -h${MYSQL_HOST}  ${MYSQL_DATABASE} < translation.sql

    echo "Configuring Client Application Permissions"
    cd clinikal-react
    chown -R apache .
    #set all directories to 500
    find . -type d -print0 | xargs -0 chmod 500
    #set all file access to 400
    find . -type f -print0 | xargs -0 chmod 400
    cd ../

    echo "Configuring Apache"
    sed -i -e "s@<DOMAIN_NAME>@$DOMAIN_NAME@" /etc/apache2/conf.d/clinikal.conf

    # Create file as a flag that container was run for the first time
    touch initialized
else
    echo "Skipping container initialization"
fi

echo "Starting cron daemon"
crond

echo "Starting Apache"
/usr/sbin/httpd -D FOREGROUND
