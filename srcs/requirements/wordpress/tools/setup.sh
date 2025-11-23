#!/bin/bash
set -e

# 📁 Dossier WordPress
cd /var/www/html

# 📄 Si le fichier wp-config.php n’existe pas, on le crée
if [ ! -f wp-config.php ]; then
    echo "📝 Création du fichier wp-config.php..."
    cp wp-config-sample.php wp-config.php
    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
    sed -i "s/localhost/${MYSQL_HOST}/" wp-config.php
fi

# ⚙️ Attendre que MariaDB soit prête avant l’installation
until mysqladmin ping -h"$MYSQL_HOST" --silent; do
    echo "⏳ En attente de la base de données..."
    sleep 2
done

# ⚙️ Installer WordPress avec WP-CLI (si non installé)
if [ ! -f .installed ]; then
    echo "🚀 Installation de WordPress..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" --role=author --user_pass="${WP_USER_PASSWORD}" --allow-root
    touch .installed
fi

echo "✅ WordPress prêt !"
exec "$@"
