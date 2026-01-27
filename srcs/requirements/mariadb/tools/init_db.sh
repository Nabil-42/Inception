#!/bin/bash
set -e

DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"

DB_ROOT_PASS="$(cat /run/secrets/db_root_password)"
DB_USER_PASS="$(cat /run/secrets/db_password)"

# Si la base est déjà initialisée (volume persistant), on ne refait rien.
if [ -d "/var/lib/mysql/mysql" ]; then
  exec "$@"
fi

# Init du répertoire système
mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

# Démarrage temporaire (local uniquement) pour init
mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
pid="$!"

# Attente bornée (pas de boucle infinie)
for i in $(seq 1 30); do
  if mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Sécurisation + création DB + user
mariadb --socket=/run/mysqld/mysqld.sock <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

# Stop propre du serveur temporaire
mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASS}" shutdown
wait "$pid" 2>/dev/null || true

# Démarrage normal (PID 1 = mysqld)
exec "$@"
