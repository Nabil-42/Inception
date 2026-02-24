#!/bin/bash
set -e

: "${DOMAIN_NAME:?DOMAIN_NAME missing}"

# Certificat (persisté via volume ssl_data)
if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
  echo "[nginx] Generating self-signed certificate for ${DOMAIN_NAME}..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=France/L=Paris/O=42/OU=Student/CN=${DOMAIN_NAME}"
fi

# Générer conf finale depuis template
envsubst '${DOMAIN_NAME}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

exec "$@"
