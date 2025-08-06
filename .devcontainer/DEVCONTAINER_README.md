# DICE DevContainer Development Environment

**Version**: 3.2 - Security Hardened Distributed Architecture with ELK Logging  
**Last Updated**: July 29, 2025  
**Status**: ✅ Production Ready

This directory contains the DevContainer configuration for the **DICE D&D Character Management System**. The DevContainer provides a complete, isolated development environment with all necessary services and tools pre-configured.

## 🏗️ Architecture Overview

The DevContainer environment includes:

- **Backend API** (NestJS + TypeScript + JWT Authentication)
- **PWA Frontend** (Astro.js + React + Tailwind CSS + Encrypted Storage)
- **Component Library** (Storybook + Design System)
- **Workflow Engine** (Temporal.io + Secure Workflows)
- **Database** (PostgreSQL 16 + Encrypted Connections)
- **Cache** (Redis 7 + Session Management)
- **AWS Services** (LocalStack + Security Simulation)
- **Reverse Proxy** (Traefik + SSL Termination)
- **Distributed Logging** (ELK Stack + Centralized Log Analysis)

## 📋 Requirements

- [Docker Desktop](https://www.docker.com/get-started) or [Rancher Desktop](https://rancherdesktop.io/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## 🚀 Quick Start

### 1. Prepare the Environment

Run the setup script to configure the DevContainer for your system:

```bash
# From the project root
./infrastructure/scripts/setup-devcontainer.sh
```

This script will:

- Configure user permissions dynamically (UID/GID detection)
- Create necessary environment files using the unified setup system
- Set up directory structure with standardised permissions
- Validate Docker Compose configuration across distributed files
- Generate cryptographically secure secrets automatically
- Perform Docker and dependency validation

**Note**: The setup process now uses our unified script architecture, which eliminates duplication and provides consistent environment management across development, DevContainer, and production environments with enterprise-grade security.

### 2. Open in DevContainer

1. Open the project in VS Code
2. Install the **Dev Containers** extension if not already installed
3. Use the command palette (`Cmd/Ctrl + Shift + P`)
4. Run: **Dev Containers: Reopen in Container**
5. Wait for the environment to build and start (first time may take 5-10 minutes)

### 3. Verify Services

Once the container is running, all services should be available:

| Service               | URL                                            | Purpose                                            |
| --------------------- | ---------------------------------------------- | -------------------------------------------------- |
| **Backend API**       | [http://localhost:3001](http://localhost:3001) | NestJS REST API with JWT auth + health endpoints   |
| **PWA Frontend**      | [http://localhost:3000](http://localhost:3000) | Character management interface (encrypted storage) |
| **Storybook**         | [http://localhost:6006](http://localhost:6006) | Component library playground                       |
| **Temporal UI**       | [http://localhost:8088](http://localhost:8088) | Workflow monitoring dashboard                      |
| **Traefik Dashboard** | [http://localhost:8080](http://localhost:8080) | Reverse proxy management                           |
| **Elasticsearch**     | [http://localhost:9200](http://localhost:9200) | Log storage and search engine                      |
| **Kibana**            | [http://localhost:5601](http://localhost:5601) | Log visualization and analytics dashboard          |

### Debug Ports

| Service      | Debug Port | Protocol          | Description            |
| ------------ | ---------- | ----------------- | ---------------------- |
| **Backend**  | 9229       | Node.js Inspector | NestJS debugging       |
| **Frontend** | 9222       | Chrome DevTools   | React/Astro debugging  |
| **Frontend** | N/A        | Browser DevTools  | Manual debugging (F12) |

### 4. Validate Security & Health

```bash
# Comprehensive health check
./infrastructure/scripts/health-check.sh

# Test authentication system
./infrastructure/scripts/test-auth.sh

# Start ELK logging stack (optional - for distributed logging)
docker-compose -f infrastructure/docker/logging-stack.yml --profile logging up -d
```

## 🔧 Configuration Files

### Core Configuration

- **`devcontainer.json`** - Main DevContainer configuration (simplified for backend development)
- **`../workspace/backend/docker-compose.yml`** - Backend services (focus on development needs)
- **`../.env`** - Unified environment variables (shared with all development workflows)
- **`../infrastructure/scripts/setup-devcontainer.sh`** - Environment preparation script (simplified)

### Key Features

#### Simplified DevContainer Architecture

The DevContainer uses a focused approach for backend development:

```json
"dockerComposeFile": [
  "../workspace/backend/docker-compose.yml"
]
```

This simplified approach provides:

- **Focused development** - Backend services only for efficient development
- **Faster startup** - Reduced overhead with only necessary services
- **Clear boundaries** - Development container focused on backend API work
- **Unified environment** - Single `.env` file shared across all workflows

#### Dynamic User Configuration

The setup automatically detects your host user ID and group ID to prevent permission issues:

```bash
# Automatically set in .env
DOCKER_USER=502    # Your host UID
DOCKER_GROUP=20    # Your host GID
```

#### Port Forwarding

All development ports are automatically forwarded:

```json
"forwardPorts": [
  3001,  // Backend API (JWT protected)
  3000,  // PWA Frontend (encrypted storage)
  6006,  // Storybook Component Library
  5432,  // PostgreSQL (encrypted connections)
  6379,  // Redis (session management)
  7233,  // Temporal gRPC
  8080,  // Traefik Dashboard
  8088,  // Temporal Web UI
  4566,  // LocalStack AWS Services
  9200,  // Elasticsearch (log storage)
  5601   // Kibana (log visualization)
]
```

#### VS Code Extensions

Pre-configured development tools for enterprise development:

- **Language Support**: TypeScript, ESLint, Prettier
- **Framework Support**: Astro, Tailwind CSS, NestJS
- **DevOps Tools**: Docker, YAML support
- **Development Tools**: Thunder Client, Spell Checker
- **Temporal**: Official Temporal extension
- **Security**: GitHub Copilot (if available)

## 🛠️ Development Workflow

### Starting Development

Once inside the DevContainer:

```bash
# Backend development
cd /app  # You're already in the backend workspace
pnpm run start:dev

# PWA development (new terminal)
cd ../pwa
pnpm run dev

# Storybook (new terminal)  
cd ../pwa
pnpm run storybook

# ELK logging stack (optional - for distributed logging)
docker-compose -f infrastructure/docker/logging-stack.yml --profile logging up -d
```

### Running Tests

```bash
# Backend tests (with database)
cd /app
pnpm test

# PWA tests (isolated)
cd ../pwa
pnpm test

# Authentication system test
./infrastructure/scripts/test-auth.sh
```

### Database Operations

```bash
# Access PostgreSQL (with encryption)
docker exec -it backend_postgres_dev psql -U dice_user -d dice_db

# Check Redis (session store)
docker exec -it backend_redis_dev redis-cli

# Monitor connections
docker exec -it backend_postgres_dev psql -U dice_user -d dice_db -c "SELECT * FROM pg_stat_activity;"
```

### Temporal Workflows

```bash
# Access Temporal CLI
docker exec -it backend_temporal_dev temporal workflow list

# Check workflow history
docker exec -it backend_temporal_dev temporal workflow show --workflow_id <ID>

# Or use the Web UI at http://localhost:8088

### Distributed Logging (ELK Stack)

```bash
# Start ELK logging stack (optional but recommended)
docker-compose -f infrastructure/docker/logging-stack.yml --profile logging up -d

# Check Elasticsearch health
curl -X GET "localhost:9200/_cluster/health?pretty"

# Access Kibana dashboard
open http://localhost:5601

# View application logs in Kibana
# Navigate to Discover → Create index pattern: dice-logs-*

# Check log ingestion
curl -X GET "localhost:9200/_cat/indices?v" | grep dice-logs

# Stop ELK stack
docker-compose -f infrastructure/docker/logging-stack.yml --profile logging down
```

### LocalStack AWS Services

Set up sample D&D data for development:

```bash
# Using the unified LocalStack setup script (containerised method)
./infrastructure/scripts/setup-localstack.sh

# Or specify method explicitly
./infrastructure/scripts/setup-localstack.sh --method container

# Host method (requires AWS CLI)
./infrastructure/scripts/setup-localstack.sh --method host
```

This consolidated script replaces the previous duplicate scripts and provides:

- **Single script** for both host and containerised AWS CLI
- **Consistent data setup** across all environments
- **Better error handling** and validation
- **Sample D&D data** (characters, campaigns, rules, assets)

## 🔍 Troubleshooting

### Container Won't Start

1. **Check Docker daemon**: Ensure Docker Desktop is running
2. **Check permissions**: Run the setup script again
3. **Clear caches**: Remove old containers and volumes

```bash
docker system prune -a
docker volume prune
```

### Permission Issues

The setup script should handle permissions automatically, but if you encounter issues:

```bash
# Check your user ID
id -u && id -g

# Re-run the setup script which will regenerate the environment
./infrastructure/scripts/setup-devcontainer.sh
```

### Service Connection Issues

```bash
# Check service health using our orchestrator
./infrastructure/scripts/docker-orchestrator.sh status

# Check individual service logs
docker logs backend_backend_dev
docker logs backend_temporal_dev
docker logs pwa_pwa_dev

# Comprehensive health check
./infrastructure/scripts/health-check.sh

# Check ELK stack status (if running)
docker-compose -f infrastructure/docker/logging-stack.yml --profile logging ps
```

### Environment Configuration Issues

If you need to regenerate environment files:

```bash
# Regenerate DevContainer environment (with fresh secrets)
./infrastructure/scripts/setup-environment.sh --type devcontainer --force

# Regenerate development environment  
./infrastructure/scripts/setup-environment.sh --type development --force
```

### Authentication Issues

```bash
# Test JWT authentication system
./infrastructure/scripts/test-auth.sh

# Check backend health with auth validation
curl -f http://localhost:3001/health

# Verify secure storage in PWA
# Open browser dev tools → Application → Local Storage
```

### Port Conflicts

If ports are already in use on your host:

1. **Check what's using ports**: `lsof -i :3001 -i :3000 -i :5432`
2. **Stop conflicting services** or modify port mappings in compose files
3. **Update devcontainer.json** port forwarding accordingly

## 📚 Additional Resources

### Development Guides

- [Backend API Documentation](../workspace/backend/README.md)
- [PWA Development Guide](../workspace/pwa/README.md)
- [Component Library Guide](../workspace/pwa/src/stories/DesignSystem.mdx)

### Service Documentation

- [Services Guide](../SERVICES_GUIDE.md) - Comprehensive service management with logging
- [Security Quality Tracker](../SECURITY_QUALITY_TRACKER.md) - OWASP compliance with audit logging
- [Unified Logging Strategy](../infrastructure/logging/LOGGING_README.md) - Complete logging implementation
- [Unified Logging Plan](../DICE_UNIFIED_LOGGING_PLAN.md) - ELK stack and distributed logging architecture

### Infrastructure Documentation

- [Infrastructure Scripts Documentation](../infrastructure/scripts/) - Complete automation guide
- [Main Project README](../README.md) - Project overview and quick start

### Architecture Documentation

- [Project Architecture](../docs/ARCHITECTURE.md) (if available)
- [Database Schema](../docs/DATABASE.md) (if available)
- [API Documentation](../docs/API.md) (if available)

## 🧪 Script Architecture Improvements

The DevContainer now benefits from our unified script architecture:

### **Consolidated Scripts**

- **setup-devcontainer.sh** - Simplified DevContainer setup (63 lines, down from 99)
- **setup-environment.sh** - Unified environment management for all types
- **setup-localstack.sh** - Consolidated LocalStack setup (replaced 2 duplicate scripts)
- **common.sh** - Shared library with 28+ utility functions

### **Key Benefits**

- **35% less code** - Eliminated duplication across setup scripts
- **Unified secret generation** - Consistent security across environments
- **Better error handling** - Standardised messaging and validation
- **Easier maintenance** - Single source of truth for common functionality
- **Security enhancements** - Cryptographically secure secret generation
- **Cross-platform support** - Works on macOS, Linux, and Windows

## 🔐 Security Features

### **Enterprise-Grade Security**

- **JWT Authentication** - Secure token-based authentication system
- **Encrypted Storage** - AES encryption for client-side data
- **Rate Limiting** - Protection against brute-force attacks
- **OWASP Compliance** - Top 10 security practices implemented
- **Secure Secret Generation** - Cryptographically secure secrets
- **Input Validation** - Comprehensive input sanitization

### **Security Testing**

```bash
# Complete authentication flow test
./infrastructure/scripts/test-auth.sh

# Security health validation
./infrastructure/scripts/health-check.sh
```

## 🐛 Known Issues

### macOS Specific

- **File watching**: Some file change detection may be slow due to Docker Desktop limitations
- **Performance**: Consider allocating more resources to Docker Desktop (8GB+ RAM recommended)
- **Backend API access**: May not be accessible from host on port 3001 due to Docker networking
- **ELK stack startup**: Elasticsearch may take 10-30 seconds to reach GREEN status

### Windows Specific  

- **Line endings**: Ensure scripts use LF line endings (`git config core.autocrlf false`)
- **Path mapping**: Windows paths may need adjustment in volume mounts
- **Docker Desktop**: Ensure WSL2 backend is enabled for best performance

### Linux Specific

- **User mapping**: Should work seamlessly with proper UID/GID detection
- **Docker permissions**: Ensure user is in docker group (`sudo usermod -aG docker $USER`)

## 🤝 Contributing

When modifying the DevContainer configuration:

1. **Test changes** with a fresh container build
2. **Update this documentation** to reflect changes
3. **Ensure the setup script** handles new requirements
4. **Test on multiple platforms** if possible (macOS, Linux, Windows)
5. **Consider impact** on the unified script architecture
6. **Validate security** - ensure no security regressions
7. **Update version** and last modified date

## 📝 Notes

- The DevContainer is optimised for **development**, not production
- Services use **development-friendly configurations** (relaxed security, verbose logging)
- Data is **persisted in Docker volumes** between container restarts
- The backend service uses `sleep infinity` as the command - DevContainer will override this
- **Environment files are automatically generated** with secure secrets
- The **distributed Docker Compose architecture** provides better isolation and maintainability
- **Security features are enabled** even in development for realistic testing
- **Performance metrics**: Backend startup ~17.1s, PWA startup ~0.4s, ELK stack startup ~10-30s

---

**🎯 DevContainer Status**: ✅ **Ready for Enterprise Development** with **Security-Hardened Architecture**, **Unified Automation**, and **Comprehensive Monitoring**
