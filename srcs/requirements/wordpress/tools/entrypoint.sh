#!/bin/bash
set -e

file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"

  local val="$def"
  if [ -n "${!var:-}" ]; then
    val="${!var}"
  elif [ -n "${!fileVar:-}" ] && [ -f "${!fileVar}" ]; then
    val="$(cat "${!fileVar}")"
  fi
  export "$var"="$val"
}

file_env MYSQL_PASSWORD
file_env WP_ADMIN_PASSWORD
file_env WP_USER_PASSWORD

WP_PATH="/var/www/wordpress"
INIT_FLAG="$WP_PATH/.inception_wp_done"

mkdir -p "$WP_PATH"
chown -R www-data:www-data "$WP_PATH"

echo "Waiting for MariaDB..."
for i in {1..60}; do
  if mariadb-admin ping -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; then
    break
  fi
  sleep 1
done

if ! mariadb-admin ping -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; then
  echo "MariaDB is not reachable."
  exit 1
fi

if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "Downloading WordPress..."
  wp core download --path="$WP_PATH" --allow-root
fi

if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "Creating wp-config.php..."
  wp config create --path="$WP_PATH" --allow-root \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="mariadb:3306"
fi

if [ ! -f "$INIT_FLAG" ]; then
  echo "Installing WordPress..."
  wp core install --path="$WP_PATH" --allow-root \
    --url="https://${DOMAIN_NAME}" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL"

  echo "Creating second user..."
  wp user create --path="$WP_PATH" --allow-root \
    "$WP_USER" "$WP_USER_EMAIL" \
    --user_pass="$WP_USER_PASSWORD"

  touch "$INIT_FLAG"
  chown www-data:www-data "$INIT_FLAG"
  echo "WordPress setup done."
fi

chown -R www-data:www-data "$WP_PATH"

echo "Starting PHP-FPM..."
exec php-fpm8.2 -F
