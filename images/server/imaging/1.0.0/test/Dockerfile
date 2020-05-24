FROM alpine:3.11

RUN apk --no-cache upgrade

RUN apk add --no-cache git php7 php7-json php7-phar php7-mbstring php7-openssl curl npm 

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

WORKDIR /tmp

COPY composer-clinikal.json .

RUN COMPOSER=composer-clinikal.json composer install --no-progress \
    && COMPOSER=composer-clinikal.json composer update  --no-progress



    
FROM openemr/openemr:5.0.3

COPY 00_clinikal.ini /etc/php7/conf.d/

COPY clinikal.conf /etc/apache2/conf.d/

RUN apk add --no-cache git

WORKDIR /var/www/localhost/htdocs/openemr

COPY create-composer-file.php .

COPY composer-clinikal.json .

# clinikal modules
RUN php create-composer-file.php . ./clinikal-composer.json \
    && rm create-composer-file.php \
    && cp composer.lock composer-clinikal.lock \
    && COMPOSER=composer-clinikal.json composer install --no-progress \
    && COMPOSER=composer-clinikal.json composer update  --no-progress clinikal/* \
    && composer global require phing/phing \
    && /root/.composer/vendor/bin/phing vendor-clean \
    && /root/.composer/vendor/bin/phing assets-clean \
    && composer global remove phing/phing \
    && composer dump-autoload -o \
    && composer clearcache

WORKDIR /var/www/localhost/htdocs

# clinikal client-app
RUN git clone https://github.com/israeli-moh/client-app.git \
    && git fetch origin master \
    && git checkout master \
    && npm install \
    && npm run build \
    && printf 'REACT_APP_INSTALL_NAME=.' >> .env.local \
    && printf 'REACT_APP_API_MODE=stateless' >> .env.development.local

RUN chmod 500 run_clinikal.sh

CMD [ "./run_clinikal.sh" ]
