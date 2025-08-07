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
	@$(SERVICE_MANAGER) start orchestrator --proxy
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
# SERVICE STARTUP (Legacy Redirects)
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
# DEVELOPMENT MODE
# =============================================================================

dev-backend: ## Start backend in development mode with debug logging
	@echo "🔧 Starting backend in DEBUG mode..."
	@echo "🐛 Debug port: localhost:9229"
	@$(SERVICE_MANAGER) start backend
	@echo "📊 Backend logs (debug mode):"
	@$(SERVICE_MANAGER) logs backend
	@echo "🔧 Backend development mode active"

dev-frontend: ## Start PWA frontend in development mode with hot reload
	@echo "🎨 Starting PWA frontend in DEBUG mode..."
	@echo "🐛 DevTools: localhost:3000 (F12)"
	@echo "🐛 Chrome Debug: localhost:9222"
	@$(SERVICE_MANAGER) start pwa
	@echo "📊 Frontend logs (debug mode):"
	@$(SERVICE_MANAGER) logs pwa
	@echo "🎨 Frontend development mode active"

dev-full: ## Start full stack in development mode
	@echo "🚀 Starting full stack in DEBUG mode..."
	@echo "🐛 Backend debug: localhost:9229"
	@echo "🐛 Frontend debug: localhost:3000 (F12)"
	@echo "🐛 Chrome Debug: localhost:9222"
	@$(SERVICE_MANAGER) start orchestrator
	@echo "📊 Full stack logs (debug mode):"
	@$(SERVICE_MANAGER) logs all
	@echo "🚀 Full stack development mode active"

dev-full-debug: ## Start full stack in development mode with ELK logging
	@echo "🚀 Starting full stack in DEBUG mode with logging..."
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
# SERVICE MANAGEMENT (Legacy Redirects)
# =============================================================================

stop: service-stop ## Stop all services (legacy redirect)
restart: service-restart ## Restart all services (legacy redirect)
clean: service-clean ## Clean all containers and volumes (legacy redirect)
logs: service-logs ## Show logs for all services (legacy redirect)
status: service-status ## Show status of all services (legacy redirect)
health: service-health ## Health check all services (legacy redirect)

# =============================================================================
# TESTING & VALIDATION (Legacy Redirects)
# =============================================================================

test-auth: validate-security ## Test authentication system (legacy redirect)
test-validation: validate-all ## Run all validation tests (legacy redirect)
validate: validate-all ## Run all validation tests (legacy redirect)

# =============================================================================
# DATABASE MANAGEMENT (Legacy Redirects)
# =============================================================================

backup-db: service-backup ## Backup PostgreSQL database (legacy redirect)

# =============================================================================
# LOGS & MONITORING
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
	@docker compose -f workspace/pwa/docker-compose.yml logs storybook

logs-all: ## Show all service logs
	@echo "📋 All DICE service logs:"
	@echo "🔹 Backend services:"
	@$(SERVICE_MANAGER) logs backend
	@echo ""
	@echo "🔹 Frontend services:"
	@$(SERVICE_MANAGER) logs pwa
	@echo ""
	@echo "🔹 Database services:"
	@docker compose -f workspace/backend/docker-compose.yml logs postgres redis

# =============================================================================
# DATABASE MANAGEMENT
# =============================================================================

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

quick-start: setup start-all ## Quick start: setup + start all services
	@echo "🚀 DICE development environment ready!"
	@echo "🌐 Access your services:"
	@echo "   Backend API: http://localhost:3001"
	@echo "   PWA Frontend: http://localhost:3000"
	@echo "   Storybook: http://localhost:6006"
	@echo "   Temporal UI: http://localhost:8088"

quick-stop: stop ## Quick stop: stop all services
	@echo "🛑 All services stopped!"

quick-restart: restart ## Quick restart: restart all services
	@echo "🔄 All services restarted!"

quick-clean: clean ## Quick clean: clean all containers and volumes
	@echo "🧹 All containers and volumes cleaned!"

quick-logs: logs ## Quick logs: show all service logs
	@echo "📋 All service logs displayed!"

quick-status: status ## Quick status: show all service status
	@echo "📊 All service status displayed!"

quick-health: health ## Quick health: health check all services
	@echo "🏥 All service health checks completed!"

# =============================================================================
# DEVELOPMENT WORKFLOWS
# =============================================================================

dev-start: ## Start development environment
	@$(SERVICE_MANAGER) start orchestrator --proxy --logging
	@echo "🚀 Development environment started!"

dev-stop: ## Stop development environment
	@$(SERVICE_MANAGER) stop all
	@echo "🛑 Development environment stopped!"

dev-monitor: ## Start development environment with monitoring
	@$(SERVICE_MANAGER) start orchestrator --proxy --monitoring
	@echo "🚀 Development environment with monitoring started!"

dev-full-stack: ## Start full development stack
	@$(SERVICE_MANAGER) start orchestrator --proxy --logging --monitoring
	@echo "🚀 Full development stack started!"

# =============================================================================
# TESTING & VALIDATION WORKFLOWS
# =============================================================================

test-all: ## Run all tests and validations
	@$(VALIDATION_FRAMEWORK) --all
	@$(DASHBOARD_TESTER) --all
	@echo "✅ All tests and validations completed!"

test-infrastructure: ## Test infrastructure only
	@$(VALIDATION_FRAMEWORK) --phase infrastructure
	@echo "✅ Infrastructure tests completed!"

test-services: ## Test services only
	@$(VALIDATION_FRAMEWORK) --phase services
	@echo "✅ Service tests completed!"

test-security: ## Test security only
	@$(VALIDATION_FRAMEWORK) --phase security
	@echo "✅ Security tests completed!"

test-logging: ## Test logging only
	@$(VALIDATION_FRAMEWORK) --phase logging
	@echo "✅ Logging tests completed!"

test-performance: ## Test performance only
	@$(VALIDATION_FRAMEWORK) --phase performance
	@echo "✅ Performance tests completed!"

test-integration: ## Test integration only
	@$(VALIDATION_FRAMEWORK) --phase integration
	@echo "✅ Integration tests completed!"

test-dashboards: ## Test all dashboards
	@$(DASHBOARD_TESTER) --all
	@echo "✅ Dashboard tests completed!"

# =============================================================================
# DASHBOARD TESTING WORKFLOWS
# =============================================================================

test-dashboard-security: ## Test security dashboard
	@$(DASHBOARD_TESTER) --dashboard security
	@echo "✅ Security dashboard tests completed!"

test-dashboard-performance: ## Test performance dashboard
	@$(DASHBOARD_TESTER) --dashboard performance
	@echo "✅ Performance dashboard tests completed!"

test-dashboard-health: ## Test health dashboard
	@$(DASHBOARD_TESTER) --dashboard health
	@echo "✅ Health dashboard tests completed!"

test-dashboard-user-activity: ## Test user activity dashboard
	@$(DASHBOARD_TESTER) --dashboard user-activity
	@echo "✅ User activity dashboard tests completed!"

test-dashboard-operational-overview: ## Test operational overview dashboard
	@$(DASHBOARD_TESTER) --dashboard operational-overview
	@echo "✅ Operational overview dashboard tests completed!"

# =============================================================================
# UTILITY TARGETS
# =============================================================================

debug-backend: ## Start backend in debug mode (legacy)
	@echo "🔧 Starting backend in DEBUG mode..."
	@echo "🐛 Debug port: localhost:9229"
	@$(SERVICE_MANAGER) start backend
	@echo "📊 Backend logs (debug mode):"
	@$(SERVICE_MANAGER) logs backend
	@echo "🔧 Backend development mode active"

# =============================================================================
# COMMON WORKFLOWS
# =============================================================================

# Development workflow
dev-workflow: setup dev-start ## Complete development workflow
	@echo "🚀 Development workflow completed!"
	@echo "🌐 Access your services:"
	@echo "   Backend API: http://localhost:3001"
	@echo "   PWA Frontend: http://localhost:3000"
	@echo "   Storybook: http://localhost:6006"
	@echo "   Temporal UI: http://localhost:8088"

# Testing workflow
test-workflow: test-all ## Complete testing workflow
	@echo "✅ Testing workflow completed!"

# Production workflow
prod-workflow: setup start-all ## Complete production workflow
	@echo "🚀 Production workflow completed!"
	@echo "🌐 Access your services:"
	@echo "   Backend API: http://localhost:3001"
	@echo "   PWA Frontend: http://localhost:3000"
	@echo "   Storybook: http://localhost:6006"
	@echo "   Temporal UI: http://localhost:8088"

# =============================================================================
# HEALTH CHECK WORKFLOWS
# =============================================================================

health-check: ## Comprehensive health check
	@$(SERVICE_MANAGER) health all
	@echo "🏥 Health check completed!"

health-backend: ## Backend health check
	@$(SERVICE_MANAGER) health backend
	@echo "🏥 Backend health check completed!"

health-frontend: ## Frontend health check
	@$(SERVICE_MANAGER) health pwa
	@echo "🏥 Frontend health check completed!"

health-all: ## All services health check
	@$(SERVICE_MANAGER) health all
	@echo "🏥 All services health check completed!"

# =============================================================================
# BACKUP & RESTORE WORKFLOWS
# =============================================================================

backup-all: ## Create comprehensive backup
	@$(SERVICE_MANAGER) backup
	@echo "💾 Comprehensive backup completed!"

restore-all: ## Restore from backup
	@echo "📥 Restoring from backup..."
	@echo "Enter backup filename:"
	@read backup_file; \
	if [ -n "$$backup_file" ]; then \
		$(SERVICE_MANAGER) restore "$$backup_file"; \
		echo "✅ Restore completed!"; \
	else \
		echo "❌ No backup file specified"; \
	fi

# =============================================================================
# CLEANUP WORKFLOWS
# =============================================================================

cleanup-all: ## Complete cleanup
	@$(SERVICE_MANAGER) clean
	@echo "🧹 Complete cleanup completed!"

cleanup-containers: ## Clean containers only
	@docker container prune -f
	@echo "🧹 Container cleanup completed!"

cleanup-volumes: ## Clean volumes only
	@docker volume prune -f
	@echo "🧹 Volume cleanup completed!"

cleanup-images: ## Clean images only
	@docker image prune -f
	@echo "🧹 Image cleanup completed!"

# =============================================================================
# MONITORING WORKFLOWS
# =============================================================================

monitor-all: ## Monitor all services
	@$(SERVICE_MANAGER) status all
	@$(SERVICE_MANAGER) health all
	@echo "📊 Monitoring completed!"

monitor-backend: ## Monitor backend services
	@$(SERVICE_MANAGER) status backend
	@$(SERVICE_MANAGER) health backend
	@echo "📊 Backend monitoring completed!"

monitor-frontend: ## Monitor frontend services
	@$(SERVICE_MANAGER) status pwa
	@$(SERVICE_MANAGER) health pwa
	@echo "📊 Frontend monitoring completed!"

# =============================================================================
# RESULT
# =============================================================================

# Enhanced database management with interactive restore
# Unified service management with comprehensive workflows
# Complete testing and validation framework
# Enhanced monitoring and health check capabilities 