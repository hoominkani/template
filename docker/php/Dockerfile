FROM node:14.4.0-alpine AS node
FROM php:7.4.7-fpm-alpine

WORKDIR /var/www

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /opt /opt
COPY .docker/app/ecs/php.ini /usr/local/etc/php/

ENV EXT_REDIS_VERSION=5.3.0
ENV EXT_IGBINARY_VERSION=3.1.2

ADD src/ /var/www/

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk --update --no-cache add curl g++ python2 python3 make libzip-dev freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && rm -rf /var/cache/apk/* && \
    # php extensions
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install zip && \
    docker-php-ext-configure gd --with-freetype --with-jpeg  && \
    docker-php-ext-install gd && \

    docker-php-source extract && \
    # ext-opcache
    docker-php-ext-enable opcache && \
    # ext-igbinary
    mkdir -p /usr/src/php/ext/igbinary && \
    curl -fsSL https://github.com/igbinary/igbinary/archive/$EXT_IGBINARY_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/igbinary --strip 1 && \
    docker-php-ext-install igbinary && \
    # ext-redis
    mkdir -p /usr/src/php/ext/redis && \
    curl -fsSL https://github.com/phpredis/phpredis/archive/$EXT_REDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 && \
    docker-php-ext-configure redis --enable-redis-igbinary && \
    docker-php-ext-install redis && \
    # ext-sockets
    docker-php-ext-install sockets && \
    ## cleanup
    docker-php-source delete && \
    # composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    #composer global require hirak/prestissimo && \

    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    rm -r /root/.cache && \

    ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    ln -sf /proc/1/fd/1 /var/log/laravel-scheduler.log
