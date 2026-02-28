#!/bin/bash
set -e

WP_PATH="/var/www/html"
cd "$WP_PATH"

log() { echo "[wp] $*"; }

# Lire secrets (si définis)
if [ -n "${MYSQL_PASSWORD_FILE:-}" ] && [ -f "$MYSQL_PASSWORD_FILE" ]; then
  MYSQL_PASSWORD="$(cat "$MYSQL_PASSWORD_FILE")"
fi
if [ -n "${WP_MASTER_PASSWORD_FILE:-}" ] && [ -f "$WP_MASTER_PASSWORD_FILE" ]; then
  WP_MASTER_PASSWORD="$(cat "$WP_MASTER_PASSWORD_FILE")"
fi
if [ -n "${WP_USER_PASSWORD_FILE:-}" ] && [ -f "$WP_USER_PASSWORD_FILE" ]; then
  WP_USER_PASSWORD="$(cat "$WP_USER_PASSWORD_FILE")"
fi

# Sanity checks minimales
: "${MYSQL_HOST:?MYSQL_HOST missing}"
: "${MYSQL_DATABASE:?MYSQL_DATABASE missing}"
: "${MYSQL_USER:?MYSQL_USER missing}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD missing}"
: "${DOMAIN_NAME:?DOMAIN_NAME missing}"
: "${WP_TITLE:?WP_TITLE missing}"
: "${WP_MASTER_USER:?WP_MASTER_USER missing}"
: "${WP_MASTER_EMAIL:?WP_MASTER_EMAIL missing}"
: "${WP_MASTER_PASSWORD:?WP_MASTER_PASSWORD missing}"
: "${WP_USER:?WP_USER missing}"
: "${WP_USER_EMAIL:?WP_USER_EMAIL missing}"
: "${WP_USER_PASSWORD:?WP_USER_PASSWORD missing}"

# Attendre MariaDB (et échouer proprement si jamais dispo)
for i in $(seq 1 60); do
  if mariadb -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1;" >/dev/null 2>&1; then
    log "MariaDB OK"
    break
  fi
  log "Waiting for MariaDB... ($i/60)"
  sleep 1
done

if ! mariadb -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1;" >/dev/null 2>&1; then
  log "ERROR: MariaDB not reachable after 60s."
  exit 1
fi

# Télécharger WP si absent (volume persistant)
if [ ! -f "$WP_PATH/wp-includes/version.php" ]; then
  log "Downloading WordPress..."
  wp core download --allow-root --path="$WP_PATH"
fi

# Créer wp-config.php si absent
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  log "Creating wp-config.php..."
  wp config create \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="$MYSQL_HOST" \
    --allow-root \
    --path="$WP_PATH"
fi

# Installer WP si pas installé
if ! wp core is-installed --allow-root --path="$WP_PATH" >/dev/null 2>&1; then
  log "Installing WordPress..."
  wp core install \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_MASTER_USER}" \
    --admin_password="${WP_MASTER_PASSWORD}" \
    --admin_email="${WP_MASTER_EMAIL}" \
    --skip-email \
    --allow-root \
    --path="$WP_PATH"

  log "Creating secondary user..."
  wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
    --role=author \
    --user_pass="${WP_USER_PASSWORD}" \
    --allow-root \
    --path="$WP_PATH"
fi

log "Starting PHP-FPM..."
exec "$@"