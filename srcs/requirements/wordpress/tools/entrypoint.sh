#!/bin/bash
set -e

WP_PATH="/var/www/wordpress"

read_secret() {
  local var="$1"
  local def="${2:-}"
  local file_var="${var}_FILE"

  if [ -n "${!file_var:-}" ] && [ -f "${!file_var}" ]; then
    export "$var"="$(cat "${!file_var}")"
  elif [ -n "${!var:-}" ]; then
    export "$var"="${!var}"
  else
    export "$var"="$def"
  fi
}

# ---- Read secrets ----
read_secret "MYSQL_PASSWORD" ""
read_secret "WP_ADMIN_PASSWORD" ""
read_secret "WP_USER_PASSWORD" ""

# ---- Required env ----
: "${DOMAIN_NAME:?DOMAIN_NAME missing}"
: "${MYSQL_DATABASE:?MYSQL_DATABASE missing}"
: "${MYSQL_USER:?MYSQL_USER missing}"
: "${WP_TITLE:?WP_TITLE missing}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER missing}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL missing}"
: "${WP_USER:?WP_USER missing}"
: "${WP_USER_EMAIL:?WP_USER_EMAIL missing}"

MYSQL_HOST="${MYSQL_HOST:-mariadb}"
MYSQL_PORT="${MYSQL_PORT:-3306}"

mkdir -p "$WP_PATH"
chown -R www-data:www-data /var/www

echo "Waiting for MariaDB..."
until mysqladmin ping -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  sleep 1
done

if [ ! -f "$WP_PATH/wp-load.php" ]; then
  wp core download --path="$WP_PATH" --allow-root
  chown -R www-data:www-data "$WP_PATH"
fi

if [ ! -f "$WP_PATH/wp-config.php" ]; then
  wp config create --path="$WP_PATH" --allow-root \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="$MYSQL_HOST:$MYSQL_PORT" \
    --skip-check
fi

if ! wp core is-installed --path="$WP_PATH" --allow-root; then
  wp core install --path="$WP_PATH" --allow-root \
    --url="https://$DOMAIN_NAME" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email
fi

wp option update home "https://$DOMAIN_NAME" --path="$WP_PATH" --allow-root
wp option update siteurl "https://$DOMAIN_NAME" --path="$WP_PATH" --allow-root

if wp user get "$WP_USER" --path="$WP_PATH" --allow-root; then
  wp user update "$WP_USER" --path="$WP_PATH" --allow-root \
    --user_pass="$WP_USER_PASSWORD"
else
  wp user create "$WP_USER" "$WP_USER_EMAIL" \
    --path="$WP_PATH" --allow-root \
    --role=subscriber \
    --user_pass="$WP_USER_PASSWORD"
fi

exec "$@"