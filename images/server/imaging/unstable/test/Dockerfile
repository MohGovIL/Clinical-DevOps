FROM israelimoh/openemr:5.0.3

COPY 00_clinikal.ini /etc/php7/conf.d/

COPY clinikal.conf /etc/apache2/conf.d/

WORKDIR /var/www/localhost/htdocs/openemr

COPY create-composer-file.php .

COPY composer-clinikal.json .

RUN apk --no-cache upgrade \
    && apk add --no-cache git php7 php7-json php7-phar php7-mbstring php7-openssl curl npm \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && php create-composer-file.php . composer-clinikal.json \
    && rm create-composer-file.php \
    && cp composer.lock composer-clinikal.lock \
    && COMPOSER=composer-clinikal.json composer install --no-progress \
    && COMPOSER=composer-clinikal.json composer update  --no-progress clinikal/* \
    && composer global require phing/phing \
    && /root/.composer/vendor/bin/phing vendor-clean \
    && /root/.composer/vendor/bin/phing assets-clean \
    && composer global remove phing/phing \
    && composer dump-autoload -o \
    && composer clearcache \
    && cd ../ \
    && git clone https://github.com/israeli-moh/clinikal-react.git \
    && cd clinikal-react \
    && git fetch origin develop \
    && git checkout develop \
    && npm install \
    && npm run build \
    && npm cache clear --force \
    && rm -fr node_modules \
    && cd ../ \
    && apk del --no-cache git curl

RUN wget --tries=2 --no-check-certificate -O translation.sql https://40.87.137.89/clinikal-translation/pages/exportlang.php

COPY run_clinikal.sh modules.txt /var/www/localhost/htdocs/

RUN chmod 500 run_clinikal.sh

CMD [ "./run_clinikal.sh" ]
