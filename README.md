# Inception

This project consists in setting up a complete WordPress infrastructure using Docker and Docker Compose, following strict constraints defined by the 42 Inception subject.

The goal is to understand how containerized services interact together while respecting security, isolation and persistence requirements.

---

The stack includes:
- Nginx (HTTPS only)
- WordPress with PHP-FPM
- MariaDB
- Docker volumes for persistence
- Docker secrets for credentials

---

## Requirements

- Docker
- Docker Compose
- GNU Make

---

## Installation & Launch

Build and start the infrastructure:

```bash
make

Or manually:

docker compose -f srcs/docker-compose.yml up -d --build

## Access

Add the following line to your /etc/hosts file:

127.0.0.1 nabil.42.fr

Then open your browser at:

https://nabil.42.fr

## Stop & Cleanup

Stop containers:

make down

Full cleanup (containers, volumes, network):

docker compose -f srcs/docker-compose.yml down -v --remove-orphans