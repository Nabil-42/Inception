#!/bin/bash
set -e

CERT=/etc/nginx/ssl/cert.pem
KEY=/etc/nginx/ssl/key.pem

if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY" -out "$CERT" \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=nabboud.42.fr"
fi

exec "$@"
