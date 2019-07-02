FROM php:7.2-alpine

STOPSIGNAL SIGINT

RUN	addgroup -S adminer \
&&	adduser -S -G adminer adminer \
&&	mkdir -p /var/www/html \
&&	mkdir -p /var/www/html/plugins-enabled \
&&	chown -R adminer:adminer /var/www/html

WORKDIR /var/www/html

RUN	apk add --no-cache libpq

RUN	set -x \
&&	apk add --no-cache --virtual .build-deps \
	postgresql-dev \
	sqlite-dev \
&&	docker-php-ext-install pdo_mysql pdo_pgsql pdo_sqlite \
&&	apk del .build-deps

COPY	*.php /var/www/html/

ENV	ADMINER_VERSION 4.6.3.2-yfix
ENV	ADMINER_DOWNLOAD_SHA256 1548e2791dff3aa1eb79ce0f9e6a41b6c0689e6a95e927545e527be4c916b760
ENV	ADMINER_SRC_DOWNLOAD_SHA256 3f5e474f54190df9bfbbae43578c3639eb39253b03ffa4920194a8ce7a4749fb
ENV	ADMINER_REPO yfix/adminer

RUN	set -x \
&&	curl -fsSL https://github.com/$ADMINER_REPO/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION.php -o adminer.php \
&&	echo "$ADMINER_DOWNLOAD_SHA256  adminer.php" |sha256sum -c - \
&&	curl -fsSL https://github.com/$ADMINER_REPO/archive/v$ADMINER_VERSION.tar.gz -o source.tar.gz \
&&	echo "$ADMINER_SRC_DOWNLOAD_SHA256  source.tar.gz" |sha256sum -c - \
&&	tar xzf source.tar.gz --strip-components=1 "adminer-$ADMINER_VERSION/designs/" "adminer-$ADMINER_VERSION/plugins/" \
&&	rm source.tar.gz

COPY	docker/etc/adminer/php.ini /usr/local/etc/php/php.ini

COPY	entrypoint.sh /usr/local/bin/
ENTRYPOINT	[ "entrypoint.sh", "docker-php-entrypoint" ]

USER	adminer
CMD	[ "php", "-S", "[::]:8080", "-t", "/var/www/html" ]

EXPOSE 8080
