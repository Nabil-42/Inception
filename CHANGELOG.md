# Changelog — Inception

All notable changes to the Inception project.

## [1.0.0] — 2025

### Added
- Custom Dockerfile for Nginx (Debian-based, TLS 1.2/1.3 only)
- Custom Dockerfile for WordPress with php-fpm (no Apache)
- Custom Dockerfile for MariaDB with initialization scripts
- Docker Compose configuration with named volumes and isolated network
- Self-signed TLS certificate generation via OpenSSL
- Environment variable configuration via `.env` file
- Persistent volumes for database data and WordPress files
- Makefile targets: `all`, `down`, `fclean`, `re`
- WordPress auto-configuration via `wp-cli` at container startup
