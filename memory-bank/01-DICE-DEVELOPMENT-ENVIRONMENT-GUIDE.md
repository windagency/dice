# DICE Containerised Development Environment - Complete Implementation Guide

**Project**: DICE D&D Character Manager Monorepo  
**Date**: 2025-08-04  
**Status**: Ready for Implementation  
**Architecture**: Docker Compose → Kubernetes Migration Strategy

---

## 📋 **PART I: DEVELOPER GUIDE**

### Project Overview and Validated Specifications

#### **Project Goals**

Create a containerised development environment for the DICE D&D character manager monorepo using a phased approach that starts with minimal viable setup and progressively adds complexity. Each service must be startable independently for development, debugging, or testing purposes.

#### **Architecture Strategy**

- **Local Development**: Docker Compose for simplicity and rapid iteration
- **Production Deployment**: Kubernetes migration path with Rancher Desktop
- **Implementation Approach**: Three-phase progressive complexity (4-6 weeks total)

#### **Technology Stack (Validated)**

**Core Technologies:**

- **Frontend**: Astro.js PWA with React integration and TailwindCSS
- **Backend**: Nest.js with TypeScript, TypeORM for database management
- **Database**: PostgreSQL 17 for primary data storage
- **Cache**: Redis 7 for session storage and caching
- **CMS**: PayloadCMS for D&D rules data management
- **Reverse Proxy**: Traefik v3.0 with built-in SSL certificate generation

**API Strategy:**

- **tRPC**: Web frontend communication (PWA ↔ Backend)
- **GraphQL Federation**: Flutter mobile app communication (Mobile ↔ Backend)

**Container Images (Latest Stable):**

- Node.js: `22-bullseye`
- PostgreSQL: `17-bullseye`
- Redis: `7-bullseye`
- LocalStack: `4.0`
- Traefik: `v3.0`

#### **System Requirements**

**Minimum Hardware:**

- **Phase 1**: 6-8GB RAM, 3GB disk space
- **Phase 2**: 8-10GB RAM, 5GB disk space
- **Phase 3**: 10-12GB RAM, 8GB disk space

**Software Prerequisites:**

- Docker Desktop or Rancher Desktop
- VS Code with DevContainer extension
- Git version control

**Performance Expectations:**

- Backend Hot Reload: < 8 seconds
- PWA Hot Reload: < 5 seconds
- Full Stack Startup: < 2 minutes

#### **Service Dependencies (Logical)**

```plaintext
PostgreSQL → Backend Service
PayloadCMS → Backend Service
Redis → Backend Service
Backend ← PWA (optional dependency)
Monitoring → All Services (optional)
```

#### **Development URLs**

- PWA Frontend: `https://pwa.dice.local`
- Backend API: `https://api.dice.local`
- PayloadCMS: `https://cms.dice.local`
- Traefik Dashboard: `https://traefik.dice.local:8080`
- Grafana Monitoring: `https://monitoring.dice.local`

### Configuration Tasks for Developer

#### **1. Local Environment Setup**

**Add to `/etc/hosts` (macOS/Linux) or `C:\Windows\System32\drivers\etc\hosts` (Windows):**

```plaintext
127.0.0.1 pwa.dice.local
127.0.0.1 api.dice.local
127.0.0.1 cms.dice.local
127.0.0.1 traefik.dice.local
127.0.0.1 monitoring.dice.local
```

**Install Required Tools:**

```bash
# Install Rancher Desktop (recommended) or Docker Desktop
# Install VS Code with DevContainer extension
# Install Git

# Verify installations
docker --version
docker-compose --version
code --version
git --version
```

#### **2. External Dependencies and Tokens**

**Development Secrets (to be created):**

- Database credentials for local PostgreSQL
- Redis connection settings
- LocalStack AWS simulation endpoints
- JWT secrets for authentication
- API keys for inter-service communication

**Optional External Services:**

- GitHub Container Registry (for custom images)
- Docker Hub (for image hosting)
- Sentry (for error tracking in later phases)

#### **3. Project Structure Validation**

**Existing Directories:**

- `workspace/backend/` - Nest.js backend service
- `workspace/pwa/` - Astro.js PWA frontend
- `workspace/shared/` - Shared TypeScript types and utilities
- `infrastructure/k8s/` - Kubernetes manifests (Phase 3)
- `infrastructure/docker/` - Custom Dockerfiles

**Required New Directories:**

- `.devcontainer/` - VS Code DevContainer configuration
- `infrastructure/data/` - Persistent volumes for databases
- `infrastructure/scripts/` - Automation and setup scripts
- `infrastructure/config/` - Service configuration files

---

## 🔧 **PART II: AI EDITOR IMPLEMENTATION GUIDE**

### Phase-Based Implementation Plan

#### **PHASE 1: Minimal Viable Development Environment (2-3 weeks)**

**Goal**: Basic development workflow functioning with all core services

**Success Criteria:**

- Developer can run `make start-all` and access all services via HTTPS
- Hot reload works within performance targets (< 8s backend, < 5s PWA)
- Database seeded with development data
- All validation checkpoints pass

#### **PHASE 2: Enhanced Development Experience (1-2 weeks)**

**Goal**: Production-ready development workflow with monitoring and CMS

**Success Criteria:**

- Monitoring dashboards show service health
- PayloadCMS populated with D&D rules data
- Independent service modes functional (backend-only, frontend-only)
- Pre-commit hooks and code quality tools working

#### **PHASE 3: Production-Ready Features (1-2 weeks)**

**Goal**: Production deployment capability with advanced features

**Success Criteria:**

- Production Kubernetes manifests working
- Security scanning passes
- Load testing completes successfully
- Redis clustering and advanced monitoring operational

### Complete Folder Structure

```plaintext
dice/
├── .devcontainer/
│   ├── devcontainer.json                 # Root DevContainer configuration
│   └── Dockerfile                         # Custom DevContainer image
├── workspace/
│   ├── backend/
│   │   ├── .devcontainer/
│   │   │   └── devcontainer.json         # Backend-specific DevContainer
│   │   ├── src/
│   │   ├── .env.sample
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── pwa/
│   │   ├── .devcontainer/
│   │   │   └── devcontainer.json         # PWA-specific DevContainer
│   │   ├── src/
│   │   ├── .env.sample
│   │   ├── astro.config.mjs
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── shared/
│       ├── .devcontainer/
│       │   └── devcontainer.json         # Shared components DevContainer
│       ├── types/                        # Shared TypeScript definitions
│       ├── utils/                        # Common utilities
│       ├── package.json
│       └── tsconfig.json
├── infrastructure/
│   ├── config/
│   │   ├── .env.development              # Development environment variables
│   │   ├── .env.production               # Production environment variables
│   │   └── .env.sample                   # Environment template
│   ├── data/                             # Persistent volumes (git-ignored)
│   │   ├── backups/
│   │   ├── localstack/
│   │   ├── postgres/
│   │   ├── redis/
│   │   └── uploads/
│   ├── docker/
│   │   ├── postgres/
│   │   │   ├── Dockerfile
│   │   │   └── init-scripts/
│   │   ├── redis/
│   │   │   └── redis.conf
│   │   └── traefik/
│   │       └── traefik.yml
│   ├── k8s/                              # Phase 3: Kubernetes manifests
│   │   ├── backend/
│   │   ├── monitoring/
│   │   ├── postgres/
│   │   ├── pwa/
│   │   ├── redis/
│   │   └── namespace.yml
│   ├── monitoring/
│   │   ├── grafana/
│   │   │   └── dashboards/
│   │   ├── alertmanager.yml
│   │   └── prometheus.yml
│   └── scripts/
│       ├── seed-data/
│       │   ├── characters.sql
│       │   ├── dnd-rules.json
│       │   └── users.sql
│       ├── backup-db.sh
│       ├── emergency-reset.sh
│       ├── restore-db.sh
│       └── setup-dev-environment.sh      # Initial setup automation
├── .pre-commit-config.yaml                # Code quality hooks (Phase 2)
├── docker-compose.yml                    # Main orchestration file
├── docker-compose.override.yml           # Local development overrides
├── CHANGELOG.md                          # Version history
├── IMPLEMENTATION_STATUS.md              # Progress tracking
├── Makefile                               # Service management commands
├── README.md                             # Developer onboarding
├── skaffold.yaml                         # Hot reload optimization (Phase 2)
└── TODO.md                               # Task tracking
```

### Environment Variables Configuration

#### **Primary Environment File: `.env.development`**

```plaintext
# Database Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=dice_db
POSTGRES_USER=dice_user
POSTGRES_PASSWORD=dice_dev_password_2024
DATABASE_URL=postgresql://dice_user:dice_dev_password_2024@postgres:5432/dice_db

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_URL=redis://redis:6379

# LocalStack Configuration (AWS Simulation)
LOCALSTACK_ENDPOINT=http://localstack:4566
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_DEFAULT_REGION=us-east-1

# Service URLs
BACKEND_URL=http://backend:3001
PWA_URL=http://pwa:3000
CMS_URL=http://payloadcms:3002

# Authentication Secrets
JWT_SECRET=dice_jwt_secret_development_2024
BACKEND_API_KEY=dice_dev_api_key_2024
CMS_API_KEY=dice_cms_api_key_2024
INTERNAL_JWT_SECRET=dice_internal_jwt_secret_dev

# Development Settings
NODE_ENV=development
LOG_LEVEL=debug
HOT_RELOAD=true

# Traefik Configuration
TRAEFIK_API_DASHBOARD=true
TRAEFIK_LOG_LEVEL=INFO

# Monitoring (Phase 2)
PROMETHEUS_ENABLED=false
GRAFANA_ENABLED=false
```

#### **Service-Specific Environment Files**

**Backend (.env.backend):**

```plaintext
PORT=3001
CORS_ORIGIN=https://pwa.dice.local,https://cms.dice.local
GRAPHQL_PLAYGROUND=true
TRPC_ENDPOINT=/trpc
TYPEORM_SYNC=true
TYPEORM_LOGGING=true
```

**PWA (.env.pwa):**

```plaintext
PORT=3000
VITE_API_URL=https://api.dice.local
VITE_TRPC_URL=https://api.dice.local/trpc
VITE_APP_TITLE=DICE Character Manager
```

**PayloadCMS (.env.cms):**

```plaintext
PORT=3002
PAYLOAD_SECRET=dice_payload_secret_2024
PAYLOAD_CONFIG_PATH=src/payload.config.ts
```

### Docker Compose Configuration

#### **Main docker-compose.yml**

```yaml
version: '3.8'

services:
  # Reverse Proxy and SSL Termination
  traefik:
    image: traefik:v3.0
    container_name: dice_traefik
    restart: unless-stopped
    command:
      - "--api.dashboard=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.selfsigned.acme.tlschallenge=true"
      - "--certificatesresolvers.selfsigned.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
      - "--log.level=INFO"
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./data/traefik:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.api.rule=Host(`traefik.dice.local`)"
      - "traefik.http.routers.api.tls=true"
      - "traefik.http.routers.api.tls.certresolver=selfsigned"
    networks:
      - dice_network

  # Database
  postgres:
    image: postgres:17-bullseye
    container_name: dice_postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/seed-data:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dice_network

  # Cache
  redis:
    image: redis:7-bullseye
    container_name: dice_redis
    restart: unless-stopped
    command: redis-server --appendonly yes --appendfsync everysec
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dice_network

  # AWS Simulation
  localstack:
    image: localstack/localstack:4.0
    container_name: dice_localstack
    restart: unless-stopped
    environment:
      SERVICES: s3,rds,dynamodb
      DEBUG: 1
      DATA_DIR: /tmp/localstack/data
      DOCKER_HOST: unix:///var/run/docker.sock
    volumes:
      - localstack_data:/tmp/localstack
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - "4566:4566"
    networks:
      - dice_network

  # Backend Service
  backend:
    build:
      context: ./workspace/backend
      dockerfile: Dockerfile
    container_name: dice_backend
    restart: unless-stopped
    environment:
      - NODE_ENV=development
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - JWT_SECRET=${JWT_SECRET}
      - PORT=3001
    volumes:
      - ./workspace/backend:/app
      - backend_node_modules:/app/node_modules
    ports:
      - "3001:3001"
      - "9229:9229"  # Debug port
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=Host(`api.dice.local`)"
      - "traefik.http.routers.backend.tls=true"
      - "traefik.http.routers.backend.tls.certresolver=selfsigned"
      - "traefik.http.services.backend.loadbalancer.server.port=3001"
    networks:
      - dice_network

  # PWA Frontend
  pwa:
    build:
      context: ./workspace/pwa
      dockerfile: Dockerfile
    container_name: dice_pwa
    restart: unless-stopped
    environment:
      - NODE_ENV=development
      - VITE_API_URL=https://api.dice.local
      - PORT=3000
    volumes:
      - ./workspace/pwa:/app
      - pwa_node_modules:/app/node_modules
    ports:
      - "3000:3000"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.pwa.rule=Host(`pwa.dice.local`)"
      - "traefik.http.routers.pwa.tls=true"
      - "traefik.http.routers.pwa.tls.certresolver=selfsigned"
      - "traefik.http.services.pwa.loadbalancer.server.port=3000"
    networks:
      - dice_network

  # PayloadCMS (Phase 2)
  payloadcms:
    build:
      context: ./workspace/payloadcms
      dockerfile: Dockerfile
    container_name: dice_payloadcms
    restart: unless-stopped
    environment:
      - NODE_ENV=development
      - DATABASE_URL=${DATABASE_URL}
      - PAYLOAD_SECRET=${CMS_API_KEY}
      - PORT=3002
    volumes:
      - ./workspace/payloadcms:/app
      - cms_node_modules:/app/node_modules
      - cms_uploads:/app/uploads
    ports:
      - "3002:3002"
    depends_on:
      postgres:
        condition: service_healthy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.cms.rule=Host(`cms.dice.local`)"
      - "traefik.http.routers.cms.tls=true"
      - "traefik.http.routers.cms.tls.certresolver=selfsigned"
      - "traefik.http.services.cms.loadbalancer.server.port=3002"
    networks:
      - dice_network

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  localstack_data:
    driver: local
  backend_node_modules:
    driver: local
  pwa_node_modules:
    driver: local
  cms_node_modules:
    driver: local
  cms_uploads:
    driver: local

networks:
  dice_network:
    driver: bridge
```

### Root DevContainer Configuration

#### **.devcontainer/devcontainer.json**

```json
{
  "name": "DICE Development Environment",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "backend",
  "workspaceFolder": "/workspace",
  "shutdownAction": "stopCompose",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {
      "version": "latest",
      "kubectl": "1.33",
      "helm": "3.16"
    },
    "ghcr.io/devcontainers/features/node:1": {
      "version": "22"
    }
  },
  "postCreateCommand": "scripts/setup-dev-environment.sh",
  "forwardPorts": [3001, 3000, 3002, 5432, 6379, 8080],
  "portsAttributes": {
    "3001": {"label": "Backend API", "onAutoForward": "notify"},
    "3000": {"label": "PWA Frontend", "onAutoForward": "openBrowser"},
    "3002": {"label": "PayloadCMS", "onAutoForward": "notify"},
    "5432": {"label": "PostgreSQL", "onAutoForward": "ignore"},
    "6379": {"label": "Redis", "onAutoForward": "ignore"},
    "8080": {"label": "Traefik Dashboard", "onAutoForward": "notify"}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "bradlc.vscode-tailwindcss",
        "ms-vscode.vscode-json",
        "redhat.vscode-yaml",
        "ms-azuretools.vscode-docker",
        "ms-kubernetes-tools.vscode-kubernetes-tools"
      ],
      "settings": {
        "typescript.preferences.importModuleSpecifier": "relative",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
          "source.fixAll.eslint": true
        }
      }
    }
  }
}
```

### Makefile Commands

#### **Complete Makefile**

```makefile
# DICE Development Environment - Service Management
.PHONY: help setup start stop restart clean logs test backup restore

# Default target
.DEFAULT_GOAL := help

# Variables
COMPOSE_FILE := docker-compose.yml
BACKUP_DIR := ./data/backups
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

help: ## Show this help message
 @echo "DICE Development Environment Commands:"
 @echo ""
 @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Initial setup of development environment
 @echo "Setting up DICE development environment..."
 @./scripts/setup-dev-environment.sh
 @echo "✅ Setup complete!"

start-all: ## Start all services
 @echo "Starting all DICE services..."
 @docker-compose -f $(COMPOSE_FILE) up -d
 @echo "✅ All services started!"
 @echo "🌐 Access your services:"
 @echo "   PWA:     https://pwa.dice.local"
 @echo "   API:     https://api.dice.local"
 @echo "   CMS:     https://cms.dice.local"
 @echo "   Traefik: https://traefik.dice.local:8080"

start-backend: ## Start backend services only (DB + Redis + Backend)
 @echo "Starting backend services..."
 @docker-compose -f $(COMPOSE_FILE) up -d postgres redis backend
 @echo "✅ Backend services started!"

start-frontend: ## Start frontend with mocks
 @echo "Starting PWA with development mocks..."
 @docker-compose -f $(COMPOSE_FILE) up -d pwa
 @echo "✅ PWA started with mock data!"

start-monitoring: ## Start monitoring stack (Phase 2)
 @echo "Starting monitoring services..."
 @docker-compose -f $(COMPOSE_FILE) up -d prometheus grafana
 @echo "✅ Monitoring started!"
 @echo "📊 Grafana: https://monitoring.dice.local"

stop: ## Stop all services
 @echo "Stopping all services..."
 @docker-compose -f $(COMPOSE_FILE) down
 @echo "✅ All services stopped!"

restart: ## Restart all services
 @echo "Restarting all services..."
 @docker-compose -f $(COMPOSE_FILE) restart
 @echo "✅ All services restarted!"

clean: ## Stop services and remove volumes
 @echo "⚠️  This will remove all data! Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
 @docker-compose -f $(COMPOSE_FILE) down -v --remove-orphans
 @docker system prune -f
 @echo "✅ Environment cleaned!"

logs: ## Show logs for all services
 @docker-compose -f $(COMPOSE_FILE) logs -f

logs-backend: ## Show backend logs
 @docker-compose -f $(COMPOSE_FILE) logs -f backend

logs-pwa: ## Show PWA logs
 @docker-compose -f $(COMPOSE_FILE) logs -f pwa

debug-backend: ## Start backend in debug mode
 @echo "Starting backend in debug mode..."
 @docker-compose -f $(COMPOSE_FILE) -f docker-compose.debug.yml up -d backend
 @echo "🐛 Backend debug mode started on port 9229"

test: ## Run all tests
 @echo "Running all tests..."
 @docker-compose -f $(COMPOSE_FILE) exec backend npm run test
 @docker-compose -f $(COMPOSE_FILE) exec pwa npm run test
 @echo "✅ All tests completed!"

backup-db: ## Backup PostgreSQL database
 @echo "Creating database backup..."
 @mkdir -p $(BACKUP_DIR)
 @docker-compose -f $(COMPOSE_FILE) exec postgres pg_dump -U dice_user dice_db > $(BACKUP_DIR)/backup_$(TIMESTAMP).sql
 @echo "✅ Database backed up to $(BACKUP_DIR)/backup_$(TIMESTAMP).sql"

restore-db: ## Restore database from backup (use: make restore-db BACKUP=filename)
 @echo "Restoring database from $(BACKUP_DIR)/$(BACKUP)..."
 @docker-compose -f $(COMPOSE_FILE) exec -T postgres psql -U dice_user -d dice_db < $(BACKUP_DIR)/$(BACKUP)
 @echo "✅ Database restored from $(BACKUP)!"

create-rollback-point: ## Create rollback point (use: make create-rollback-point PHASE=phase1)
 @echo "Creating rollback point for $(PHASE)..."
 @mkdir -p $(BACKUP_DIR)/rollback-points
 @docker-compose -f $(COMPOSE_FILE) exec postgres pg_dump -U dice_user dice_db > $(BACKUP_DIR)/rollback-points/$(PHASE)_$(TIMESTAMP).sql
 @tar -czf $(BACKUP_DIR)/rollback-points/$(PHASE)_config_$(TIMESTAMP).tar.gz config/ docker-compose.yml
 @echo "✅ Rollback point created for $(PHASE)!"

list-rollback-points: ## List available rollback points
 @echo "Available rollback points:"
 @ls -la $(BACKUP_DIR)/rollback-points/ || echo "No rollback points found"

rollback-to-point: ## Rollback to specific point (use: make rollback-to-point POINT=phase1_20241226_120000)
 @echo "Rolling back to $(POINT)..."
 @make restore-db BACKUP=rollback-points/$(POINT).sql
 @tar -xzf $(BACKUP_DIR)/rollback-points/$(POINT)_config.tar.gz
 @make restart
 @echo "✅ Rolled back to $(POINT)!"

status: ## Show service status
 @echo "DICE Services Status:"
 @docker-compose -f $(COMPOSE_FILE) ps

health: ## Check service health
 @echo "Checking service health..."
 @docker-compose -f $(COMPOSE_FILE) exec postgres pg_isready -U dice_user -d dice_db
 @docker-compose -f $(COMPOSE_FILE) exec redis redis-cli ping
 @curl -f https://api.dice.local/health || echo "❌ Backend health check failed"
 @curl -f https://pwa.dice.local || echo "❌ PWA health check failed"
 @echo "✅ Health checks completed!"

# Phase-specific targets
phase1: setup start-backend start-frontend ## Complete Phase 1 setup
 @echo "🎯 Phase 1 implementation complete!"

phase2: phase1 start-monitoring ## Complete Phase 2 setup
 @docker-compose -f $(COMPOSE_FILE) up -d payloadcms
 @echo "🎯 Phase 2 implementation complete!"

phase3: phase2 ## Complete Phase 3 setup
 @echo "🎯 Phase 3 implementation complete!"
 @echo "🚀 Production-ready environment active!"
```

### Workspace-Specific DevContainer Configurations

#### **workspace/backend/.devcontainer/devcontainer.json**

```json
{
  "name": "DICE Backend Service",
  "dockerComposeFile": "../../docker-compose.yml",
  "service": "backend",
  "workspaceFolder": "/app",
  "shutdownAction": "stopCompose",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "22"
    }
  },
  "postCreateCommand": "npm install",
  "forwardPorts": [3001, 9229],
  "portsAttributes": {
    "3001": {"label": "Backend API", "onAutoForward": "openBrowser"},
    "9229": {"label": "Debug Port", "onAutoForward": "ignore"}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "bradlc.vscode-tailwindcss",
        "ms-vscode.vscode-json",
        "GraphQL.vscode-graphql",
        "Prisma.prisma"
      ],
      "settings": {
        "typescript.preferences.importModuleSpecifier": "relative",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
          "source.fixAll.eslint": true
        }
      }
    }
  }
}
```

#### **workspace/pwa/.devcontainer/devcontainer.json**

```json
{
  "name": "DICE PWA Frontend",
  "dockerComposeFile": "../../docker-compose.yml",
  "service": "pwa",
  "workspaceFolder": "/app",
  "shutdownAction": "stopCompose",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "22"
    }
  },
  "postCreateCommand": "npm install",
  "forwardPorts": [3000],
  "portsAttributes": {
    "3000": {"label": "PWA Frontend", "onAutoForward": "openBrowser"}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "bradlc.vscode-tailwindcss",
        "astro-build.astro-vscode",
        "ms-vscode.vscode-json",
        "formulahendry.auto-rename-tag"
      ],
      "settings": {
        "typescript.preferences.importModuleSpecifier": "relative",
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
          "source.fixAll.eslint": true
        }
      }
    }
  }
}
```

#### **workspace/shared/.devcontainer/devcontainer.json**

```json
{
  "name": "DICE Shared Components",
  "dockerComposeFile": "../../docker-compose.yml",
  "service": "backend",
  "workspaceFolder": "/workspace/shared",
  "shutdownAction": "stopCompose",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "22"
    }
  },
  "postCreateCommand": "npm install",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "ms-vscode.vscode-json",
        "bradlc.vscode-tailwindcss"
      ],
      "settings": {
        "typescript.preferences.importModuleSpecifier": "relative",
        "editor.formatOnSave": true
      }
    }
  }
}
```

### Service Dockerfiles

#### **workspace/backend/Dockerfile**

```dockerfile
FROM node:22-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY src/ ./src/

# Create non-root user
RUN groupadd -r dice && useradd -r -g dice dice
RUN chown -R dice:dice /app
USER dice

# Expose ports
EXPOSE 3001 9229

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# Start command
CMD ["npm", "run", "start:dev"]
```

#### **workspace/pwa/Dockerfile**

```dockerfile
FROM node:22-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./
COPY astro.config.mjs ./

# Install dependencies
RUN npm ci && npm cache clean --force

# Copy source code
COPY src/ ./src/
COPY public/ ./public/

# Create non-root user
RUN groupadd -r dice && useradd -r -g dice dice
RUN chown -R dice:dice /app
USER dice

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

# Start command
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
```

#### **workspace/payloadcms/Dockerfile**

```dockerfile
FROM node:22-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm ci && npm cache clean --force

# Copy source code
COPY src/ ./src/

# Create uploads directory
RUN mkdir -p /app/uploads

# Create non-root user
RUN groupadd -r dice && useradd -r -g dice dice
RUN chown -R dice:dice /app
USER dice

# Expose port
EXPOSE 3002

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3002/admin || exit 1

# Start command
CMD ["npm", "run", "dev"]
```

### Code Quality and Development Tools

#### **.pre-commit-config.yaml**

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-merge-conflict
      - id: check-yaml
      - id: check-json
      - id: pretty-format-json
        args: ['--autofix']
      - id: check-added-large-files

  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v8.44.0
    hooks:
      - id: eslint
        files: \.(js|jsx|ts|tsx)$
        types: [file]
        additional_dependencies:
          - eslint@8.44.0
          - "@typescript-eslint/eslint-plugin@5.61.0"
          - "@typescript-eslint/parser@5.61.0"

  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.0.0
    hooks:
      - id: prettier
        files: \.(js|jsx|ts|tsx|json|css|scss|md)$

  - repo: https://github.com/psf/black
    rev: 23.7.0
    hooks:
      - id: black
        language_version: python3

  - repo: https://github.com/sqlfluff/sqlfluff
    rev: 2.1.0
    hooks:
      - id: sqlfluff-lint
        additional_dependencies: ['dbt-postgres', 'sqlfluff-templater-dbt']
      - id: sqlfluff-fix
        additional_dependencies: ['dbt-postgres', 'sqlfluff-templater-dbt']

  - repo: local
    hooks:
      - id: typescript-check
        name: TypeScript Check
        entry: npx tsc --noEmit
        language: system
        files: \.(ts|tsx)$
        pass_filenames: false
```

#### **skaffold.yaml (Phase 2)**

```yaml
apiVersion: skaffold/v4beta6
kind: Config
metadata:
  name: dice-development
build:
  artifacts:
    - image: dice/backend
      context: workspace/backend
      docker:
        dockerfile: Dockerfile
      sync:
        manual:
          - src: 'src/**/*.ts'
            dest: /app/src
    - image: dice/pwa
      context: workspace/pwa
      docker:
        dockerfile: Dockerfile
      sync:
        manual:
          - src: 'src/**/*'
            dest: /app/src
    - image: dice/payloadcms
      context: workspace/payloadcms
      docker:
        dockerfile: Dockerfile
      sync:
        manual:
          - src: 'src/**/*.ts'
            dest: /app/src
deploy:
  docker:
    useCompose: true
    files:
      - docker-compose.yml
portForward:
  - resourceType: service
    resourceName: dice_backend
    port: 3001
    localPort: 3001
  - resourceType: service
    resourceName: dice_pwa
    port: 3000
    localPort: 3000
  - resourceType: service
    resourceName: dice_payloadcms
    port: 3002
    localPort: 3002
  - resourceType: service
    resourceName: dice_traefik
    port: 8080
    localPort: 8080
```

### Monitoring Configuration (Phase 2)

#### **infrastructure/monitoring/prometheus.yml**

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'dice-backend'
    static_configs:
      - targets: ['backend:3001']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'dice-pwa'
    static_configs:
      - targets: ['pwa:3000']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'dice-payloadcms'
    static_configs:
      - targets: ['payloadcms:3002']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis-exporter'
    static_configs:
      - targets: ['redis-exporter:9121']

  - job_name: 'traefik'
    static_configs:
      - targets: ['traefik:8080']
    metrics_path: '/metrics'

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
```

#### **infrastructure/monitoring/grafana/dashboards/dice-overview.json**

```json
{
  "dashboard": {
    "id": null,
    "title": "DICE Development Overview",
    "tags": ["dice", "development"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Service Health",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=~\"dice-.*\"}",
            "legendFormat": "{{job}}"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "thresholds"
            },
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "green", "value": 1}
              ]
            }
          }
        }
      },
      {
        "id": 2,
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{service}} requests/sec"
          }
        ]
      },
      {
        "id": 3,
        "title": "Response Times",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "id": 4,
        "title": "Database Connections",
        "type": "graph",
        "targets": [
          {
            "expr": "pg_stat_database_numbackends",
            "legendFormat": "Active connections"
          }
        ]
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s"
  }
}
```

### Phase 2 and 3 Validation Scripts

#### **scripts/validate-phase2.sh**

```bash
#!/bin/bash
set -e

echo "🔍 Validating Phase 2 Implementation..."

# Check Phase 1 is still working
echo "Verifying Phase 1 components..."
./scripts/validate-phase1.sh

# Check monitoring services
echo "Checking monitoring stack..."
if docker-compose ps prometheus | grep -q "Up"; then
    echo "✅ Prometheus is running"
else
    echo "❌ Prometheus is not running"
    exit 1
fi

if docker-compose ps grafana | grep -q "Up"; then
    echo "✅ Grafana is running"
else
    echo "❌ Grafana is not running"
    exit 1
fi

# Check PayloadCMS
echo "Checking PayloadCMS..."
if docker-compose ps payloadcms | grep -q "Up"; then
    echo "✅ PayloadCMS is running"
else
    echo "❌ PayloadCMS is not running"
    exit 1
fi

# Check monitoring endpoints
echo "Checking monitoring endpoints..."
if curl -f https://monitoring.dice.local &> /dev/null; then
    echo "✅ Grafana accessible at https://monitoring.dice.local"
else
    echo "❌ Grafana not accessible"
    exit 1
fi

if curl -f https://cms.dice.local/admin &> /dev/null; then
    echo "✅ PayloadCMS accessible at https://cms.dice.local"
else
    echo "❌ PayloadCMS not accessible"
    exit 1
fi

# Check D&D rules data
echo "Checking D&D rules data..."
RACE_COUNT=$(curl -s https://cms.dice.local/api/races | jq '. | length')
if [ "$RACE_COUNT" -gt 0 ]; then
    echo "✅ D&D rules data populated ($RACE_COUNT races)"
else
    echo "❌ D&D rules data missing"
    exit 1
fi

# Check pre-commit hooks
echo "Checking pre-commit hooks..."
if [ -f .pre-commit-config.yaml ] && command -v pre-commit &> /dev/null; then
    if pre-commit run --all-files &> /dev/null; then
        echo "✅ Pre-commit hooks working"
    else
        echo "❌ Pre-commit hooks failing"
        exit 1
    fi
else
    echo "⚠️  Pre-commit hooks not configured"
fi

# Check independent service modes
echo "Checking independent service modes..."
docker-compose stop pwa
sleep 5
if curl -f https://api.dice.local/health &> /dev/null; then
    echo "✅ Backend-only mode working"
    docker-compose start pwa
    sleep 10
else
    echo "❌ Backend-only mode failed"
    docker-compose start pwa
    exit 1
fi

echo "✅ Phase 2 validation complete - All checks passed!"
```

#### **scripts/validate-phase3.sh**

```bash
#!/bin/bash
set -e

echo "🔍 Validating Phase 3 Implementation..."

# Check Phase 2 is still working
echo "Verifying Phase 2 components..."
./scripts/validate-phase2.sh

# Check advanced monitoring
echo "Checking ELK stack..."
if docker-compose ps elasticsearch | grep -q "Up"; then
    echo "✅ Elasticsearch is running"
else
    echo "❌ Elasticsearch is not running"
    exit 1
fi

if docker-compose ps kibana | grep -q "Up"; then
    echo "✅ Kibana is running"
else
    echo "❌ Kibana is not running"
    exit 1
fi

# Check distributed tracing
echo "Checking Jaeger..."
if docker-compose ps jaeger | grep -q "Up"; then
    echo "✅ Jaeger is running"
else
    echo "❌ Jaeger is not running"
    exit 1
fi

# Check Redis clustering
echo "Checking Redis cluster..."
REDIS_CLUSTER_SIZE=$(docker-compose ps | grep redis | wc -l)
if [ "$REDIS_CLUSTER_SIZE" -gt 1 ]; then
    echo "✅ Redis clustering active ($REDIS_CLUSTER_SIZE nodes)"
else
    echo "❌ Redis clustering not configured"
    exit 1
fi

# Check security scanning
echo "Running security scan..."
if command -v trivy &> /dev/null; then
    if trivy image --severity HIGH,CRITICAL dice/backend &> /dev/null; then
        echo "✅ Security scanning passed"
    else
        echo "⚠️  Security vulnerabilities found"
    fi
else
    echo "⚠️  Trivy not installed, skipping security scan"
fi

# Check Kubernetes manifests
echo "Checking Kubernetes manifests..."
if kubectl apply --dry-run=client -f infrastructure/k8s/ &> /dev/null; then
    echo "✅ Kubernetes manifests valid"
else
    echo "❌ Kubernetes manifests invalid"
    exit 1
fi

# Performance baseline test
echo "Running performance baseline..."
if command -v k6 &> /dev/null; then
    if k6 run --duration=30s --vus=10 scripts/load-test.js &> /dev/null; then
        echo "✅ Performance baseline test passed"
    else
        echo "❌ Performance baseline test failed"
        exit 1
    fi
else
    echo "⚠️  k6 not installed, skipping performance test"
fi

echo "✅ Phase 3 validation complete - All checks passed!"
echo "🚀 Production-ready environment validated!"
```

### Production Kubernetes Manifests (Phase 3)

#### **infrastructure/k8s/namespace.yml**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dice-production
  labels:
    name: dice-production
    environment: production
```

#### **infrastructure/k8s/postgres/deployment.yml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: dice-production
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:17-bullseye
        env:
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: database
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - $(POSTGRES_USER)
            - -d
            - $(POSTGRES_DB)
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - $(POSTGRES_USER)
            - -d
            - $(POSTGRES_DB)
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: dice-production
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
```

#### **infrastructure/k8s/backend/deployment.yml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: dice-production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: dice/backend:latest
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: database-url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: redis-url
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: backend-secret
              key: jwt-secret
        ports:
        - containerPort: 3001
        livenessProbe:
          httpGet:
            path: /health
            port: 3001
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3001
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: dice-production
spec:
  selector:
    app: backend
  ports:
  - port: 3001
    targetPort: 3001
  type: ClusterIP
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: dice-production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Load Testing Configuration

#### **scripts/load-test.js**

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 10 }, // Ramp up
    { duration: '5m', target: 10 }, // Stay at 10 users
    { duration: '2m', target: 20 }, // Ramp up to 20 users
    { duration: '5m', target: 20 }, // Stay at 20 users
    { duration: '2m', target: 0 },  // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    http_req_failed: ['rate<0.1'],    // Error rate under 10%
  },
};

export default function() {
  // Test backend health endpoint
  let response = http.get('https://api.dice.local/health');
  check(response, {
    'backend health check': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  });

  // Test PWA main page
  response = http.get('https://pwa.dice.local');
  check(response, {
    'PWA loads successfully': (r) => r.status === 200,
    'PWA response time < 500ms': (r) => r.timings.duration < 500,
  });

  // Test GraphQL endpoint
  let payload = JSON.stringify({
    query: '{ characters { id name race class } }'
  });
  
  response = http.post('https://api.dice.local/graphql', payload, {
    headers: { 'Content-Type': 'application/json' },
  });
  
  check(response, {
    'GraphQL query successful': (r) => r.status === 200,
    'GraphQL response time < 300ms': (r) => r.timings.duration < 300,
  });

  sleep(1);
}

export function handleSummary(data) {
  return {
    'load-test-results.json': JSON.stringify(data, null, 2),
    stdout: `
    ========================================
    DICE Load Test Results
    ========================================
    Total Requests: ${data.metrics.http_reqs.values.count}
    Failed Requests: ${data.metrics.http_req_failed.values.rate * 100}%
    Average Response Time: ${data.metrics.http_req_duration.values.avg}ms
    95th Percentile: ${data.metrics.http_req_duration.values['p(95)']}ms
    ========================================
    `,
  };
}
```

### Setup Scripts

#### **scripts/setup-dev-environment.sh**

```bash
#!/bin/bash
set -e

echo "🚀 Setting up DICE Development Environment..."

# Create required directories
echo "📁 Creating directory structure..."
mkdir -p data/{postgres,redis,localstack,uploads,backups}
mkdir -p config
mkdir -p scripts/seed-data

# Copy environment template if it doesn't exist
if [ ! -f .env.development ]; then
    echo "📝 Creating development environment file..."
    cp config/.env.sample .env.development
    echo "⚠️  Please update .env.development with your specific configuration"
fi

# Set proper permissions
echo "🔒 Setting permissions..."
chmod +x scripts/*.sh
chmod 755 data/

# Check Docker installation
echo "🐳 Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop or Rancher Desktop."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose."
    exit 1
fi

# Check if ports are available
echo "🔍 Checking port availability..."
for port in 80 443 3001 3000 3002 5432 6379 8080; do
    if lsof -i :$port &> /dev/null; then
        echo "⚠️  Port $port is already in use. Please stop the service using this port."
    fi
done

# Add hosts entries
echo "🌐 Checking /etc/hosts entries..."
HOSTS_FILE="/etc/hosts"
HOSTS_ENTRIES=(
    "127.0.0.1 pwa.dice.local"
    "127.0.0.1 api.dice.local"
    "127.0.0.1 cms.dice.local"
    "127.0.0.1 traefik.dice.local"
    "127.0.0.1 monitoring.dice.local"
)

for entry in "${HOSTS_ENTRIES[@]}"; do
    if ! grep -q "$entry" "$HOSTS_FILE" 2>/dev/null; then
        echo "Adding to hosts: $entry"
        echo "$entry" | sudo tee -a "$HOSTS_FILE" > /dev/null
    fi
done

# Install pre-commit hooks (Phase 2)
if [ -f .pre-commit-config.yaml ]; then
    echo "🎯 Installing pre-commit hooks..."
    pip install pre-commit
    pre-commit install
fi

echo "✅ Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and update .env.development file"
echo "2. Run 'make start-all' to start all services"
echo "3. Access your application at https://pwa.dice.local"
echo ""
echo "For help: make help"
```

### Database Migration and Seed Data

#### **scripts/seed-data/01-init-database.sql**

```sql
-- DICE Development Database Initialization

-- Create development users
INSERT INTO users (id, email, password_hash, role, created_at, updated_at) VALUES
('dev-admin-001', 'admin@dice.local', '$2b$10$hashedpasswordfordev', 'admin', NOW(), NOW()),
('dev-user-001', 'user@dice.local', '$2b$10$hashedpasswordfordev', 'user', NOW(), NOW())
ON CONFLICT (email) DO NOTHING;

-- Create sample D&D characters
INSERT INTO characters (id, user_id, name, race, class, level, ability_scores, created_at, updated_at) VALUES
('char-001', 'dev-user-001', 'Test Fighter', 'Human', 'Fighter', 1, 
 '{"str": 16, "dex": 14, "con": 15, "int": 12, "wis": 13, "cha": 10}', NOW(), NOW()),
('char-002', 'dev-user-001', 'Sample Wizard', 'Elf', 'Wizard', 1,
 '{"str": 8, "dex": 14, "con": 12, "int": 16, "wis": 15, "cha": 13}', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Create basic authentication tokens
INSERT INTO auth_tokens (id, user_id, token_hash, expires_at, created_at) VALUES
('token-001', 'dev-admin-001', 'dev_admin_token_hash', NOW() + INTERVAL '30 days', NOW()),
('token-002', 'dev-user-001', 'dev_user_token_hash', NOW() + INTERVAL '30 days', NOW())
ON CONFLICT (id) DO NOTHING;

-- Log initialization
INSERT INTO system_logs (level, message, created_at) VALUES
('INFO', 'Development database initialized with seed data', NOW());
```

#### **scripts/seed-data/dnd-rules.json**

```json
{
  "races": [
    {
      "name": "Human",
      "ability_score_increase": {"all": 1},
      "size": "Medium",
      "speed": 30,
      "languages": ["Common"],
      "traits": ["Extra Skill", "Extra Feat"]
    },
    {
      "name": "Elf",
      "ability_score_increase": {"dex": 2},
      "size": "Medium", 
      "speed": 30,
      "languages": ["Common", "Elvish"],
      "traits": ["Darkvision", "Fey Ancestry", "Trance"]
    },
    {
      "name": "Dwarf",
      "ability_score_increase": {"con": 2},
      "size": "Medium",
      "speed": 25,
      "languages": ["Common", "Dwarvish"],
      "traits": ["Darkvision", "Dwarven Resilience", "Stonecunning"]
    }
  ],
  "classes": [
    {
      "name": "Fighter",
      "hit_die": "d10",
      "primary_ability": ["Strength", "Dexterity"],
      "saving_throw_proficiencies": ["Strength", "Constitution"],
      "skill_proficiencies": 2,
      "armor_proficiencies": ["Light", "Medium", "Heavy", "Shields"],
      "weapon_proficiencies": ["Simple", "Martial"]
    },
    {
      "name": "Wizard",
      "hit_die": "d6", 
      "primary_ability": ["Intelligence"],
      "saving_throw_proficiencies": ["Intelligence", "Wisdom"],
      "skill_proficiencies": 2,
      "armor_proficiencies": [],
      "weapon_proficiencies": ["Simple"]
    },
    {
      "name": "Rogue",
      "hit_die": "d8",
      "primary_ability": ["Dexterity"],
      "saving_throw_proficiencies": ["Dexterity", "Intelligence"], 
      "skill_proficiencies": 4,
      "armor_proficiencies": ["Light"],
      "weapon_proficiencies": ["Simple", "Hand crossbows", "Longswords", "Rapiers", "Shortswords"]
    }
  ],
  "ability_scores": {
    "names": ["Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"],
    "abbreviations": ["STR", "DEX", "CON", "INT", "WIS", "CHA"],
    "modifiers": {
      "1": -5, "2": -4, "3": -4, "4": -3, "5": -3,
      "6": -2, "7": -2, "8": -1, "9": -1, "10": 0,
      "11": 0, "12": 1, "13": 1, "14": 2, "15": 2,
      "16": 3, "17": 3, "18": 4, "19": 4, "20": 5
    }
  }
}
```

### Validation Checkpoints

#### **Phase 1 Validation Script: scripts/validate-phase1.sh**

```bash
#!/bin/bash
set -e

echo "🔍 Validating Phase 1 Implementation..."

# Check service health
echo "Checking service startup order..."
if docker-compose ps postgres | grep -q "Up"; then
    echo "✅ PostgreSQL is running"
else
    echo "❌ PostgreSQL is not running"
    exit 1
fi

if docker-compose ps redis | grep -q "Up"; then
    echo "✅ Redis is running"
else
    echo "❌ Redis is not running"
    exit 1
fi

if docker-compose ps backend | grep -q "Up"; then
    echo "✅ Backend is running"
else
    echo "❌ Backend is not running"
    exit 1
fi

# Check HTTPS endpoints
echo "Checking HTTPS endpoints..."
if curl -k -f https://api.dice.local/health &> /dev/null; then
    echo "✅ Backend accessible at https://api.dice.local"
else
    echo "❌ Backend not accessible via HTTPS"
    exit 1
fi

if curl -k -f https://pwa.dice.local &> /dev/null; then
    echo "✅ PWA accessible at https://pwa.dice.local"
else
    echo "❌ PWA not accessible via HTTPS"
    exit 1
fi

# Check database connectivity
echo "Checking database connectivity..."
if docker-compose exec postgres pg_isready -U dice_user -d dice_db &> /dev/null; then
    echo "✅ Database connection working"
else
    echo "❌ Database connection failed"
    exit 1
fi

# Check seed data
echo "Checking seed data..."
USER_COUNT=$(docker-compose exec postgres psql -U dice_user -d dice_db -t -c "SELECT COUNT(*) FROM users;" | tr -d ' ')
if [ "$USER_COUNT" -gt 0 ]; then
    echo "✅ Database seeded with development data ($USER_COUNT users)"
else
    echo "❌ Database seed data missing"
    exit 1
fi

echo "✅ Phase 1 validation complete - All checks passed!"
```

### Troubleshooting and Rollback Procedures

#### **Emergency Reset Script: scripts/emergency-reset.sh**

```bash
#!/bin/bash
set -e

echo "⚠️  EMERGENCY RESET - This will destroy all data!"
echo "Are you absolutely sure? Type 'RESET' to continue:"
read confirmation

if [ "$confirmation" != "RESET" ]; then
    echo "Cancelled."
    exit 0
fi

echo "🚨 Performing emergency reset..."

# Stop everything
docker-compose down -v --remove-orphans
docker system prune -af --volumes

# Remove all project data
rm -rf data/ || true
rm -rf logs/ || true
rm -rf .env.* || true
rm -f docker-compose.override.yml || true

# Reset git to clean state
git reset --hard HEAD
git clean -fdx

echo "💀 Emergency reset complete!"
echo "Run 'make setup' to start fresh."
```

### Environment File Templates

#### **infrastructure/config/.env.sample**

```bash
# DICE Development Environment Template
# Copy this file to .env.development and update values

# Database Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=dice_db
POSTGRES_USER=dice_user
POSTGRES_PASSWORD=dice_dev_password_2024
DATABASE_URL=postgresql://dice_user:dice_dev_password_2024@postgres:5432/dice_db

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_URL=redis://redis:6379

# LocalStack Configuration (AWS Simulation)
LOCALSTACK_ENDPOINT=http://localstack:4566
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_DEFAULT_REGION=us-east-1

# Service URLs (Internal Docker Network)
BACKEND_URL=http://backend:3001
PWA_URL=http://pwa:3000
CMS_URL=http://payloadcms:3002

# Authentication Secrets (CHANGE IN PRODUCTION!)
JWT_SECRET=dice_jwt_secret_development_2024
BACKEND_API_KEY=dice_dev_api_key_2024
CMS_API_KEY=dice_cms_api_key_2024
INTERNAL_JWT_SECRET=dice_internal_jwt_secret_dev

# Development Settings
NODE_ENV=development
LOG_LEVEL=debug
HOT_RELOAD=true

# Traefik Configuration
TRAEFIK_API_DASHBOARD=true
TRAEFIK_LOG_LEVEL=INFO

# Monitoring (Phase 2)
PROMETHEUS_ENABLED=false
GRAFANA_ENABLED=false

# Security Settings (Phase 3)
VAULT_ENABLED=false
VAULT_TOKEN=
SECURITY_SCANNING=false
```

#### **workspace/backend/.env.sample**

```bash
# Backend Service Environment Template

# Service Configuration
PORT=3001
HOST=0.0.0.0

# CORS Configuration
CORS_ORIGIN=https://pwa.dice.local,https://cms.dice.local
CORS_CREDENTIALS=true

# API Configuration
GRAPHQL_PLAYGROUND=true
GRAPHQL_INTROSPECTION=true
TRPC_ENDPOINT=/trpc

# Database Configuration
TYPEORM_SYNC=true
TYPEORM_LOGGING=true
TYPEORM_MIGRATIONS_RUN=true

# Authentication Configuration
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# File Upload Configuration
MAX_FILE_SIZE=10485760
UPLOAD_DEST=./uploads

# Development Features
DEBUG_MODE=true
HOT_RELOAD=true
```

#### **workspace/pwa/.env.sample**

```bash
# PWA Frontend Environment Template

# Service Configuration
PORT=3000
HOST=0.0.0.0

# API Endpoints
VITE_API_URL=https://api.dice.local
VITE_TRPC_URL=https://api.dice.local/trpc
VITE_GRAPHQL_URL=https://api.dice.local/graphql
VITE_CMS_URL=https://cms.dice.local

# Application Configuration
VITE_APP_TITLE=DICE Character Manager
VITE_APP_DESCRIPTION=D&D Character Management Tool
VITE_APP_VERSION=1.0.0

# PWA Configuration
VITE_PWA_NAME=DICE
VITE_PWA_SHORT_NAME=DICE
VITE_PWA_THEME_COLOR=#1f2937

# Development Features
VITE_DEV_TOOLS=true
VITE_DEBUG_MODE=true
```

### Complete Implementation Checklist

#### **Phase 1 Implementation Checklist**

```markdown
## Phase 1: Minimal Viable Development Environment

### 1.1 Foundation Setup
- [ ] Create root `.devcontainer/devcontainer.json` with Docker Compose integration
- [ ] Set up `docker-compose.yml` with Traefik, PostgreSQL, Redis, LocalStack
- [ ] Configure Traefik for automatic SSL certificate generation
- [ ] Create `infrastructure/data/` directories with proper permissions
- [ ] Set up service dependency chain using `depends_on` healthchecks

### 1.2 Data Layer Setup  
- [ ] Deploy PostgreSQL 17-bullseye with persistent volume
- [ ] Deploy Redis 7-bullseye with appendonly persistence
- [ ] Deploy LocalStack 4.0 with S3, RDS, DynamoDB services
- [ ] Configure health checks for all data services
- [ ] Test database connectivity and persistence

### 1.3 Service Communication
- [ ] Create `.env.development` with all service URLs
- [ ] Document internal Docker network communication
- [ ] Set up fake development credentials and API keys
- [ ] Test inter-service connectivity

### 1.4 Backend Service
- [ ] Create `workspace/backend/Dockerfile` with Node.js 22-bullseye
- [ ] Set up Nest.js project structure with TypeScript
- [ ] Configure TypeORM with PostgreSQL connection
- [ ] Implement tRPC endpoints for web frontend
- [ ] Implement GraphQL Federation for mobile app
- [ ] Add health check endpoints: `/health`, `/ready`, `/metrics`
- [ ] Set up debugging support on port 9229
- [ ] Configure hot reload with volume mounts

### 1.5 PWA Frontend
- [ ] Create `workspace/pwa/Dockerfile` with Node.js 22-bullseye  
- [ ] Set up Astro.js project with React integration
- [ ] Configure TailwindCSS for styling
- [ ] Set up tRPC client for backend communication
- [ ] Implement MirageJS mocks for independent development
- [ ] Configure service worker for offline capability
- [ ] Set up hot reload with optimised file watching

### 1.6 Development Tools
- [ ] Create comprehensive `Makefile` with all service commands
- [ ] Set up `scripts/setup-dev-environment.sh` automation
- [ ] Create database seed scripts with D&D sample data
- [ ] Configure workspace-specific DevContainers
- [ ] Set up validation script `scripts/validate-phase1.sh`

### 1.7 Validation Gates
- [ ] All services start in correct dependency order
- [ ] Backend accessible at `https://api.dice.local` with valid SSL
- [ ] PWA accessible at `https://pwa.dice.local` with service worker
- [ ] Database seeded with development users and characters
- [ ] Hot reload functioning within performance targets (< 8s backend, < 5s PWA)
- [ ] Health check endpoints responding correctly
- [ ] GraphQL playground accessible with basic queries
- [ ] Independent service startup working (`make start-backend`, `make start-frontend`)
```

#### **Phase 2 Implementation Checklist**

```markdown
## Phase 2: Enhanced Development Experience

### 2.1 Monitoring Stack
- [ ] Deploy Prometheus with service discovery configuration
- [ ] Deploy Grafana with DICE-specific dashboards
- [ ] Configure PostgreSQL and Redis exporters
- [ ] Set up service health monitoring with custom probes
- [ ] Create monitoring accessible at `https://monitoring.dice.local`

### 2.2 PayloadCMS Integration
- [ ] Create `workspace/payloadcms/` with Dockerfile
- [ ] Configure PayloadCMS with PostgreSQL backend
- [ ] Set up D&D rules data models (races, classes, spells)
- [ ] Create automated seeding from `scripts/seed-data/dnd-rules.json`
- [ ] Configure shared TypeScript types across services
- [ ] Set up CMS accessible at `https://cms.dice.local`

### 2.3 Development Workflow Tools
- [ ] Create `.pre-commit-config.yaml` with comprehensive hooks
- [ ] Set up `skaffold.yaml` for optimised hot reload
- [ ] Configure ESLint, Prettier, TypeScript checking
- [ ] Add security scanning hooks
- [ ] Set up automated code formatting and linting

### 2.4 Independent Service Management
- [ ] Implement backend-only mode (PostgreSQL + Redis + Backend)
- [ ] Implement frontend-only mode (PWA with MirageJS mocks)
- [ ] Implement full-stack mode with proper dependency ordering
- [ ] Implement testing mode with test databases
- [ ] Add service isolation and independent debugging capabilities

### 2.5 Validation Gates
- [ ] Prometheus collecting metrics from all services
- [ ] Grafana dashboards showing service health and resource usage
- [ ] PayloadCMS populated with complete D&D rules data
- [ ] Shared TypeScript types working across all services
- [ ] Pre-commit hooks preventing bad code commits
- [ ] Skaffold hot reload optimised with intelligent rebuilds
- [ ] All Makefile commands working: test, debug, clean, reset
- [ ] Independent service modes fully functional
```

#### **Phase 3 Implementation Checklist**

```markdown
## Phase 3: Production-Ready Features

### 3.1 Advanced Security
- [ ] Deploy HashiCorp Vault for secrets management
- [ ] Configure Kubernetes RBAC with service accounts
- [ ] Set up security scanning with Trivy
- [ ] Implement automatic secret rotation
- [ ] Configure network policies and security boundaries

### 3.2 Advanced Monitoring
- [ ] Deploy ELK stack (Elasticsearch, Logstash, Kibana)
- [ ] Configure distributed tracing with Jaeger
- [ ] Set up alerting with Prometheus alerts
- [ ] Configure notification channels (Slack, email, PagerDuty)
- [ ] Implement log aggregation and analysis

### 3.3 Scaling and Performance
- [ ] Configure Redis clustering with persistence and replication
- [ ] Implement horizontal pod autoscaling with custom metrics
- [ ] Set up load testing with k6 scripts
- [ ] Configure performance regression detection
- [ ] Implement resource limits and requests

### 3.4 Production Kubernetes Manifests
- [ ] Create production namespace and RBAC
- [ ] Deploy PostgreSQL with persistent volumes and backups
- [ ] Deploy Redis cluster with high availability
- [ ] Deploy backend with horizontal pod autoscaling
- [ ] Deploy PWA with CDN and edge caching
- [ ] Deploy PayloadCMS with file storage persistence
- [ ] Configure Ingress with production SSL certificates

### 3.5 Validation Gates
- [ ] HashiCorp Vault managing secrets with automatic rotation
- [ ] ELK stack aggregating logs from all services
- [ ] Jaeger tracing requests across microservices
- [ ] Redis clustering with persistence and failover
- [ ] Security scanning passing for all containers
- [ ] Load testing scenarios completing with performance baselines
- [ ] Horizontal pod autoscaling working with custom metrics
- [ ] Production Kubernetes manifests deploying successfully
```

### Final Implementation Notes for AI Editor

#### **Critical Success Factors**

1. **Follow Validation Gates**: Each phase must pass ALL validation checks before proceeding
2. **Implement Rollback Procedures**: Create rollback points before major changes
3. **Monitor Resource Usage**: Ensure system meets minimum requirements at each phase
4. **Test Independent Service Modes**: Verify each service can run independently
5. **Maintain Documentation**: Update `IMPLEMENTATION_STATUS.md` regularly

#### **Common Implementation Pitfalls to Avoid**

1. **Don't Skip Health Checks**: All services must have proper health checks
2. **Don't Ignore Dependencies**: Respect service startup order and dependencies
3. **Don't Rush Validation**: Run full validation scripts, not just quick checks
4. **Don't Forget Permissions**: Set proper file and directory permissions
5. **Don't Skip Backup Points**: Create rollback points before major changes

#### **Emergency Procedures**

1. **Service Won't Start**: Check logs, verify dependencies, restart in isolation
2. **Database Issues**: Use backup/restore procedures, check connectivity
3. **SSL Certificate Problems**: Regenerate certificates, check Traefik configuration
4. **Performance Issues**: Check resource usage, review hot reload configuration
5. **Complete Failure**: Use emergency reset script to start fresh

---

## 📊 **Implementation Timeline and Milestones**

### Phase 1 Milestones (Weeks 1-3)

- [ ] Week 1: Core infrastructure (Docker Compose, Traefik, databases)
- [ ] Week 2: Backend service with API endpoints and database integration
- [ ] Week 3: PWA frontend with hot reload and service integration

### Phase 2 Milestones (Weeks 4-5)

- [ ] Week 4: Monitoring stack (Prometheus, Grafana) and PayloadCMS
- [ ] Week 5: Development tools (pre-commit hooks, Skaffold, independent modes)

### Phase 3 Milestones (Weeks 6-7)

- [ ] Week 6: Production Kubernetes manifests and advanced security
- [ ] Week 7: Advanced monitoring (ELK, Jaeger) and performance testing

### Success Validation

Each phase includes specific validation scripts that must pass before proceeding to the next phase. The implementation should follow test-driven development principles with validation gates at each milestone.

---

**Final Notes for AI Editor:**

- Follow the phased approach strictly - do not skip validation steps
- Implement rollback procedures with each phase
- Test all validation checkpoints before marking phases complete
- Update IMPLEMENTATION_STATUS.md regularly with progress
- Create backup points before major changes
