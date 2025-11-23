# Utilise Debian
FROM debian:bullseye

# Installation des dépendances
RUN apt-get update && apt-get install -y \
    php7.4-fpm php7.4-mysql curl mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Téléchargement de WordPress
RUN mkdir -p /var/www/html
WORKDIR /var/www/html
RUN curl -O https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz --strip-components=1 \
    && rm latest.tar.gz

# Copie du script d’installation
COPY tools/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

# Lancement de PHP-FPM au démarrage
ENTRYPOINT ["/tmp/setup.sh"]
CMD ["php-fpm7.4", "-F"]
