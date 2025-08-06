# DICE Development Environment - Service Management
.PHONY: help setup start stop restart clean logs test backup restore status health

# Default target
.DEFAULT_GOAL := help

# Variables
ORCHESTRATOR_SCRIPT := ./infrastructure/scripts/docker-orchestrator.sh
BACKUP_DIR := ./infrastructure/data/backups
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

# =============================================================================
# HELP & SETUP
# =============================================================================

help: ## Show this help message
	@echo "DICE Development Environment Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Initial setup of development environment
	@echo "Setting up DICE development environment..."
	@./infrastructure/scripts/setup-environment.sh --type development
	@echo "✅ Setup complete!"

setup-devcontainer: ## Setup DevContainer environment
	@echo "Setting up DevContainer environment..."
	@./infrastructure/scripts/setup-devcontainer.sh
	@echo "✅ DevContainer setup complete!"

# =============================================================================
# SERVICE STARTUP (Production Mode)
# =============================================================================

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

# =============================================================================
# SERVICE STARTUP WITH PROFILES
# =============================================================================

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

# =============================================================================
# DEVELOPMENT MODE (Debug Enabled)
# =============================================================================

dev-backend: ## Start backend in debug mode with logs
	@echo "🔧 Starting backend in DEBUG mode..."
	@echo "🐛 Debug port: localhost:9229"
	@$(ORCHESTRATOR_SCRIPT) backend-only
	@echo "📊 Backend logs (debug mode):"
	@$(ORCHESTRATOR_SCRIPT) logs backend
	@echo "🔧 Backend development mode active"

dev-frontend: ## Start frontend in debug mode with logs
	@echo "🎨 Starting frontend in DEBUG mode..."
	@echo "🐛 DevTools: localhost:3000 (F12)"
	@echo "🐛 Chrome Debug: localhost:9222"
	@$(ORCHESTRATOR_SCRIPT) pwa-only
	@echo "📊 Frontend logs (debug mode):"
	@$(ORCHESTRATOR_SCRIPT) logs pwa
	@echo "🎨 Frontend development mode active"

dev-full: ## Start full stack in debug mode with logs
	@echo "🚀 Starting full stack in DEBUG mode..."
	@echo "🐛 Backend debug: localhost:9229"
	@echo "🐛 Frontend debug: localhost:3000 (F12)"
	@echo "🐛 Chrome Debug: localhost:9222"
	@$(ORCHESTRATOR_SCRIPT) full-stack
	@echo "📊 Full stack logs (debug mode):"
	@$(ORCHESTRATOR_SCRIPT) logs
	@echo "🚀 Full stack development mode active"

dev-full-debug: ## Start full stack with all debug features
	@echo "🚀 Starting full stack with ALL debug features..."
	@echo "🐛 Backend debug: localhost:9229"
	@echo "🐛 Frontend debug: localhost:3000 (F12)"
	@echo "🐛 Chrome Debug: localhost:9222"
	@echo "📊 ELK logging: localhost:5601"
	@echo "🔍 Elasticsearch: localhost:9200"
	@$(ORCHESTRATOR_SCRIPT) full-stack --logging
	@echo "📊 Full stack logs with ELK:"
	@$(ORCHESTRATOR_SCRIPT) logs
	@echo "🚀 Full stack debug mode with logging active"

# =============================================================================
# ELK LOGGING STACK MANAGEMENT
# =============================================================================

start-elk: ## Start ELK logging stack only
	@echo "Starting ELK logging stack..."
	@docker-compose -f infrastructure/docker/logging-stack.yml --profile logging up -d
	@echo "✅ ELK stack started!"
	@echo "🌐 Access Kibana: http://localhost:5601"
	@echo "🔍 Access Elasticsearch: http://localhost:9200"

stop-elk: ## Stop ELK logging stack
	@echo "Stopping ELK logging stack..."
	@docker-compose -f infrastructure/docker/logging-stack.yml --profile logging down
	@echo "✅ ELK stack stopped!"

status-elk: ## Show ELK stack status
	@echo "ELK Stack Status:"
	@docker-compose -f infrastructure/docker/logging-stack.yml --profile logging ps

# =============================================================================
# SERVICE MANAGEMENT
# =============================================================================

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

# =============================================================================
# LOGGING & MONITORING
# =============================================================================

logs: ## Show logs for all services
	@$(ORCHESTRATOR_SCRIPT) logs

logs-backend: ## Show backend logs
	@$(ORCHESTRATOR_SCRIPT) logs backend

logs-pwa: ## Show PWA logs
	@$(ORCHESTRATOR_SCRIPT) logs pwa

logs-frontend: ## Show frontend logs (PWA + Storybook)
	@echo "📱 Frontend logs (PWA + Storybook):"
	@echo "🔹 PWA logs:"
	@$(ORCHESTRATOR_SCRIPT) logs pwa
	@echo ""
	@echo "🔹 Storybook logs:"
	@docker logs pwa_dev 2>/dev/null | grep -i storybook || echo "Storybook not running"

logs-temporal: ## Show Temporal logs
	@docker logs backend_temporal_dev -f

logs-elk: ## Show ELK stack logs (Elasticsearch, Kibana, Fluent Bit)
	@echo "📊 ELK Stack logs:"
	@echo "🔹 Elasticsearch logs:"
	@docker logs dice_elasticsearch 2>/dev/null || echo "Elasticsearch not running"
	@echo ""
	@echo "🔹 Kibana logs:"
	@docker logs dice_kibana 2>/dev/null || echo "Kibana not running"
	@echo ""
	@echo "🔹 Fluent Bit logs:"
	@docker logs dice_fluent_bit 2>/dev/null || echo "Fluent Bit not running"

logs-database: ## Show database logs (PostgreSQL + Redis)
	@echo "🗄️ Database logs:"
	@echo "🔹 PostgreSQL logs:"
	@docker logs backend_postgres_dev 2>/dev/null || echo "PostgreSQL not running"
	@echo ""
	@echo "🔹 Redis logs:"
	@docker logs backend_redis_dev 2>/dev/null || echo "Redis not running"

logs-aws: ## Show LocalStack AWS logs
	@echo "☁️ LocalStack AWS logs:"
	@docker logs backend_localstack_dev 2>/dev/null || echo "LocalStack not running"

logs-proxy: ## Show Traefik proxy logs
	@echo "🌐 Traefik proxy logs:"
	@docker logs dice_traefik_orchestrated 2>/dev/null || echo "Traefik not running"

logs-all: ## Show all service logs
	@echo "📋 All DICE service logs:"
	@echo "🔹 Backend services:"
	@$(ORCHESTRATOR_SCRIPT) logs backend
	@echo ""
	@echo "🔹 Frontend services:"
	@$(ORCHESTRATOR_SCRIPT) logs pwa
	@echo ""
	@echo "🔹 Database services:"
	@docker logs backend_postgres_dev 2>/dev/null || echo "PostgreSQL not running"
	@docker logs backend_redis_dev 2>/dev/null || echo "Redis not running"
	@echo ""
	@echo "🔹 ELK Stack (if running):"
	@docker logs dice_elasticsearch 2>/dev/null || echo "Elasticsearch not running"
	@docker logs dice_kibana 2>/dev/null || echo "Kibana not running"

# =============================================================================
# LOGGING MONITORING & TESTING
# =============================================================================

monitor-logs: ## Monitor logs in real-time using logging scripts
	@echo "📊 Real-time log monitoring:"
	@./infrastructure/scripts/logging-monitor.sh

monitor-logs-security: ## Monitor security events only
	@echo "🔒 Security event monitoring:"
	@./infrastructure/scripts/logging-monitor.sh --security --follow

monitor-logs-performance: ## Monitor performance metrics only
	@echo "⚡ Performance monitoring:"
	@./infrastructure/scripts/logging-monitor.sh --performance --follow

test-logging: ## Test logging pipeline and generate sample logs
	@echo "🧪 Testing logging pipeline:"
	@./infrastructure/scripts/logging-test.sh

setup-logging: ## Setup and configure ELK stack
	@echo "🔧 Setting up ELK logging stack:"
	@./infrastructure/scripts/logging-setup.sh

export-logs: ## Export recent logs from Elasticsearch
	@echo "📤 Exporting recent logs:"
	@./infrastructure/scripts/logging-setup.sh export

# =============================================================================
# TESTING & VALIDATION
# =============================================================================

test: ## Run all tests (when services are implemented)
	@echo "Running all tests..."
	@echo "⚠️  Tests will be implemented in service setup phase"

test-auth: ## Test JWT authentication system
	@echo "🔐 Testing authentication system..."
	@./infrastructure/scripts/test-auth.sh

test-validation: ## Run comprehensive validation
	@echo "🧪 Running comprehensive validation..."
	@./infrastructure/scripts/unified-validation.sh

test-localstack: ## Test LocalStack AWS services
	@echo "☁️ Testing LocalStack AWS services..."
	@./infrastructure/scripts/setup-localstack.sh

# =============================================================================
# HEALTH & STATUS
# =============================================================================

status: ## Show service status
	@echo "DICE Services Status:"
	@$(ORCHESTRATOR_SCRIPT) status

health: ## Check service health
	@echo "Checking service health..."
	@docker exec backend_postgres_dev pg_isready -U dice_user -d dice_db || echo "❌ PostgreSQL not ready"
	@docker exec backend_redis_dev redis-cli ping || echo "❌ Redis not ready"
	@curl -f http://localhost:3001/health || echo "❌ Backend API not ready"
	@curl -f http://localhost:3000/ || echo "❌ PWA not ready"
	@echo "✅ Health checks completed!"

health-backend: ## Check backend service health only
	@echo "Checking backend service health..."
	@docker exec backend_postgres_dev pg_isready -U dice_user -d dice_db || echo "❌ PostgreSQL not ready"
	@docker exec backend_redis_dev redis-cli ping || echo "❌ Redis not ready"
	@curl -f http://localhost:3001/health || echo "❌ Backend API not ready"
	@echo "✅ Backend health checks completed!"

health-frontend: ## Check frontend service health only
	@echo "Checking frontend service health..."
	@curl -f http://localhost:3000/ || echo "❌ PWA not ready"
	@curl -f http://localhost:6006/ || echo "❌ Storybook not ready"
	@echo "✅ Frontend health checks completed!"

health-elk: ## Check ELK stack health
	@echo "Checking ELK stack health..."
	@curl -f http://localhost:9200/_cluster/health || echo "❌ Elasticsearch not ready"
	@curl -f http://localhost:5601/api/status || echo "❌ Kibana not ready"
	@curl -f http://localhost:2020/api/v1/health || echo "❌ Fluent Bit not ready"
	@echo "✅ ELK stack health checks completed!"

# =============================================================================
# DATABASE MANAGEMENT
# =============================================================================

backup-db: ## Backup PostgreSQL database
	@echo "Creating database backup..."
	@mkdir -p $(BACKUP_DIR)
	@docker exec backend_postgres_dev pg_dump -U dice_user dice_db > $(BACKUP_DIR)/backup_$(TIMESTAMP).sql
	@echo "✅ Database backed up to $(BACKUP_DIR)/backup_$(TIMESTAMP).sql"

restore-db: ## Restore database from backup (use: make restore-db BACKUP=filename)
	@echo "Restoring database from $(BACKUP_DIR)/$(BACKUP)..."
	@docker exec -i backend_postgres_dev psql -U dice_user -d dice_db < $(BACKUP_DIR)/$(BACKUP)
	@echo "✅ Database restored from $(BACKUP)!"

# =============================================================================
# DEVELOPMENT WORKFLOWS
# =============================================================================

# Phase-specific targets
phase1: setup start-backend start-frontend ## Complete Phase 1 setup
	@echo "🎯 Phase 1 implementation in progress!"
	@echo "📝 Run 'make health' to verify services"

phase1-full: setup start-all ## Complete Phase 1 setup with full stack
	@echo "🎯 Phase 1 full stack implementation in progress!"
	@echo "📝 Run 'make health' to verify all services"

# =============================================================================
# UTILITY TARGETS
# =============================================================================

debug-backend: ## Start backend in debug mode (legacy target)
	@echo "Starting backend in debug mode..."
	@echo "🐛 Backend debug mode - connect to localhost:9229"
	@cd workspace/backend && docker compose --env-file ../../.env up -d backend

validate: ## Validate all infrastructure and configuration
	@echo "🔍 Validating infrastructure..."
	@./infrastructure/scripts/unified-validation.sh

setup-aws: ## Setup LocalStack with sample D&D data
	@echo "☁️ Setting up LocalStack with sample data..."
	@./infrastructure/scripts/setup-localstack.sh

setup-devcontainer: ## Setup DevContainer environment
	@echo "🔧 Setting up DevContainer environment..."
	@./infrastructure/scripts/setup-devcontainer.sh

# =============================================================================
# QUICK ACCESS TARGETS
# =============================================================================

quick-start: setup start-all health ## Quick start with setup, start, and health check
	@echo "🚀 Quick start complete!"

quick-dev: setup dev-full health ## Quick development start with debug mode
	@echo "🔧 Quick development start complete!"

quick-logging: start-elk setup-logging health-elk ## Quick logging setup
	@echo "📊 Quick logging setup complete!"

# =============================================================================
# CLEANUP TARGETS
# =============================================================================

clean-all: clean ## Clean all including ELK stack
	@echo "Cleaning ELK stack..."
	@docker-compose -f infrastructure/docker/logging-stack.yml --profile logging down -v 2>/dev/null || true
	@echo "✅ All services and data cleaned!"

clean-logs: ## Clean log data only
	@echo "Cleaning log data..."
	@docker-compose -f infrastructure/docker/logging-stack.yml --profile logging down -v 2>/dev/null || true
	@echo "✅ Log data cleaned!" 