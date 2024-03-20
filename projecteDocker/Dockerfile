FROM composer:2 as COMPOSER

FROM php:8.2-cli-alpine3.18
WORKDIR /app
COPY --from=COMPOSER /usr/bin/composer /usr/bin/composer

RUN apk add \
	--update \
	--no-cache \
	bash \
	git \
	rsync \
	nodejs \
	npm \
 && docker-php-ext-install pdo pdo_mysql	

ENTRYPOINT ["/bin/sh", "-c"]