#!/bin/bash
set -e

DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"

DB_ROOT_PASS="$(cat /run/secrets/db_root_password)"
DB_USER_PASS="$(cat /run/secrets/db_password)"

MARKER="/var/lib/mysql/.inception_initialized"
SOCK="/run/mysqld/mysqld.sock"

# Si déjà initialisé (volume persistant)
if [ -f "$MARKER" ]; then
  exec "$@"
fi

# Init du répertoire système (si nécessaire)
mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

# Démarrage temporaire (socket uniquement) pour l'init
mysqld --user=mysql --skip-networking --socket="$SOCK" &
pid="$!"

# Attente bornée que le serveur réponde
for i in $(seq 1 30); do
  if mariadb-admin --socket="$SOCK" -uroot ping >/dev/null 2>&1; then
    break
  fi
  sleep 1
  if [ "$i" -eq 30 ]; then
    echo "[mariadb-init] ERROR: mysqld not ready after 30s"
    exit 1
  fi
done

# Init SQL via socket en root (sans mot de passe au tout début)
mariadb --socket="$SOCK" -uroot <<SQL
-- Assurer un mot de passe root (sur localhost)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';

CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
SQL

# Marker pour ne pas refaire l'init au prochain démarrage
touch "$MARKER"

# Stop propre du serveur temporaire (maintenant root a un mot de passe)
mariadb-admin --socket="$SOCK" -uroot -p"${DB_ROOT_PASS}" shutdown
wait "$pid" 2>/dev/null || true

# Démarrage normal (PID 1 = mysqld)
exec "$@"
