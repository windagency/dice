# DICE Development Environment - Service Management
.PHONY: help setup start stop restart clean logs test backup restore status health

# Default target
.DEFAULT_GOAL := help

# Variables
SERVICE_MANAGER := ./infrastructure/scripts/unified-service-manager.sh
VALIDATION_FRAMEWORK := ./infrastructure/scripts/unified-validation-framework.sh
DASHBOARD_TESTER := ./infrastructure/scripts/dashboard-test-framework.sh
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

setup-localstack: ## Setup LocalStack AWS services emulator
	@echo "Setting up LocalStack AWS services emulator..."
	@./infrastructure/scripts/setup-localstack.sh
	@echo "✅ LocalStack AWS services emulator setup complete!"

# =============================================================================
# SERVICE STARTUP (Production Mode)
# =============================================================================

start-all: ## Start full integrated stack with all services
	@echo "Starting full DICE integrated stack..."
	@$(SERVICE_MANAGER) start orchestrator
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
	@$(SERVICE_MANAGER) start backend
	@echo "✅ Backend services started!"

start-frontend: ## Start PWA frontend with development mocks
	@echo "Starting PWA frontend with development mocks..."
	@$(SERVICE_MANAGER) start pwa
	@echo "✅ PWA frontend started!"

# =============================================================================
# UNIFIED SERVICE MANAGEMENT
# =============================================================================

# Unified service management commands
service-start: ## Start all services using unified service manager
	@$(SERVICE_MANAGER) start all

service-stop: ## Stop all services using unified service manager
	@$(SERVICE_MANAGER) stop all

service-restart: ## Restart all services using unified service manager
	@$(SERVICE_MANAGER) restart all

service-status: ## Show status of all services using unified service manager
	@$(SERVICE_MANAGER) status all

service-health: ## Health check all services using unified service manager
	@$(SERVICE_MANAGER) health all

service-logs: ## Show logs for all services using unified service manager
	@$(SERVICE_MANAGER) logs all

service-clean: ## Clean all containers and volumes using unified service manager
	@$(SERVICE_MANAGER) clean

service-backup: ## Create backup using unified service manager
	@$(SERVICE_MANAGER) backup

# =============================================================================
# UNIFIED VALIDATION
# =============================================================================

validate-all: ## Run all validation phases using unified validation framework
	@$(VALIDATION_FRAMEWORK) --all

validate-infrastructure: ## Validate infrastructure using unified validation framework
	@$(VALIDATION_FRAMEWORK) --phase infrastructure

validate-services: ## Validate services using unified validation framework
	@$(VALIDATION_FRAMEWORK) --phase services

validate-security: ## Validate security using unified validation framework
	@$(VALIDATION_FRAMEWORK) --phase security

validate-logging: ## Validate logging using unified validation framework
	@$(VALIDATION_FRAMEWORK) --phase logging

validate-performance: ## Validate performance using unified validation framework
	@$(VALIDATION_FRAMEWORK) --phase performance

validate-integration: ## Validate integration using unified validation framework
	@$(VALIDATION_FRAMEWORK) --phase integration

# =============================================================================
# UNIFIED DASHBOARD TESTING
# =============================================================================

test-dashboards-all: ## Test all dashboards using unified dashboard testing framework
	@$(DASHBOARD_TESTER) --all

test-dashboard-security: ## Test security dashboard using unified dashboard testing framework
	@$(DASHBOARD_TESTER) --type security

test-dashboard-performance: ## Test performance dashboard using unified dashboard testing framework
	@$(DASHBOARD_TESTER) --type performance

test-dashboard-health: ## Test health dashboard using unified dashboard testing framework
	@$(DASHBOARD_TESTER) --type health

test-dashboard-user-activity: ## Test user activity dashboard using unified dashboard testing framework
	@$(DASHBOARD_TESTER) --type user-activity

test-dashboard-operational: ## Test operational dashboard using unified dashboard testing framework
	@$(DASHBOARD_TESTER) --type operational

# =============================================================================
# SERVICE STARTUP WITH PROFILES
# =============================================================================

start-proxy: ## Start full stack with Traefik reverse proxy
	@echo "Starting full stack with reverse proxy..."
	@$(SERVICE_MANAGER) start orchestrator --proxy
	@echo "✅ Full stack with proxy started!"

start-monitoring: ## Start full stack with monitoring (Prometheus + Grafana)
	@echo "Starting full stack with monitoring..."
	@$(SERVICE_MANAGER) start orchestrator --monitoring
	@echo "✅ Full stack with monitoring started!"

start-logging: ## Start full stack with ELK logging stack
	@echo "Starting full stack with logging..."
	@$(SERVICE_MANAGER) start elk
	@echo "✅ ELK logging stack started!"

start-aws: ## Start full stack with LocalStack AWS services
	@echo "Starting full stack with AWS services..."
	@$(SERVICE_MANAGER) start orchestrator --aws
	@echo "✅ Full stack with AWS services started!"

# =============================================================================
# DEVELOPMENT MODE (Debug Enabled)
# =============================================================================

dev-backend: ## Start backend in debug mode with logs
	@echo "🔧 Starting backend in DEBUG mode..."
	@echo "🐛 Debug port: localhost:9229"
	@$(SERVICE_MANAGER) start backend
	@echo "📊 Backend logs (debug mode):"
	@$(SERVICE_MANAGER) logs backend
	@echo "🔧 Backend development mode active"

dev-frontend: ## Start frontend in debug mode with logs
	@echo "🎨 Starting frontend in DEBUG mode..."
	@echo "🐛 DevTools: localhost:3000 (F12)"
	@echo "🐛 Chrome Debug: localhost:9222"
	@$(SERVICE_MANAGER) start pwa
	@echo "📊 Frontend logs (debug mode):"
	@$(SERVICE_MANAGER) logs pwa
	@echo "🎨 Frontend development mode active"

dev-full: ## Start full stack in debug mode with logs
	@echo "🚀 Starting full stack in DEBUG mode..."
	@echo "🐛 Backend debug: localhost:9229"
	@echo "🐛 Frontend debug: localhost:3000 (F12)"
	@echo "🐛 Chrome Debug: localhost:9222"
	@$(SERVICE_MANAGER) start orchestrator
	@echo "📊 Full stack logs (debug mode):"
	@$(SERVICE_MANAGER) logs all
	@echo "🚀 Full stack development mode active"

dev-full-debug: ## Start full stack with all debug features
	@echo "🚀 Starting full stack with ALL debug features..."
	@echo "🐛 Backend debug: localhost:9229"
	@echo "🐛 Frontend debug: localhost:3000 (F12)"
	@echo "🐛 Chrome Debug: localhost:9222"
	@echo "📊 ELK logging: localhost:5601"
	@echo "🔍 Elasticsearch: localhost:9200"
	@$(SERVICE_MANAGER) start orchestrator --logging
	@echo "📊 Full stack logs with ELK:"
	@$(SERVICE_MANAGER) logs all
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
# LOGGING & MONITORING (Unified)
# =============================================================================

logs-backend: ## Show backend logs
	@$(SERVICE_MANAGER) logs backend

logs-pwa: ## Show PWA logs
	@$(SERVICE_MANAGER) logs pwa

logs-frontend: ## Show frontend logs (PWA + Storybook)
	@echo "📱 Frontend logs (PWA + Storybook):"
	@echo "🔹 PWA logs:"
	@$(SERVICE_MANAGER) logs pwa
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
	@$(SERVICE_MANAGER) logs backend
	@echo ""
	@echo "🔹 Frontend services:"
	@$(SERVICE_MANAGER) logs pwa
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
# HEALTH & STATUS (Unified)
# =============================================================================

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

restore-db: ## Restore database from backup (use: make restore-db BACKUP=filename or make restore-db for interactive)
	@if [ -n "$(BACKUP)" ] && [ -f "$(BACKUP_DIR)/$(BACKUP)" ]; then \
		echo "Restoring database from $(BACKUP_DIR)/$(BACKUP)..."; \
		docker exec -i backend_postgres_dev psql -U dice_user -d dice_db < "$(BACKUP_DIR)/$(BACKUP)"; \
		echo "✅ Database restored from $(BACKUP)!"; \
	else \
		echo "📋 Available backups:"; \
		ls -la $(BACKUP_DIR)/*.sql 2>/dev/null || echo "❌ No backup files found in $(BACKUP_DIR)"; \
		echo ""; \
		echo "🔍 Interactive mode:"; \
		echo "Enter backup filename (or press Enter to cancel):"; \
		read backup_file; \
		if [ -z "$$backup_file" ]; then \
			echo "❌ Restore cancelled"; \
			exit 0; \
		fi; \
		if [ ! -f "$(BACKUP_DIR)/$$backup_file" ]; then \
			echo "❌ Error: Backup file $(BACKUP_DIR)/$$backup_file not found"; \
			exit 1; \
		fi; \
		echo "🔄 Restoring database from $(BACKUP_DIR)/$$backup_file..."; \
		docker exec -i backend_postgres_dev psql -U dice_user -d dice_db < "$(BACKUP_DIR)/$$backup_file"; \
		echo "✅ Database restored from $$backup_file!"; \
	fi



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