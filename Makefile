# DICE Development Environment - Service Management
.PHONY: help setup start stop restart clean logs test backup restore

# Default target
.DEFAULT_GOAL := help

# Variables
COMPOSE_FILE := docker-compose.yml
BACKUP_DIR := ./infrastructure/data/backups
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

help: ## Show this help message
	@echo "DICE Development Environment Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Initial setup of development environment
	@echo "Setting up DICE development environment..."
	@./infrastructure/scripts/setup-environment.sh --type development
	@echo "✅ Setup complete!"

start-all: ## Start all services
	@echo "Starting all DICE services..."
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "✅ All services started!"
	@echo "🌐 Access your services:"
	@echo "   PWA:     https://pwa.dice.local"
	@echo "   API:     https://api.dice.local"
	@echo "   Traefik:  https://traefik.dice.local:8080"

start-backend: ## Start backend services only (DB + Redis + Backend)
	@echo "Starting backend services..."
	@docker compose -f $(COMPOSE_FILE) up -d postgres redis backend
	@echo "✅ Backend services started!"

start-frontend: ## Start frontend with mocks
	@echo "Starting PWA with development mocks..."
	@docker compose -f $(COMPOSE_FILE) up -d pwa
	@echo "✅ PWA started with mock data!"

stop: ## Stop all services
	@echo "Stopping all services..."
	@docker compose -f $(COMPOSE_FILE) down
	@echo "✅ All services stopped!"

restart: ## Restart all services
	@echo "Restarting all services..."
	@docker compose -f $(COMPOSE_FILE) restart
	@echo "✅ All services restarted!"

clean: ## Stop services and remove volumes
	@echo "⚠️  This will remove all data! Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	@docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	@docker system prune -f
	@echo "✅ Environment cleaned!"

logs: ## Show logs for all services
	@docker compose -f $(COMPOSE_FILE) logs -f

logs-backend: ## Show backend logs
	@docker compose -f $(COMPOSE_FILE) logs -f backend

logs-pwa: ## Show PWA logs
	@docker compose -f $(COMPOSE_FILE) logs -f pwa

debug-backend: ## Start backend in debug mode
	@echo "Starting backend in debug mode..."
	@echo "🐛 Backend debug mode - connect to localhost:9229"
	@docker compose -f $(COMPOSE_FILE) up -d backend

test: ## Run all tests (when services are implemented)
	@echo "Running all tests..."
	@echo "⚠️  Tests will be implemented in service setup phase"

backup-db: ## Backup PostgreSQL database
	@echo "Creating database backup..."
	@mkdir -p $(BACKUP_DIR)
	@docker compose -f $(COMPOSE_FILE) exec postgres pg_dump -U dice_user dice_db > $(BACKUP_DIR)/backup_$(TIMESTAMP).sql
	@echo "✅ Database backed up to $(BACKUP_DIR)/backup_$(TIMESTAMP).sql"

restore-db: ## Restore database from backup (use: make restore-db BACKUP=filename)
	@echo "Restoring database from $(BACKUP_DIR)/$(BACKUP)..."
	@docker compose -f $(COMPOSE_FILE) exec -T postgres psql -U dice_user -d dice_db < $(BACKUP_DIR)/$(BACKUP)
	@echo "✅ Database restored from $(BACKUP)!"

status: ## Show service status
	@echo "DICE Services Status:"
	@docker compose -f $(COMPOSE_FILE) ps

health: ## Check service health
	@echo "Checking service health..."
	@docker compose -f $(COMPOSE_FILE) exec postgres pg_isready -U dice_user -d dice_db || echo "❌ PostgreSQL not ready"
	@docker compose -f $(COMPOSE_FILE) exec redis redis-cli ping || echo "❌ Redis not ready"
	@echo "✅ Health checks completed!"

# Phase-specific targets
phase1: setup start-backend start-frontend ## Complete Phase 1 setup
	@echo "🎯 Phase 1 implementation in progress!"
	@echo "📝 Run 'make health' to verify services" 