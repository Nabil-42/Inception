# Usage — Inception

## Starting the Stack

```bash
make        # build images and start all containers
```

## Stopping the Stack

```bash
make down   # stop and remove containers (data persisted in volumes)
```

## Full Cleanup

```bash
make fclean # stop containers, remove images, delete volumes and data
```

## Accessing the Services

| Service | URL | Notes |
|---------|-----|-------|
| WordPress site | `https://localhost` | Accept self-signed cert |
| WordPress admin | `https://localhost/wp-admin` | Credentials from `.env` |
| MariaDB | internal only | Port 3306, not exposed to host |

## Connecting to the Database (debug)

```bash
docker exec -it mariadb mysql -u root -p
# enter MYSQL_ROOT_PASSWORD from .env
```

## Checking Logs

```bash
docker logs nginx      # Nginx access/error logs
docker logs wordpress  # PHP-FPM logs
docker logs mariadb    # MariaDB startup and query logs
```

## Managing WordPress Files

WordPress files are stored in the `wordpress` Docker volume, mounted at `/var/www/html` inside the container:

```bash
docker exec -it wordpress ls /var/www/html
```

## Common Issues

| Issue | Fix |
|-------|-----|
| Container exits immediately | Check `docker logs <container>` for startup errors |
| Site shows "connection refused" | Verify Nginx is running: `docker ps` |
| Database connection error | Check `.env` credentials match between WordPress and MariaDB |
| Permission denied on volumes | Check ownership of `/home/$USER/data/` directories |
