FROM debian:bullseye

RUN apt update && apt install -y \
    php7.4-fpm php7.4-mysql \
    curl mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# wp-cli
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# PHP-FPM listen on 9000 for nginx fastcgi
RUN sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf \
    && mkdir -p /run/php

COPY tools/wp_setup.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/wp_setup.sh"]
CMD ["php-fpm7.4", "-F"]
