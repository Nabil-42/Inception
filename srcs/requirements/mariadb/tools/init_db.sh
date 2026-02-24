#!/bin/bash
set -e

DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"

DB_ROOT_PASS="$(cat /run/secrets/db_root_password)"
DB_USER_PASS="$(cat /run/secrets/db_user_password)"

MARKER="/var/lib/mysql/.inception_initialized"

if [ -f "$MARKER" ]; then
  exec "$@"
fi

mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
pid="$!"

ready=""
for i in $(seq 1 30); do
  if mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; then
    ready="yes"
    break
  fi
  sleep 1
done

if [ -z "$ready" ]; then
  echo "[mariadb-init] ERROR: mysqld not ready after timeout"
  kill "$pid" 2>/dev/null || true
  exit 1
fi

mariadb --socket=/run/mysqld/mysqld.sock <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

touch "$MARKER"
chown mysql:mysql "$MARKER"

mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASS}" shutdown
wait "$pid" 2>/dev/null || true

exec "$@"
