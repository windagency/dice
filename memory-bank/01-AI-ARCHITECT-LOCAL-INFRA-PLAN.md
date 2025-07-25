# Instruction: Complete Containerised Development Environment for DICE Monorepo (Phased Approach)

> Please follow this plan using proper rules from the knowledge base.

## Goal

Create a containerised development environment using Rancher Desktop and Kubernetes for the DICE D&D character manager monorepo. The implementation follows a phased approach starting with minimal viable setup and progressively adding complexity. Each service can be started independently for development, debugging, or testing purposes.

## Development vs Production Configuration

**Development Mode (Phase 1-2) - Docker Compose:**

- Environment variables in `.env` files (not Vault)
- Simple logging to stdout/files (not ELK stack)  
- Single Redis instance (not clustering)
- Docker Compose for local development with hot reload optimisation
- Basic health checks + Prometheus + Grafana
- Traefik built-in SSL certificate generation

**Production-Ready Mode (Phase 3+) - Kubernetes:**

- HashiCorp Vault for secrets
- ELK stack for centralised logging
- Redis clustering with persistence
- Kubernetes deployment with GitOps (ArgoCD)
- Advanced monitoring and scaling
- Production SSL certificates with cert-manager

## Existing files

- `dice/workspace/backend/` (empty directory)
- `dice/workspace/pwa/` (empty directory)
- `dice/workspace/shared/` (contains images only)
- `dice/infrastructure/k8s/` (empty directory)
- `dice/infrastructure/tf/` (empty directory)
- `dice/infrastructure/localstack/` (empty directory)
- `dice/ai-architect/` (contains all documentation)
- `dice/CHANGELOG.md`
- `dice/README.md`

## New files to create

### Core Infrastructure

- `.devcontainer/devcontainer.json` (root devcontainer with Kubernetes tools)
- `workspace/backend/.devcontainer/devcontainer.json` (Nest.js development)
- `workspace/pwa/.devcontainer/devcontainer.json` (Astro.js development)  
- `workspace/shared/.devcontainer/devcontainer.json` (shared components)
- `infrastructure/k8s/` (Kubernetes manifests organised by service)
- `infrastructure/docker/` (Dockerfiles with stable base images)
- `infrastructure/scripts/` (automation and service management)
- `Makefile` (service lifecycle commands)
- `skaffold.yaml` (hot reload optimisation)
- `IMPLEMENTATION_STATUS.md` (phase tracking)

### Configuration Management

- `.env.development` (development environment variables)
- `infrastructure/certs/` (mkcert SSL certificates and mounting strategy)
- `infrastructure/data/` (persistent volumes for databases)

### Tools

- `.pre-commit-config.yaml` (code quality hooks)
- `workspace/shared/types/` (shared TypeScript definitions)
- `infrastructure/scripts/seed-data/` (development data initialisation)

## Implementation Phases

### PHASE 1: Minimal Viable Development Environment

> Core functionality with essential services - Target: Basic development workflow working

#### 1.1 Foundation Setup (Dependencies: None)

- **Create root devcontainer** with Kubernetes tools (kubectl v1.33, k9s v0.27.4, mkcert v1.4.4) using stable Node.js base image
- **Configure SSL certificate strategy** using Traefik's built-in certificate generation for *.dice.local domains
- **Set up persistent volume structure** for PostgreSQL data, Redis data, and development files with proper permissions
- **Create service startup dependency chain** using Docker Compose depends_on: PostgreSQL → Backend, PayloadCMS → Backend, Redis → Backend

#### 1.2 Data Layer Setup (Dependencies: 1.1)

- **Deploy PostgreSQL** using stable `postgres:17-bullseye` image with persistent storage and development database initialisation
- **Deploy Redis** single instance using stable `redis:7-bullseye` image with basic persistence for session/cache storage
- **Configure Localstack** using `localstack/localstack:4.0` for S3, RDS simulation with persistent state and development AWS resources

#### 1.3 Service Communication Strategy (Dependencies: 1.2)

```yaml
# Example service URLs for clear identification
POSTGRES_URL: "postgresql://dice_user:dice_dev_password@postgres-service.dice.svc.cluster.local:5432/dice_db"
REDIS_URL: "redis://redis-service.dice.svc.cluster.local:6379"
LOCALSTACK_ENDPOINT: "http://localstack-service.dice.svc.cluster.local:4566"
BACKEND_URL: "http://backend-service.dice.svc.cluster.local:3001"
CMS_URL: "http://cms-service.dice.svc.cluster.local:3002"
```

#### 1.4 Backend Service (Dependencies: 1.3)

- **Create backend devcontainer** using stable `node:22-bullseye` with debugging support (--inspect), TypeScript, and hot reload optimisation
- **Configure Nest.js backend** with GraphQL Federation (for Flutter mobile app) + tRPC (for web frontend) using clear separation of concerns
- **Set up TypeORM migrations** with automatic database schema management and development seed data integration
- **Implement health check endpoints** at `/health`, `/ready`, `/metrics` for Kubernetes probes and basic monitoring

#### 1.5 PWA Frontend (Dependencies: 1.4)

- **Create PWA devcontainer** using stable `node:22-bullseye` with Astro CLI, debugging tools, and optimised file watching
- **Configure Astro.js PWA** with React integration, TailwindCSS, and MirageJS mock API for independent frontend development
- **optimise hot reload** using volume mounts with optimised file watching, bind mounts for source code, and intelligent rebuild triggers
- **Set up service worker** with offline capability and development-friendly caching strategies

### PHASE 2: Enhanced Development Experience

> Development productivity and debugging tools - Target: Seamless developer workflow

#### 2.1 Monitoring Stack (Dependencies: Phase 1 Complete)

- **Deploy Prometheus** for metrics collection from all services with basic scraping configuration
- **Deploy Grafana** with pre-built dashboards for service health, resource usage, and business metrics
- **Configure service health monitoring** with custom probes and automatic service restart capabilities

#### 2.2 PayloadCMS Integration (Dependencies: 2.1)

- **Deploy PayloadCMS** using stable `node:22-bullseye` base with PostgreSQL backend integration
- **Configure D&D rules data** with automated seeding from static JSON files including races, classes, spells, and abilities
- **Set up CMS API integration** with backend service using shared TypeScript types and automated schema synchronisation

#### 2.3 Development Workflow Tools (Dependencies: 2.2)

- **Create comprehensive Makefile** with commands: `make start-all`, `make start-backend`, `make start-frontend`, `make test`, `make debug-backend`
- **Configure Skaffold** for optimised hot reload with file watching, intelligent rebuilds, and port forwarding automation
- **Set up pre-commit hooks** with ESLint, Prettier, TypeScript checking, and basic security scanning

#### 2.4 Independent Service Management (Dependencies: 2.3)

- **Backend-only mode**: Start PostgreSQL + Redis + Backend for API development and testing
- **Frontend-only mode**: Start PWA with MirageJS mocks for UI development without backend dependencies
- **Full-stack mode**: Start all services with proper dependency ordering and health checks
- **Testing mode**: Start services with test databases and isolated data for automated testing

### PHASE 3: Production-Ready Features

> Production-grade infrastructure and advanced features - Target: Production deployment capability

#### 3.1 Advanced Security (Dependencies: Phase 2 Complete)

- **Deploy HashiCorp Vault** for secrets management with automatic rotation for production deployments
- **Configure Kubernetes RBAC** with service accounts and proper security boundaries
- **Add security scanning** with Trivy for container vulnerabilities in CI/CD pipeline

#### 3.2 Advanced Monitoring (Dependencies: 3.1)

- **Deploy ELK stack** for centralised logging with log aggregation and analysis capabilities
- **Configure distributed tracing** with Jaeger for request tracking across microservices
- **Set up alerting** with Prometheus alerts and notification channels

#### 3.3 Scaling and Performance (Dependencies: 3.2)

- **Configure Redis clustering** with persistence and replication for high availability
- **Implement horizontal pod autoscaling** with custom metrics and load-based scaling
- **Add load testing** with k6 scripts and performance regression detection

## Data Seeding and Initialisation Strategy

### Database Initialisation Order

```plaintext
1. PostgreSQL container starts with empty database
2. Init container runs TypeORM migrations to create schema
3. Seed script populates development data:
   - Test user accounts (admin@dice.local, user@dice.local)
   - Sample D&D characters for testing
   - Basic authentication tokens
4. PayloadCMS starts and connects to initialised database
5. CMS seed script populates:
   - D&D 3.0 races (Human, Elf, Dwarf, etc.)
   - D&D 3.0 classes (Fighter, Wizard, Rogue, etc.)
   - Ability scores and modifiers lookup tables
   - Spells and equipment data (Phase 2+)
```

### Development Data Structure

```typescript
// Example seed data in scripts/seed-data/
interface DevUser {
  email: "admin@dice.local" | "user@dice.local"
  password: "dice_dev_password"
  role: "admin" | "user"
}

interface DevCharacter {
  name: "Test Fighter" | "Sample Wizard"
  race: "Human" | "Elf"
  class: "Fighter" | "Wizard"
  level: 1
  abilityScores: { str: 16, dex: 14, con: 15, int: 12, wis: 13, cha: 10 }
}
```

## Database Migration and Schema Management

### Migration Strategy for Development

```plaintext
1. TypeORM migrations run automatically on backend startup
2. Development seed data reapplied after schema changes
3. PayloadCMS schema updates synchronised with backend changes
4. Shared TypeScript types regenerated after database changes
```

### Rollback Procedures

- **Schema Rollback**: `npm run migration:revert` in backend container
- **Data Rollback**: Restore from `data/postgres-backup/` volume snapshots
- **Full Environment Reset**: `make clean && make start-all`

## Inter-Service Authentication Strategy

### Development Authentication (Phase 1-2)

```yaml
# Simple shared secrets for development
BACKEND_API_KEY: "dice_dev_api_key_2024"
CMS_API_KEY: "dice_cms_api_key_2024"
INTERNAL_JWT_SECRET: "dice_internal_jwt_secret_dev"
```

### Service Communication Security

- **Backend ↔ PayloadCMS**: Shared API key authentication
- **PWA ↔ Backend**: JWT token-based authentication
- **Flutter ↔ Backend**: GraphQL with JWT authentication
- **Internal Services**: Basic API key validation

## Data Persistence and Backup Strategy

### Development Data Management

```plaintext
# Docker volume structure
./data/postgres/          # PostgreSQL data persistence
./data/redis/             # Redis data persistence  
./data/localstack/        # LocalStack state persistence
./data/uploads/           # PayloadCMS file uploads
./data/backups/           # Automated backups twice-a-day
```

### Backup Procedures

- **Daily Automated Backup**: PostgreSQL dump to `data/backups/daily/`
- **Pre-Migration Backup**: Automatic backup before schema changes
- **Manual Backup**: `make backup-db` command available
- **Restore Process**: `make restore-db BACKUP=<filename>` command

## Troubleshooting Guide

### Common Development Issues

#### Service Won't Start

```bash
# Check service logs
docker-compose logs backend
docker-compose logs postgres

# Reset specific service
docker-compose restart backend
docker-compose up --force-recreate postgres
```

#### Database Connection Issues

```bash
# Verify PostgreSQL health
docker-compose exec postgres pg_isready
docker-compose exec postgres psql -U dice_user -d dice_db -c "SELECT version();"

# Reset database completely
make clean-db && make start-db
```

#### Hot Reload Not Working

```bash
# Check file watching
docker-compose logs backend | grep "File change detected"

# Restart with fresh volumes
docker-compose down -v && docker-compose up
```

#### SSL Certificate Issues

```bash
# Check Traefik dashboard
open https://traefik.dice.local:8080

# Verify certificate generation
docker-compose logs traefik | grep "certificate"
```

## Phase-Specific Rollback Procedures

### Phase 1 Rollback (Minimal Viable Development)

#### Complete Phase Rollback

```bash
# Stop all services and remove containers
docker-compose down -v --remove-orphans

# Remove generated configurations
rm -rf data/ certs/ .env.development

# Reset to clean state
git checkout HEAD -- docker-compose.yml Makefile
git clean -fd
```

#### Partial Component Rollback

```bash
# Rollback specific service
docker-compose stop backend
docker-compose rm -f backend
docker-compose up -d backend

# Rollback database only
docker-compose stop postgres
docker volume rm dice_postgres_data
docker-compose up -d postgres
```

### Phase 2 Rollback (Enhanced Development)

#### Monitoring Stack Rollback

```bash
# Remove monitoring services
docker-compose stop prometheus grafana
docker-compose rm -f prometheus grafana
docker volume rm dice_prometheus_data dice_grafana_data

# Update compose file to remove monitoring
git checkout HEAD~1 -- docker-compose.yml
```

#### PayloadCMS Rollback

```bash
# Stop CMS and remove data
docker-compose stop payloadcms
docker-compose rm -f payloadcms
docker volume rm dice_cms_uploads

# Revert database to pre-CMS state
make restore-db BACKUP=pre-cms-migration
```

### Phase 3 Rollback (Production-Ready)

#### Vault Rollback

```bash
# Stop Vault and remove secrets
docker-compose stop vault
docker-compose rm -f vault
docker volume rm dice_vault_data

# Revert to .env file configuration
cp .env.development.backup .env.development
```

#### ELK Stack Rollback

```bash
# Stop logging services
docker-compose stop elasticsearch logstash kibana
docker-compose rm -f elasticsearch logstash kibana
docker volume rm dice_elasticsearch_data

# Revert to simple stdout logging
git checkout HEAD~3 -- docker-compose.yml
```

#### Redis Clustering Rollback

```bash
# Stop Redis cluster
docker-compose stop redis-master redis-replica redis-sentinel

# Start single Redis instance
docker-compose up -d redis
```

### Emergency Full Rollback

#### Nuclear Option - Complete Reset

```bash
#!/bin/bash
# emergency-reset.sh

# Stop everything
docker-compose down -v --remove-orphans
docker system prune -af --volumes

# Remove all project data
rm -rf data/ certs/ logs/ backups/
rm -f .env.* docker-compose.override.yml

# Reset git to clean state
git reset --hard HEAD
git clean -fdx

# Restart from Phase 1
make phase1-setup
```

#### Backup Current State Before Rollback

```bash
# Create rollback point
make create-rollback-point PHASE=current

# List available rollback points
make list-rollback-points

# Rollback to specific point
make rollback-to-point POINT=phase2-stable
```

## DevContainer Strategy (VS Code Native Support)

### Root DevContainer (.devcontainer/devcontainer.json)

```json
{
  "name": "DICE Development Environment",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "devcontainer",
  "workspaceFolder": "/workspace",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {
      "version": "latest",
      "kubectl": "1.33",
      "helm": "3.16"
    }
  },
  "postCreateCommand": "scripts/setup-dev-environment.sh",
  "forwardPorts": [3001, 3000, 3002, 5432, 6379, 8080],
  "portsAttributes": {
    "3001": {"label": "Backend API", "onAutoForward": "notify"},
    "3000": {"label": "PWA Frontend", "onAutoForward": "openBrowser"},
    "3002": {"label": "PayloadCMS", "onAutoForward": "notify"},
    "8080": {"label": "Traefik Dashboard", "onAutoForward": "notify"}
  }
}
```

### Workspace-Specific DevContainers

- **Backend**: Extends root with Node.js debugging, TypeScript support
- **PWA**: Extends root with Astro CLI, browser debugging tools
- **Shared**: Extends root with Storybook, component library tools

### Opening Strategy

1. **Full Development**: Open root folder in VS Code DevContainer
2. **Backend Only**: Open `workspace/backend` folder in its DevContainer
3. **Frontend Only**: Open `workspace/pwa` folder in its DevContainer
4. **Multi-Window**: Open multiple VS Code windows for parallel development

## SSL Certificate Management Solution

### Certificate Generation with Traefik

```yaml
# docker-compose.yml - Traefik service configuration
traefik:
  image: traefik:v3.0
  command:
    - "--api.dashboard=true"
    - "--providers.docker=true"
    - "--entrypoints.web.address=:80"
    - "--entrypoints.websecure.address=:443"
    - "--certificatesresolvers.selfsigned.acme.tlschallenge=true"
    - "--certificatesresolvers.selfsigned.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
  labels:
    - "traefik.http.routers.api.rule=Host(`traefik.dice.local`)"
    - "traefik.http.routers.api.tls=true"
    - "traefik.http.routers.api.tls.certresolver=selfsigned"
```

### Service SSL Configuration Example

```yaml
# Backend service with automatic SSL
backend:
  image: dice/backend:latest
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.backend.rule=Host(`api.dice.local`)"
    - "traefik.http.routers.backend.tls=true"
    - "traefik.http.routers.backend.tls.certresolver=selfsigned"
    - "traefik.http.services.backend.loadbalancer.server.port=3001"
```

### Development SSL Setup

```plaintext
# Automatic SSL certificate generation
1. Traefik automatically generates self-signed certificates for *.dice.local
2. Developer adds dice.local domains to /etc/hosts
3. Browser accepts self-signed certificates for development
4. No manual certificate management required
```

## Phase-Based Validation Checkpoints

### Phase 1 Validation (Minimal Viable Development)

- [ ] All services start in correct dependency order (PostgreSQL → Redis → Backend → PWA)
- [ ] Backend accessible at <https://api.dice.local> with valid SSL certificate
- [ ] PWA accessible at <https://pwa.dice.local> with service worker registration
- [ ] Database connections working with sample data seeded successfully
- [ ] Hot reload functioning for backend (< 8 seconds) and PWA (< 5 seconds)
- [ ] Health check endpoints responding: `/health`, `/ready`, `/metrics`
- [ ] GraphQL playground accessible with basic queries working
- [ ] MirageJS mocks allowing frontend development without backend
- [ ] Individual services startable: `make start-backend`, `make start-frontend`
- [ ] DevContainer opening successfully with all Kubernetes tools available

### Phase 2 Validation (Enhanced Development Experience)

- [ ] Prometheus collecting metrics from all services
- [ ] Grafana dashboards showing service health and resource usage
- [ ] PayloadCMS accessible at <https://cms.dice.local> with D&D rules data populated
- [ ] Shared TypeScript types working across backend, PWA, and CMS
- [ ] Pre-commit hooks preventing bad code: linting, formatting, TypeScript errors
- [ ] Skaffold hot reload optimised with intelligent rebuilds
- [ ] All Makefile commands working: test, debug, clean, reset
- [ ] Independent service modes working: backend-only, frontend-only, full-stack

### Phase 3 Validation (Production-Ready Features)

- [ ] HashiCorp Vault managing secrets with automatic rotation
- [ ] ELK stack aggregating logs from all services
- [ ] Jaeger tracing requests across microservices
- [ ] Redis clustering with persistence and failover
- [ ] Security scanning passing for all containers
- [ ] Load testing scenarios completing with performance baselines
- [ ] Horizontal pod autoscaling working with custom metrics

## Implementation Status Tracking

### IMPLEMENTATION_STATUS.md Structure

```markdown
# DICE Infrastructure Implementation Status

## Current Phase: 1 (Minimal Viable Development)
**Last Updated**: YYYY-MM-DD  
**Overall Progress**: X/Y tasks completed

### Phase 1 Progress
- [x] 1.1 Foundation Setup (4/4 tasks)
- [ ] 1.2 Data Layer Setup (1/3 tasks)
- [ ] 1.3 Service Communication (0/1 tasks)
- [ ] 1.4 Backend Service (0/4 tasks)
- [ ] 1.5 PWA Frontend (0/4 tasks)

### Current Blockers
- Issue with PostgreSQL persistent volume permissions
- Need to resolve SSL certificate mounting in containers

### Next Steps
1. Fix PostgreSQL volume mounting with proper user permissions
2. Test service-to-service communication with example URLs
3. Implement basic health check endpoints

### Completed Features
- Root devcontainer with Kubernetes tools
- SSL certificate generation with mkcert
- Basic Kubernetes manifests structure

### Known Issues
- Hot reload performance needs optimisation
- DevContainer memory usage higher than expected
```

## Official Documentation URLs

### Core Technologies

- **Rancher Desktop**: <https://docs.rancherdesktop.io/>
- **Kubernetes**: <https://kubernetes.io/docs/>
- **Devcontainers**: <https://containers.dev/>
- **Testcontainers**: <https://testcontainers.com/>
- **Localstack**: <https://docs.localstack.cloud/>
- **Traefik**: <https://doc.traefik.io/traefik/>
- **mkcert**: <https://github.com/FiloSottile/mkcert>
- **Helm**: <https://helm.sh/docs/>
- **Skaffold**: <https://skaffold.dev/docs/>

### Application Stack

- **Nest.js**: <https://docs.nestjs.com/>
- **Astro.js**: <https://docs.astro.build/>
- **PayloadCMS**: <https://payloadcms.com/docs>
- **PostgreSQL**: <https://www.postgresql.org/docs/>
- **Redis**: <https://redis.io/docs/>
- **GraphQL**: <https://graphql.org/learn/>
- **tRPC**: <https://trpc.io/docs>

### Monitoring & Security

- **Prometheus**: <https://prometheus.io/docs/>
- **Grafana**: <https://grafana.com/docs/>
- **Jaeger**: <https://www.jaegertracing.io/docs/>
- **HashiCorp Vault**: <https://developer.hashicorp.com/vault/docs>
- **Trivy**: <https://aquasecurity.github.io/trivy/>
- **cert-manager**: <https://cert-manager.io/docs/>

### Development Tools

- **pnpm**: <https://pnpm.io/>
- **Volta**: <https://volta.sh/>
- **TailwindCSS**: <https://tailwindcss.com/docs>
- **Storybook**: <https://storybook.js.org/docs>
- **MirageJS**: <https://miragejs.com/docs/>
- **k6**: <https://k6.io/docs/>

## Architecture Overview (Phase-Based Implementation)

### Phase 1: Core Services

```mermaid
graph TB
    subgraph "Developer Setup"
        RD["Rancher Desktop + K8s"]
        CERT["mkcert *.dice.local"]
        DNS["/etc/hosts entries"]
    end

    subgraph "Kubernetes Cluster - Phase 1"
        subgraph "Ingress"
            TRAEFIK["Traefik Ingress<br/>SSL Termination"]
        end
        
        subgraph "Data Layer"
            POSTGRES[("PostgreSQL<br/>Development DB")]
            REDIS[("Redis<br/>Session Store")]
            LOCALSTACK["Localstack<br/>AWS Simulation"]
        end
        
        subgraph "Application Services"
            BACKEND["Nest.js Backend<br/>GraphQL Federation<br/>+ tRPC"]
            PWA["Astro.js PWA<br/>+ MirageJS Mocks"]
        end
    end

    subgraph "DevContainers"
        ROOT_DC["Root: K8s Tools"]
        BACKEND_DC["Backend: Node.js Debug"]
        PWA_DC["PWA: Astro CLI"]
    end

    subgraph "Development URLs"
        API_URL["https://api.dice.local"]
        PWA_URL["https://pwa.dice.local"]
    end

    RD --> TRAEFIK
    CERT --> TRAEFIK
    TRAEFIK --> API_URL
    TRAEFIK --> PWA_URL
    API_URL --> BACKEND
    PWA_URL --> PWA
    BACKEND --> POSTGRES
    BACKEND --> REDIS
    BACKEND --> LOCALSTACK
```

### Phase 2: Enhanced Development

```mermaid
graph TB
    subgraph "Added in Phase 2"
        CMS["PayloadCMS<br/>D&D Rules Data"]
        PROMETHEUS["Prometheus<br/>Metrics"]
        GRAFANA["Grafana<br/>Dashboards"]
    end
    
    subgraph "Additional URLs"
        CMS_URL["https://cms.dice.local"]
        MONITOR_URL["https://monitoring.dice.local"]
    end
    
    CMS --> POSTGRES
    PROMETHEUS --> BACKEND
    PROMETHEUS --> PWA
    PROMETHEUS --> CMS
```

### Service Startup Dependencies

```mermaid
graph TD
    A[PostgreSQL] --> C[Backend Service]
    A --> E[PayloadCMS]
    B[Redis] --> C
    C -.-> D[PWA Service]
    F[Monitoring Stack] -.-> C
    F -.-> D
    F -.-> E
    
    style A fill:#e1f5fe
    style B fill:#e8f5e8
    style C fill:#fff3e0
    style D fill:#fce4ec
    style E fill:#f3e5f5
    style F fill:#e0f2f1
```

---

## Summary of Key Improvements

### ✅ **Addressed Major Issues**

- **Clear Technology Choice**: Docker Compose for local development, Kubernetes for production
- **Phased Implementation**: Start minimal, add complexity progressively
- **Realistic Resource Requirements**: ~6-8GB RAM for Phase 1, ~10-12GB for full stack
- **Clear Service Dependencies**: PostgreSQL → Backend, PayloadCMS → Backend, Redis → Backend
- **VS Code Native DevContainer Support**: Proper hierarchy with workspace-specific containers

### ✅ **Technical optimisations**

- **Stable Base Images**: `node:22-bullseye`, `postgres:17-bullseye`, `redis:7-bullseye`
- **Hot Reload optimisation**: optimised volume mounts and file watching
- **SSL Certificate Automation**: mkcert with Kubernetes secret mounting
- **Development vs Production Split**: `.env` files vs Vault, simple logging vs ELK
- **Independent Service Startup**: Individual services can run independently

### ✅ **Clear Development Workflow**

```bash
# Phase 1 - Basic Development
make start-all          # Full stack
make start-backend      # Backend + Database only
make start-frontend     # PWA with mocks only

# Phase 2 - Enhanced Development  
make start-monitoring   # Add Prometheus + Grafana
make debug-backend      # Debug mode with breakpoints
make test               # Run test suites
```

### ✅ **Progressive Complexity**

- **Phase 1** (2-3 weeks): Basic development environment working
- **Phase 2** (1-2 weeks): Enhanced developer experience and tools
- **Phase 3** (1-2 weeks): Production-ready features and scaling

### ✅ **Continuous Tracking**

- `IMPLEMENTATION_STATUS.md` maintains current progress
- Phase-based validation checkpoints ensure quality
- Clear next steps and blocker identification

**This phased approach ensures a working development environment quickly while building toward production-ready infrastructure systematically.**
