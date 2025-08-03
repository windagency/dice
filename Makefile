# DICE Development Environment - Service Management
.PHONY: help setup start stop restart clean logs test backup restore status health

# Default target
.DEFAULT_GOAL := help

# Variables
ORCHESTRATOR_SCRIPT := ./infrastructure/scripts/docker-orchestrator.sh
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

start-all: ## Start full integrated stack with all services
	@echo "Starting full DICE integrated stack..."
	@$(ORCHESTRATOR_SCRIPT) full-stack
	@echo "✅ Full stack started!"
	@echo "🌐 Access your services:"
	@echo "   Backend API: http://localhost:3001"
	@echo "   PWA Frontend: http://localhost:3000"
	@echo "   Storybook: http://localhost:6006"
	@echo "   Temporal UI: http://localhost:8088"
	@echo "   PostgreSQL: localhost:5432"
	@echo "   Redis: localhost:6379"

start-backend: ## Start backend services only (DB + Redis + Backend + Temporal)
	@echo "Starting backend services..."
	@$(ORCHESTRATOR_SCRIPT) backend-only
	@echo "✅ Backend services started!"

start-frontend: ## Start PWA frontend with development mocks
	@echo "Starting PWA frontend with development mocks..."
	@$(ORCHESTRATOR_SCRIPT) pwa-only
	@echo "✅ PWA frontend started!"

start-proxy: ## Start full stack with Traefik reverse proxy
	@echo "Starting full stack with reverse proxy..."
	@$(ORCHESTRATOR_SCRIPT) full-stack --proxy
	@echo "✅ Full stack with proxy started!"

start-monitoring: ## Start full stack with monitoring (Prometheus + Grafana)
	@echo "Starting full stack with monitoring..."
	@$(ORCHESTRATOR_SCRIPT) full-stack --monitoring
	@echo "✅ Full stack with monitoring started!"

start-logging: ## Start full stack with ELK logging stack
	@echo "Starting full stack with logging..."
	@$(ORCHESTRATOR_SCRIPT) full-stack --logging
	@echo "✅ Full stack with logging started!"

start-aws: ## Start full stack with LocalStack AWS services
	@echo "Starting full stack with AWS services..."
	@$(ORCHESTRATOR_SCRIPT) full-stack --aws
	@echo "✅ Full stack with AWS services started!"

stop: ## Stop all services
	@echo "Stopping all services..."
	@$(ORCHESTRATOR_SCRIPT) stop
	@echo "✅ All services stopped!"

restart: ## Restart all services
	@echo "Restarting all services..."
	@$(ORCHESTRATOR_SCRIPT) stop
	@$(ORCHESTRATOR_SCRIPT) full-stack
	@echo "✅ All services restarted!"

clean: ## Stop services and remove volumes
	@echo "⚠️  This will remove all data! Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	@$(ORCHESTRATOR_SCRIPT) clean
	@echo "✅ Environment cleaned!"

logs: ## Show logs for all services
	@$(ORCHESTRATOR_SCRIPT) logs

logs-backend: ## Show backend logs
	@$(ORCHESTRATOR_SCRIPT) logs backend

logs-pwa: ## Show PWA logs
	@$(ORCHESTRATOR_SCRIPT) logs pwa

logs-temporal: ## Show Temporal logs
	@docker logs backend_temporal -f

debug-backend: ## Start backend in debug mode
	@echo "Starting backend in debug mode..."
	@echo "🐛 Backend debug mode - connect to localhost:9229"
	@cd workspace/backend && docker compose --env-file ../../.env up -d backend

test: ## Run all tests (when services are implemented)
	@echo "Running all tests..."
	@echo "⚠️  Tests will be implemented in service setup phase"

backup-db: ## Backup PostgreSQL database
	@echo "Creating database backup..."
	@mkdir -p $(BACKUP_DIR)
	@docker exec backend_postgres pg_dump -U dice_user dice_db > $(BACKUP_DIR)/backup_$(TIMESTAMP).sql
	@echo "✅ Database backed up to $(BACKUP_DIR)/backup_$(TIMESTAMP).sql"

restore-db: ## Restore database from backup (use: make restore-db BACKUP=filename)
	@echo "Restoring database from $(BACKUP_DIR)/$(BACKUP)..."
	@docker exec -i backend_postgres psql -U dice_user -d dice_db < $(BACKUP_DIR)/$(BACKUP)
	@echo "✅ Database restored from $(BACKUP)!"

status: ## Show service status
	@echo "DICE Services Status:"
	@$(ORCHESTRATOR_SCRIPT) status

health: ## Check service health
	@echo "Checking service health..."
	@docker exec backend_postgres pg_isready -U dice_user -d dice_db || echo "❌ PostgreSQL not ready"
	@docker exec backend_redis redis-cli ping || echo "❌ Redis not ready"
	@curl -f http://localhost:3001/health || echo "❌ Backend API not ready"
	@curl -f http://localhost:3000/ || echo "❌ PWA not ready"
	@echo "✅ Health checks completed!"

health-backend: ## Check backend service health only
	@echo "Checking backend service health..."
	@docker exec backend_postgres pg_isready -U dice_user -d dice_db || echo "❌ PostgreSQL not ready"
	@docker exec backend_redis redis-cli ping || echo "❌ Redis not ready"
	@curl -f http://localhost:3001/health || echo "❌ Backend API not ready"
	@echo "✅ Backend health checks completed!"

health-frontend: ## Check frontend service health only
	@echo "Checking frontend service health..."
	@curl -f http://localhost:3000/ || echo "❌ PWA not ready"
	@curl -f http://localhost:6006/ || echo "❌ Storybook not ready"
	@echo "✅ Frontend health checks completed!"

# Phase-specific targets
phase1: setup start-backend start-frontend ## Complete Phase 1 setup
	@echo "🎯 Phase 1 implementation in progress!"
	@echo "📝 Run 'make health' to verify services"

phase1-full: setup start-all ## Complete Phase 1 setup with full stack
	@echo "🎯 Phase 1 full stack implementation in progress!"
	@echo "📝 Run 'make health' to verify all services"

# Development convenience targets
dev-backend: start-backend logs-backend ## Start backend and show logs
	@echo "🔧 Backend development mode active"

dev-frontend: start-frontend logs-pwa ## Start frontend and show logs
	@echo "🎨 Frontend development mode active"

dev-full: start-all logs ## Start full stack and show logs
	@echo "🚀 Full stack development mode active" 