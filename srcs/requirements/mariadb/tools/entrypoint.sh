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

file_env MYSQL_ROOT_PASSWORD
file_env MYSQL_PASSWORD

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

INIT_FLAG="/var/lib/mysql/.inception_init_done"

# Detect if system tables exist (more reliable than directory existence)
SYSTEM_OK=0
if [ -d "/var/lib/mysql/mysql" ]; then
  if ls /var/lib/mysql/mysql/user.* >/dev/null 2>&1; then
    SYSTEM_OK=1
  elif ls /var/lib/mysql/mysql/db.* >/dev/null 2>&1; then
    SYSTEM_OK=1
  fi
fi

if [ ! -f "$INIT_FLAG" ] || [ "$SYSTEM_OK" -eq 0 ]; then
  echo "Initializing MariaDB system tables..."
  rm -rf /var/lib/mysql/*
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null

  echo "Starting MariaDB temporarily for init..."
  mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid="$!"

  for i in {1..30}; do
    if mariadb-admin ping --socket=/run/mysqld/mysqld.sock --silent; then
      break
    fi
    sleep 1
  done

  if ! mariadb-admin ping --socket=/run/mysqld/mysqld.sock --silent; then
    echo "MariaDB did not start correctly."
    exit 1
  fi

  echo "Applying initial SQL..."
  mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

  echo "Shutting down temporary MariaDB..."
  mariadb-admin --protocol=socket --socket=/run/mysqld/mysqld.sock -p"${MYSQL_ROOT_PASSWORD}" shutdown
  wait "$pid" || true

  touch "$INIT_FLAG"
  chown mysql:mysql "$INIT_FLAG"
  echo "MariaDB initialization done."
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql
