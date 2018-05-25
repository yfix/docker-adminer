FROM yfix/php:7.2

RUN	mkdir -p /var/www/html \
  && mkdir -p /var/www/html/plugins-enabled \
  && chown -R www-data:www-data /var/www/html

USER www-data

WORKDIR /var/www/html

COPY *.php /var/www/html/

ENV	ADMINER_VERSION 4.3.2-yfix
ENV	ADMINER_DOWNLOAD_SHA256 0acba5c7034b2ca3c00a13ba1a1300b084781f28ce9bc2e063549dec9c905025
ENV	ADMINER_SRC_DOWNLOAD_SHA256 d30ea917f8830110dec4035c408f626e67ee868e21361c4ce86de27a51565613
ENV	ADMINER_REPO yfix/adminer

RUN	set -x \
  && curl -fsSL https://github.com/$ADMINER_REPO/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION.php -o adminer.php \
  && echo "$ADMINER_DOWNLOAD_SHA256  adminer.php" |sha256sum -c - \
  && curl -fsSL https://github.com/$ADMINER_REPO/archive/v$ADMINER_VERSION.tar.gz -o source.tar.gz \
  && echo "$ADMINER_SRC_DOWNLOAD_SHA256  source.tar.gz" |sha256sum -c - \
  && tar xzf source.tar.gz --strip-components=1 "adminer-$ADMINER_VERSION/designs/" "adminer-$ADMINER_VERSION/plugins/" \
  && rm source.tar.gz

# COPY entrypoint.sh /usr/local/bin/
# ENTRYPOINT [ "entrypoint.sh", "docker-php-entrypoint" ]

CMD	[ "php", "-S", "[::]:8080", "-t", "/var/www/html" ]

EXPOSE 8080
