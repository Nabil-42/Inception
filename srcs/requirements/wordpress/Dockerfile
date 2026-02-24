FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4-fpm php7.4-mysql \
    mariadb-client curl \
    && rm -rf /var/lib/apt/lists/*

# wp-cli
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# PHP-FPM écoute en TCP 9000
RUN set -eux; \
  CONF="/etc/php/7.4/fpm/pool.d/www.conf"; \
  sed -i 's|^[[:space:]]*listen[[:space:]]*=.*|listen = 0.0.0.0:9000|' "$CONF"; \
  sed -i '/^[[:space:]]*;[[:space:]]*listen\.allowed_clients/d' "$CONF"; \
  sed -i '/^[[:space:]]*listen\.allowed_clients/d' "$CONF"; \
  mkdir -p /run/php

WORKDIR /var/www/html

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm7.4", "-F"]
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4-fpm php7.4-mysql \
    mariadb-client curl \
    && rm -rf /var/lib/apt/lists/*

# wp-cli
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# PHP-FPM écoute en TCP 9000
RUN set -eux; \
  CONF="/etc/php/7.4/fpm/pool.d/www.conf"; \
  sed -i 's|^[[:space:]]*listen[[:space:]]*=.*|listen = 0.0.0.0:9000|' "$CONF"; \
  sed -i '/^[[:space:]]*;[[:space:]]*listen\.allowed_clients/d' "$CONF"; \
  sed -i '/^[[:space:]]*listen\.allowed_clients/d' "$CONF"; \
  mkdir -p /run/php

WORKDIR /var/www/html

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm7.4", "-F"]
