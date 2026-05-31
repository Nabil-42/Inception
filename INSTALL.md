# Installation — Inception

## System Requirements

- **OS**: Linux or macOS
- **Docker**: >= 20.10
- **Docker Compose**: >= 1.29 (v1) or >= 2.0 (v2)
- **Make**
- **OpenSSL** (for generating the self-signed TLS certificate)

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/Nabil-42/Inception.git
cd Inception
```

### 2. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` and fill in all required values:

```env
DOMAIN_NAME=login.42.fr          # or localhost
MYSQL_ROOT_PASSWORD=your_root_pw
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=wp_password
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=admin_password
WP_USER=editor
WP_USER_PASSWORD=editor_password
```

### 3. Configure /etc/hosts (if using a custom domain)

```bash
sudo echo "127.0.0.1 login.42.fr" >> /etc/hosts
```

### 4. Create data directories

```bash
sudo mkdir -p /home/$USER/data/wordpress /home/$USER/data/mariadb
```

### 5. Build and start

```bash
make
```

This will:
- Generate a self-signed TLS certificate
- Build all Docker images from Dockerfiles
- Start Nginx, WordPress (php-fpm), and MariaDB containers
- Mount persistent volumes for database and WordPress files

## Verify Installation

```bash
docker ps          # all 3 containers should be running
docker logs nginx  # check for configuration errors
```

Open `https://localhost` (or `https://login.42.fr`) in your browser and accept the self-signed certificate warning.
