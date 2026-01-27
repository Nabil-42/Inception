#!/bin/bash
set -e

DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASS="$(cat /run/secrets/db_password)"
DB_HOST="mariadb:3306"

WP_ADMIN_USER="${WP_ADMIN_USER}"
WP_ADMIN_PASS="$(cat /run/secrets/wp_admin_password)"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL}"

WP_USER_USER="${WP_USER_USER}"
WP_USER_PASS="$(cat /run/secrets/wp_user_password)"
WP_USER_EMAIL="${WP_USER_EMAIL}"

WP_TITLE="${WP_TITLE}"
WP_URL="${WP_URL}"

# Attente bornée DB (pas de boucle infinie)
for i in $(seq 1 30); do
  if mariadb -h  mariadb -P 3306 -u "${DB_USER}" -p"${DB_PASS}" -e "SELECT 1;" "${DB_NAME}" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Installer WP seulement si pas déjà fait (volume persistant)
if [ ! -f wp-config.php ]; then
  wp core download --allow-root

  wp config create \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST}" \
    --allow-root

  wp core install \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  wp user create "${WP_USER_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASS}" \
    --role=author \
    --allow-root
fi

exec "$@"
