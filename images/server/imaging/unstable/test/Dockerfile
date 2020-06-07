FROM israelimoh/openemr:5.0.3-beta

RUN apk --no-cache upgrade \
    && apk add --no-cache git php7 php7-json php7-phar php7-mbstring php7-openssl curl npm

COPY 00_clinikal.ini /etc/php7/conf.d/

COPY clinikal.conf /etc/apache2/conf.d/

WORKDIR /var/www/localhost/htdocs/openemr

COPY create-composer-file.php .

COPY composer-clinikal.json .

# Disables cache for commands bellow, to ensure we always download the newest code and translations
ARG CACHEBUST=1
RUN echo "CACHEBUST: $CACHEBUST"

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && php create-composer-file.php . composer-clinikal.json \
    && rm create-composer-file.php \
    && cp composer.lock composer-clinikal.lock \
    && COMPOSER=composer-clinikal.json composer update  --no-progress clinikal/* \
    && composer global require phing/phing \
    && /root/.composer/vendor/bin/phing vendor-clean \
    && /root/.composer/vendor/bin/phing assets-clean \
    && composer global remove phing/phing \
    && composer dump-autoload -o \
    && composer clearcache
    
WORKDIR /var/www/localhost/htdocs

RUN git clone https://github.com/israeli-moh/clinikal-react.git --branch develop --depth 1 \
    && rm -rf clinikal-react/.git \
    && cd clinikal-react \
    && npm install \
    && npm run build \
    && npm cache clear --force \
    && rm -fr node_modules

RUN apk del --no-cache git curl

RUN wget --tries=2 --no-check-certificate -O translation.sql https://40.87.137.89/clinikal-translation/pages/exportlang.php

COPY run_clinikal.sh modules.txt ./

RUN chmod 500 run_clinikal.sh

CMD [ "./run_clinikal.sh" ]
