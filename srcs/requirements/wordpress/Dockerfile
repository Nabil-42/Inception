FROM debian:bullseye

RUN apt update && apt install -y \
    php7.4-fpm php7.4-mysql \
    mariadb-client curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# wp-cli
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# Configure PHP-FPM to listen on TCP 9000 (instead of unix socket)
RUN set -eux; \
    CONF="/etc/php/7.4/fpm/pool.d/www.conf"; \
    sed -i 's|^listen = .*|listen = 9000|' "$CONF"; \
    sed -i 's|^;*listen.allowed_clients =.*|listen.allowed_clients = 0.0.0.0/0|' "$CONF"; \
    sed -i 's|^;*catch_workers_output =.*|catch_workers_output = yes|' "$CONF" || true; \
    sed -i 's|^;*decorate_workers_output =.*|decorate_workers_output = no|' "$CONF" || true; \
    mkdir -p /run/php

COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/wp_setup.sh"]
CMD ["php-fpm7.4", "-F"]
