COMPOSE := docker compose

.PHONY: start up down restart stop logs ps status reset pull config

start:
	$(COMPOSE) up -d

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

restart:
	$(COMPOSE) down
	$(COMPOSE) up -d

logs:
	$(COMPOSE) logs -f --tail=200

ps status:
	$(COMPOSE) ps

pull:
	$(COMPOSE) pull

config:
	$(COMPOSE) config

reset:
	$(COMPOSE) down -v --remove-orphans
