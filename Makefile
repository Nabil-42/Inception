NAME = inception

COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE = docker compose -f $(COMPOSE_FILE)

DATA_DIR = /home/nabboud/data
MARIADB_DIR = $(DATA_DIR)/mariadb
WP_DIR = $(DATA_DIR)/wordpress

all: up

dirs:
	@sudo mkdir -p $(MARIADB_DIR) $(WP_DIR)
	@sudo chown -R $(USER):$(USER) $(DATA_DIR)

up: dirs
	@$(COMPOSE) up -d --build
	@$(COMPOSE) ps

down:
	@$(COMPOSE) down

restart:
	@$(COMPOSE) restart
	@$(COMPOSE) ps

logs:
	@$(COMPOSE) logs --tail=150

clean: down
	@docker image rm -f nginx:1.0 wordpress:1.0 mariadb:1.0 2>/dev/null || true

fclean: clean
	@docker system prune -af --volumes
	@sudo rm -rf $(MARIADB_DIR)/* $(WP_DIR)/*

re: fclean up

.PHONY: all dirs up down restart logs clean fclean re
