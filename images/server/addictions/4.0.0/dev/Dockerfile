FROM openemr/openemr:flex-3.10

RUN apk --no-cache upgrade && apk add --no-cache php7-xdebug

COPY 00_clinikal.ini /etc/php7/conf.d/

COPY clinikal.conf /etc/apache2/conf.d/

WORKDIR /var/www/localhost/htdocs

COPY run_clinikal.sh run_openemr_sql_update.php modules.txt /var/www/localhost/htdocs/

RUN chmod 500 run_clinikal.sh

RUN ln -sf /dev/stderr /var/log/apache2/error.log

CMD [ "./run_clinikal.sh" ]

