# Inception

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://github.com/Nabil-42/Inception)
[![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat&logo=nginx&logoColor=white)](https://github.com/Nabil-42/Inception)
[![WordPress](https://img.shields.io/badge/WordPress-21759B?style=flat&logo=wordpress&logoColor=white)](https://github.com/Nabil-42/Inception)
[![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat&logo=mariadb&logoColor=white)](https://github.com/Nabil-42/Inception)
[![School](https://img.shields.io/badge/%C3%89cole_42-Paris-00babc?style=flat)](https://42.fr)

A multi-container Docker infrastructure deploying a WordPress site with Nginx as reverse proxy and MariaDB as the database backend.

## Description

`Inception` builds a fully containerized web stack from scratch using Docker Compose. Every service runs in its own container built from a custom Dockerfile based on the penultimate stable Debian release. No pre-built images (e.g., DockerHub WordPress/MariaDB) are used — all services are configured manually.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                     Host machine                     │
│                                                     │
│   ┌──────────┐     ┌──────────────┐     ┌────────┐  │
│   │  Nginx   │────▶│  WordPress   │────▶│MariaDB │  │
│   │ :443     │     │  (php-fpm)   │     │ :3306  │  │
│   └──────────┘     └──────────────┘     └────────┘  │
│        │                  │                  │       │
│   [SSL cert]        [wp-content vol]   [db vol]      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

| Service | Role | Port |
|---------|------|------|
| **Nginx** | Reverse proxy, TLS termination (TLSv1.2/1.3 only) | 443 |
| **WordPress** | PHP-FPM application server | internal |
| **MariaDB** | Database backend | internal |

## Volumes

| Volume | Path in container | Purpose |
|--------|------------------|---------|
| `wordpress` | `/var/www/html` | WordPress files |
| `mariadb` | `/var/lib/mysql` | Database data |

Both volumes are mounted from the host at `/home/<user>/data/`.

## Secrets & Environment

Credentials are never hardcoded. A `.env` file (not committed) provides:

```env
DOMAIN_NAME=login.42.fr
MYSQL_ROOT_PASSWORD=...
MYSQL_DATABASE=wordpress
MYSQL_USER=...
MYSQL_PASSWORD=...
WP_ADMIN_USER=...
WP_ADMIN_PASSWORD=...
WP_USER=...
WP_USER_PASSWORD=...
```

See `.env.example` for the full template.

## Launch

```bash
# Build and start all services
make

# Stop and remove containers
make down

# Full cleanup (containers + volumes)
make fclean
```

The site is accessible at `https://localhost` (or `https://<DOMAIN_NAME>` with the appropriate `/etc/hosts` entry).

## Stack

- **Docker**, **Docker Compose**
- **Nginx** (TLS 1.2/1.3, self-signed cert via OpenSSL)
- **WordPress** (php-fpm, no Apache)
- **MariaDB**
- **Debian** (penultimate stable, used as base image for all containers)

## 42 Project Info

| Field | Value |
|-------|-------|
| **Project** | Inception |
| **Circle** | 5 |

## What I Learned

- Writing Dockerfiles from scratch (no pre-built app images)
- Docker Compose service orchestration, dependency ordering, and networking
- TLS configuration in Nginx with self-signed certificates
- Managing secrets and environment variables outside of source control
- Volume persistence and data separation between containers