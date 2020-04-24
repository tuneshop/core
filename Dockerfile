FROM php:7.4-fpm-alpine

COPY --from=composer:1.10 /usr/bin/composer /usr/bin/composer

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/cronjob /var/spool/cron/crontabs/root

ENV MAGICK_HOME=/usr

RUN apk add --no-cache --update nginx supervisor nodejs npm git ffmpeg imagemagick-dev imagemagick \
    && apk add --no-cache --update --virtual .build-deps \
        $PHPIZE_DEPS \
    && apk add --no-cache --update \
        imap-dev \
        openssl-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libraw-dev \
        libzip-dev \
    && pecl install xdebug \
    && pecl install imagick \
    && pecl install redis \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && PHP_OPENSSL=yes docker-php-ext-configure imap --with-imap-ssl \
    && docker-php-ext-configure zip \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable redis \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        bcmath \
        gd \
        zip \
    && apk del .build-deps \
    && mkdir -p /run/nginx

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
