FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
      php8.2-fpm php8.2-mysql \
      mariadb-client curl ca-certificates \
      unzip less && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# PHP-FPM config
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# WordPress init script
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN mkdir -p /var/www/wordpress && chown -R www-data:www-data /var/www/wordpress

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
