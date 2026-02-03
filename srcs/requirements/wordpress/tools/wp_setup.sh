#!/bin/bash
set -e

log() { echo "[wp_setup] $*"; }

DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASS="$(cat /run/secrets/db_password)"
DB_HOST="${MYSQL_HOST:-mariadb}"
DB_PORT="${MYSQL_PORT:-3306}"

WP_URL="${WP_URL}"
WP_TITLE="${WP_TITLE}"

WP_ADMIN_USER="${WP_ADMIN_USER}"
WP_ADMIN_PASS="$(cat /run/secrets/wp_admin_password)"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL}"

WP_USER_USER="${WP_USER_USER}"
WP_USER_PASS="$(cat /run/secrets/wp_user_password)"
WP_USER_EMAIL="${WP_USER_EMAIL}"

cd /var/www/html

log "Waiting for MariaDB at ${DB_HOST}:${DB_PORT}..."
for i in $(seq 1 30); do
  if mariadb -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" -e "SELECT 1;" >/dev/null 2>&1; then
    log "MariaDB OK"
    break
  fi
  sleep 1
  if [ "$i" -eq 30 ]; then
    log "ERROR: MariaDB not reachable after 30s"
    exit 1
  fi
done

# Download WP if not present
if [ ! -f wp-load.php ]; then
  log "Downloading WordPress..."
  wp core download --allow-root
fi

# Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
  log "Creating wp-config.php..."
  wp config create \
    --dbname="${DB_NAME}" \
    --dbuser="${DB_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="${DB_HOST}:${DB_PORT}" \
    --allow-root
fi

# Install WP only if not installed
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
  log "Installing WordPress..."
  wp core install \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  log "Creating secondary user..."
  wp user create "${WP_USER_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASS}" \
    --role=author \
    --allow-root
else
  log "WordPress already installed"
fi

log "Starting PHP-FPM..."
exec "$@"
