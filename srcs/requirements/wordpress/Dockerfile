FROM debian:bookworm

# --- Install packages: PHP-FPM + extensions needed by WordPress, plus tools ---
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      mariadb-client \
      php-fpm \
      php-mysql \
      php-curl \
      php-gd \
      php-intl \
      php-mbstring \
      php-xml \
      php-zip \
      php-opcache \
      unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- WP-CLI ---
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
      -o /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# --- Prepare WordPress directory ---
RUN mkdir -p /var/www/wordpress && \
    chown -R www-data:www-data /var/www/wordpress

# --- PHP-FPM config: listen on 9000 inside container (for nginx fastcgi_pass) ---
# Default on Debian is typically a socket; we force TCP:9000 for Docker networking.
RUN sed -i 's|^listen = .*|listen = 9000|g' /etc/php/*/fpm/pool.d/www.conf && \
    mkdir -p /run/php

# --- Copy entrypoint ---
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/wordpress

EXPOSE 9000

# Entry point runs WP init, then starts php-fpm in foreground (container stays up)
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]