#!/bin/bash
set -e

# Read env vars from *_FILE if provided (Docker secrets pattern)
file_env() {
  name="$1"
  def="${2:-}"
  fileName="${name}_FILE"

  if [ -n "${!name:-}" ]; then
    export "$name"="${!name}"
    return
  fi

  if [ -n "${!fileName:-}" ] && [ -f "${!fileName}" ]; then
    export "$name"="$(cat "${!fileName}")"
    return
  fi

  export "$name"="$def"
}

file_env MYSQL_ROOT_PASSWORD
file_env MYSQL_PASSWORD

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

INIT_FLAG="/var/lib/mysql/.inception_init_done"

# Init DB only once (first container start or empty datadir)
if [ ! -d "/var/lib/mysql/mysql" ] || [ ! -f "$INIT_FLAG" ]; then
  echo "Initializing MariaDB data directory..."
  rm -rf /var/lib/mysql/*
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

  # Keep your SQL behavior (charset/collation + user/db/grants)
  cat > /tmp/init.sql <<EOF
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

  echo "Running MariaDB bootstrap (no background process)..."
  mysqld --user=mysql --bootstrap --skip-networking --datadir=/var/lib/mysql < /tmp/init.sql

  rm -f /tmp/init.sql
  touch "$INIT_FLAG"
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql