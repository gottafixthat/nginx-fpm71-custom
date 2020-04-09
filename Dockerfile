FROM ubuntu:bionic

# Composer
COPY ./install-composer.sh /

# Disable frontend dialogs
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_VERSION 7.1
# Add ppa, curl and syslogd
RUN apt-get update && apt-get install -y software-properties-common curl wget inetutils-syslogd supervisor git && \
    apt-add-repository ppa:nginx/stable -y && \
    LC_ALL=C.UTF-8 apt-add-repository ppa:ondrej/php -y && \
    apt-get update && apt-get install -y \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-gd \
    php-gettext \
    php-redis \
    php-memcached \
    php-mailparse \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-mbstring \
    php-ast \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-apcu \
    zip \
    unzip \
    nginx && \
    sh /install-composer.sh && \
    rm /install-composer.sh && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/php && chmod -R 755 /run/php && \
    sed -i 's|.*listen =.*|listen=9000|g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i 's|.*error_log =.*|error_log=/proc/self/fd/2|g' /etc/php/${PHP_VERSION}/fpm/php-fpm.conf && \
    sed -i 's|.*access.log =.*|access.log=/proc/self/fd/2|g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i 's|.*user =.*|user=www-data|g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i 's|.*group =.*|group=www-data|g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i 's#.*variables_order.*#variables_order=EGPCS#g' /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i 's#.*date.timezone.*#date.timezone=UTC#g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i 's#.*clear_env.*#clear_env=no#g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

VOLUME /root/.composer
WORKDIR /app

COPY uploads.ini /etc/php/${PHP_VERSION}/fpm/conf.d/
COPY nginx.conf /etc/nginx/
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
RUN rm /etc/nginx/sites-enabled/default && \
    sed -i -e 's/PHP_VERSION/7.1/g' /etc/supervisor/conf.d/supervisor.conf

ENTRYPOINT ["/usr/bin/supervisord"]

