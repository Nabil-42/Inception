# Inception

This project has been created as part of the 42 curriculum
by Nabboud

The goal of the Inception project is to set up a complete containerized web infrastructure using Docker and Docker Compose, while respecting strict constraints defined in the subject.

The infrastructure hosts a WordPress website, secured with HTTPS only, and focuses on:

service isolation

secure configuration

data persistence

proper orchestration of multiple containers

This project aims to provide a concrete understanding of how containerized services interact together in a controlled and secure environment.

# Architecture

The infrastructure is composed of the following services:

NGINX
Acts as the single entry point, serves HTTPS traffic only (TLS 1.2 / 1.3), and works as a reverse proxy.

WordPress + PHP-FPM
Runs the WordPress application and handles PHP execution.

MariaDB
Stores WordPress data in a dedicated database.

Docker Volumes
Used to persist WordPress files and MariaDB data on the host system.

Docker Secrets
Used to securely store sensitive information such as database and WordPress credentials.

All services communicate through a dedicated Docker network defined in docker-compose.yml.

# Requirements

Docker

Docker Compose

GNU Make

# Instructions

1) Clone the repository
git clone <repository_url>
cd inception
2) Create required local directories
mkdir -p /home/${USER}/data/mariadb
mkdir -p /home/${USER}/data/wordpress
mkdir -p srcs/secrets
3) Create secrets locally (not committed)
printf "db_password\n" > srcs/secrets/db_root_password.txt
printf "db_password\n" > srcs/secrets/db_user_password.txt
printf "wp_master_password\n" > srcs/secrets/wp_master_password.txt
printf "wp_user_password\n" > srcs/secrets/wp_user_password.txt

Secrets are never pushed to the repository and are created locally during evaluation.

4) $Build and start the infrastructure

make up

Or manually:

docker compose -f srcs/docker-compose.yml up -d --build
Access

Add the following line to your /etc/hosts file:

<VM_IP_ADDRESS> nabil.42.fr

with: 
ip -4 addr show scope global
sudo sh -c 'echo "<VM_IP_ADDRESS> nabil.42.fr" >> /etc/hosts'

Then open your browser at:

https://nabil.42.fr

Stop & Cleanup

Stop containers:

make down

Stop containers, remove volumes and network:

docker compose -f srcs/docker-compose.yml down -v --remove-orphans

# Resources & AI Usage
External resources

Docker official documentation

Docker Compose documentation

NGINX documentation

WordPress and WP-CLI documentation

# AI usage

AI tools were used only as a learning and assistance resource, to:

- clarify Docker and Docker Compose concepts

- understand error messages and debugging strategies

- improve explanations and documentation wording

- help for script like setup.sh ...

All design choices, implementation, and final configuration were fully understood and validated by the author.