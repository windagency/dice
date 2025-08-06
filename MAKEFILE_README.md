# DICE Makefile Documentation

**Version**: 3.1 - Optimised Development Environment  
**Last Updated**: August 4, 2025  
**Status**: ✅ Production Ready

## 📋 **Overview**

The DICE Makefile provides a comprehensive interface for managing the distributed Docker development environment. It includes production startup, debug-enabled development workflows, comprehensive logging, testing, and validation capabilities.

---

## 🏗️ **Architecture Overview**

The Makefile is organized into logical sections that mirror the distributed architecture:

### **Section Structure**

```
├── HELP & SETUP                    # Basic setup and help
├── SERVICE STARTUP (Production)    # Standard service startup
├── SERVICE STARTUP WITH PROFILES   # Profile-based startup
├── DEVELOPMENT MODE (Debug)        # Debug-enabled development
├── ELK LOGGING STACK MANAGEMENT    # Logging infrastructure
├── SERVICE MANAGEMENT              # Stop, restart, clean
├── LOGGING & MONITORING           # Comprehensive logging
├── LOGGING MONITORING & TESTING   # Advanced logging features
├── TESTING & VALIDATION           # All testing scripts
├── HEALTH & STATUS                # Health checking
├── DATABASE MANAGEMENT            # Database operations
├── DEVELOPMENT WORKFLOWS          # Phase-specific workflows
├── UTILITY TARGETS               # Helper commands
├── QUICK ACCESS TARGETS          # One-command workflows
└── CLEANUP TARGETS               # Comprehensive cleanup
```

---

## 🚀 **Quick Start**

### **Basic Usage**

```bash
# Show all available commands
make help

# Quick development start with debug mode
make quick-dev

# Quick start with full stack
make quick-start

# Quick logging setup
make quick-logging
```

### **Development Workflows**

```bash
# Backend development with debug
make dev-backend

# Frontend development with debug
make dev-frontend

# Full stack development with debug
make dev-full

# Full stack with all debug features + logging
make dev-full-debug
```

---

## 📚 **Command Reference**

### **🔧 HELP & SETUP**

| Command              | Description                           | Usage                     |
| -------------------- | ------------------------------------- | ------------------------- |
| `help`               | Show all available commands           | `make help`               |
| `setup`              | Initial development environment setup | `make setup`              |
| `setup-devcontainer` | Setup DevContainer environment        | `make setup-devcontainer` |

### **🏭 SERVICE STARTUP (Production Mode)**

| Command          | Description                 | Usage                 |
| ---------------- | --------------------------- | --------------------- |
| `start-all`      | Start full integrated stack | `make start-all`      |
| `start-backend`  | Start backend services only | `make start-backend`  |
| `start-frontend` | Start PWA frontend only     | `make start-frontend` |

**Features:**
- Standard production startup
- No debug mode enabled
- Optimised for performance
- Health checks included

### **🎛️ SERVICE STARTUP WITH PROFILES**

| Command            | Description                        | Usage                   |
| ------------------ | ---------------------------------- | ----------------------- |
| `start-proxy`      | Full stack with Traefik proxy      | `make start-proxy`      |
| `start-monitoring` | Full stack with Prometheus/Grafana | `make start-monitoring` |
| `start-logging`    | Full stack with ELK logging        | `make start-logging`    |
| `start-aws`        | Full stack with LocalStack AWS     | `make start-aws`        |

**Available Profiles:**
- `--proxy` - Traefik reverse proxy
- `--monitoring` - Prometheus + Grafana
- `--logging` - ELK stack (Elasticsearch, Kibana, Fluent Bit)
- `--aws` - LocalStack AWS services

### **🔧 DEVELOPMENT MODE (Debug Enabled)**

| Command          | Description              | Debug Features                 | Usage                 |
| ---------------- | ------------------------ | ------------------------------ | --------------------- |
| `dev-backend`    | Backend with debug mode  | Port 9229, logs                | `make dev-backend`    |
| `dev-frontend`   | Frontend with debug mode | DevTools, Chrome Debug (9222)  | `make dev-frontend`   |
| `dev-full`       | Full stack with debug    | All debug ports, logs          | `make dev-full`       |
| `dev-full-debug` | Full stack + ELK + debug | Complete debug setup + logging | `make dev-full-debug` |

**Debug Features:**
- **Backend**: Node.js debugger on port 9229
- **Frontend**: Browser DevTools (F12) + Chrome Debug (port 9222)
- **Logging**: Real-time log streaming
- **ELK**: Centralised log analysis

### **📊 ELK LOGGING STACK MANAGEMENT**

| Command      | Description                  | Usage             |
| ------------ | ---------------------------- | ----------------- |
| `start-elk`  | Start ELK logging stack only | `make start-elk`  |
| `stop-elk`   | Stop ELK logging stack       | `make stop-elk`   |
| `status-elk` | Show ELK stack status        | `make status-elk` |

**ELK Stack Components:**
- **Elasticsearch**: Log storage and search (port 9200)
- **Kibana**: Log visualization dashboard (port 5601)
- **Fluent Bit**: Log collection and forwarding (port 2020)

### **⚙️ SERVICE MANAGEMENT**

| Command   | Description             | Usage          |
| --------- | ----------------------- | -------------- |
| `stop`    | Stop all services       | `make stop`    |
| `restart` | Restart all services    | `make restart` |
| `clean`   | Stop and remove volumes | `make clean`   |

### **📋 LOGGING & MONITORING**

| Command         | Description                          | Usage                |
| --------------- | ------------------------------------ | -------------------- |
| `logs`          | Show all service logs                | `make logs`          |
| `logs-backend`  | Show backend logs                    | `make logs-backend`  |
| `logs-pwa`      | Show PWA logs                        | `make logs-pwa`      |
| `logs-frontend` | Show frontend logs (PWA + Storybook) | `make logs-frontend` |
| `logs-temporal` | Show Temporal logs                   | `make logs-temporal` |
| `logs-elk`      | Show ELK stack logs                  | `make logs-elk`      |
| `logs-database` | Show database logs                   | `make logs-database` |
| `logs-aws`      | Show LocalStack AWS logs             | `make logs-aws`      |
| `logs-proxy`    | Show Traefik proxy logs              | `make logs-proxy`    |
| `logs-all`      | Show all service logs                | `make logs-all`      |

### **🔍 LOGGING MONITORING & TESTING**

| Command                    | Description                    | Usage                           |
| -------------------------- | ------------------------------ | ------------------------------- |
| `monitor-logs`             | Real-time log monitoring       | `make monitor-logs`             |
| `monitor-logs-security`    | Security events monitoring     | `make monitor-logs-security`    |
| `monitor-logs-performance` | Performance metrics monitoring | `make monitor-logs-performance` |
| `test-logging`             | Test logging pipeline          | `make test-logging`             |
| `setup-logging`            | Setup and configure ELK        | `make setup-logging`            |
| `export-logs`              | Export recent logs             | `make export-logs`              |

### **🧪 TESTING & VALIDATION**

| Command           | Description                  | Usage                  |
| ----------------- | ---------------------------- | ---------------------- |
| `test`            | Run all tests                | `make test`            |
| `test-auth`       | Test JWT authentication      | `make test-auth`       |
| `test-validation` | Run comprehensive validation | `make test-validation` |
| `test-localstack` | Test LocalStack AWS services | `make test-localstack` |

### **🏥 HEALTH & STATUS**

| Command           | Description                | Usage                  |
| ----------------- | -------------------------- | ---------------------- |
| `status`          | Show service status        | `make status`          |
| `health`          | Check all service health   | `make health`          |
| `health-backend`  | Check backend health only  | `make health-backend`  |
| `health-frontend` | Check frontend health only | `make health-frontend` |
| `health-elk`      | Check ELK stack health     | `make health-elk`      |

### **🗄️ DATABASE MANAGEMENT**

| Command      | Description                  | Usage                             |
| ------------ | ---------------------------- | --------------------------------- |
| `backup-db`  | Backup PostgreSQL database   | `make backup-db`                  |
| `restore-db` | Restore database from backup | `make restore-db BACKUP=filename` |

### **🔄 DEVELOPMENT WORKFLOWS**

| Command       | Description             | Usage              |
| ------------- | ----------------------- | ------------------ |
| `phase1`      | Complete Phase 1 setup  | `make phase1`      |
| `phase1-full` | Phase 1 with full stack | `make phase1-full` |

### **🛠️ UTILITY TARGETS**

| Command              | Description                          | Usage                     |
| -------------------- | ------------------------------------ | ------------------------- |
| `debug-backend`      | Start backend in debug mode (legacy) | `make debug-backend`      |
| `validate`           | Validate all infrastructure          | `make validate`           |
| `setup-aws`          | Setup LocalStack with sample data    | `make setup-aws`          |
| `setup-devcontainer` | Setup DevContainer environment       | `make setup-devcontainer` |

### **⚡ QUICK ACCESS TARGETS**

| Command         | Description                  | Usage                |
| --------------- | ---------------------------- | -------------------- |
| `quick-start`   | Setup + start + health check | `make quick-start`   |
| `quick-dev`     | Setup + debug mode + health  | `make quick-dev`     |
| `quick-logging` | ELK setup + config + health  | `make quick-logging` |

### **🧹 CLEANUP TARGETS**

| Command      | Description                   | Usage             |
| ------------ | ----------------------------- | ----------------- |
| `clean-all`  | Clean all including ELK stack | `make clean-all`  |
| `clean-logs` | Clean log data only           | `make clean-logs` |

---

## 🎯 **Common Workflows**

### **1. New Developer Setup**

```bash
# Complete setup for new developer
make quick-dev

# This runs: setup → dev-full → health
# Result: Complete development environment with debug mode
```

### **2. Backend Development**

```bash
# Start backend with debug mode
make dev-backend

# Features:
# - Backend API on localhost:3001
# - Debug port on localhost:9229
# - PostgreSQL on localhost:5432
# - Redis on localhost:6379
# - Temporal UI on localhost:8088
```

### **3. Frontend Development**

```bash
# Start frontend with debug mode
make dev-frontend

# Features:
# - PWA on localhost:3000
# - Storybook on localhost:6006
# - Browser DevTools (F12)
# - Real-time logs
```

### **4. Full-Stack Development**

```bash
# Start complete stack with debug
make dev-full

# Features:
# - All services running
# - Debug ports available
# - Real-time logs
# - Health monitoring
```

### **5. Enterprise Development**

```bash
# Start with all features including logging
make dev-full-debug

# Features:
# - Complete stack with debug
# - ELK logging stack
# - Security monitoring
# - Performance tracking
# - Centralised log analysis
```

### **6. Testing & Validation**

```bash
# Test authentication system
make test-auth

# Validate entire infrastructure
make validate

# Test LocalStack AWS services
make test-localstack
```

### **7. Logging & Monitoring**

```bash
# Start ELK stack
make start-elk

# Monitor logs in real-time
make monitor-logs

# Monitor security events
make monitor-logs-security

# Test logging pipeline
make test-logging
```

---

## 🔧 **Advanced Usage**

### **Environment Variables**

The Makefile uses these key variables:

```makefile
ORCHESTRATOR_SCRIPT := ./infrastructure/scripts/docker-orchestrator.sh
BACKUP_DIR := ./infrastructure/data/backups
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)
```

### **Container Names**

The Makefile uses the correct development container names:

- `backend_postgres_dev` - PostgreSQL database
- `backend_redis_dev` - Redis cache
- `backend_temporal_dev` - Temporal workflow engine
- `backend_localstack_dev` - LocalStack AWS services
- `pwa_dev` - PWA frontend container

### **Port Mappings**

| Service       | Port | Description        |
| ------------- | ---- | ------------------ |
| Backend API   | 3001 | NestJS REST API    |
| PWA Frontend  | 3000 | Astro + React PWA  |
| Storybook     | 6006 | Component library  |
| Temporal UI   | 8088 | Workflow dashboard |
| PostgreSQL    | 5432 | Database           |
| Redis         | 6379 | Cache              |
| Elasticsearch | 9200 | Log storage        |
| Kibana        | 5601 | Log dashboard      |
| Fluent Bit    | 2020 | Log metrics        |
| LocalStack    | 4566 | AWS services       |

### **Debug Ports**

| Service  | Debug Port | Description              |
| -------- | ---------- | ------------------------ |
| Backend  | 9229       | Node.js debugger         |
| Frontend | 9222       | Chrome DevTools Protocol |
| Frontend | N/A        | Browser DevTools (F12)   |

---

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. Services Not Starting**

```bash
# Check service status
make status

# Check health
make health

# View logs
make logs-all
```

#### **2. Debug Mode Not Working**

```bash
# Use development mode targets
make dev-backend    # Instead of start-backend
make dev-frontend   # Instead of start-frontend
make dev-full       # Instead of start-all
```

#### **3. Logging Issues**

```bash
# Check ELK stack health
make health-elk

# View ELK logs
make logs-elk

# Test logging pipeline
make test-logging
```

#### **4. Database Issues**

```bash
# Check database health
make health-backend

# View database logs
make logs-database

# Backup database
make backup-db
```

### **Cleanup Procedures**

```bash
# Clean everything and start fresh
make clean-all

# Clean only logs
make clean-logs

# Restart all services
make restart
```

---

## 📊 **Performance Metrics**

### **Startup Times**

| Target           | Services | Startup Time | Memory Usage |
| ---------------- | -------- | ------------ | ------------ |
| `start-backend`  | 5        | ~17.1s       | ~850MB       |
| `start-frontend` | 1        | ~0.4s        | ~180MB       |
| `start-all`      | 7-8      | ~17.8s       | ~1.6GB       |
| `start-elk`      | 3-4      | ~10-30s      | ~500MB       |

### **Resource Savings**

| Mode          | Savings  | Use Case         |
| ------------- | -------- | ---------------- |
| Backend Only  | 47%      | API development  |
| Frontend Only | 89%      | UI development   |
| Full Stack    | Baseline | Integration work |

---

## 🔐 **Security Features**

### **Development Mode Security**

- **JWT Authentication**: All API endpoints protected
- **Debug Mode**: Secure debugging with proper isolation
- **Logging**: Security events logged and monitored
- **Health Checks**: Comprehensive security validation

### **Production Mode Security**

- **OWASP Compliance**: Top 10 security practices
- **Encrypted Storage**: Client-side AES encryption
- **Rate Limiting**: Protection against attacks
- **Input Validation**: Comprehensive sanitization

---

## 📚 **Related Documentation**

- **[SERVICES_GUIDE.md](SERVICES_GUIDE.md)** - Comprehensive service management
- **[SECURITY_QUALITY_TRACKER.md](SECURITY_QUALITY_TRACKER.md)** - OWASP compliance tracking
- **[DevContainer README](.devcontainer/DEVCONTAINER_README.md)** - DevContainer setup
- **[Infrastructure Scripts](../infrastructure/scripts/SCRIPTS_README.md)** - Script documentation

---

## 🤝 **Contributing**

When modifying the Makefile:

1. **Follow the section structure** - Keep commands organized by purpose
2. **Include debug information** - All dev targets should show debug ports
3. **Add comprehensive help** - Use `##` comments for help text
4. **Test all targets** - Ensure all commands work correctly
5. **Update this documentation** - Keep this README current

---

**🎯 RESULT**: The DICE Makefile provides **enterprise-grade development workflows** with **comprehensive debugging**, **logging integration**, and **production-ready automation**!

---

**🛡️ Security-First • ⚡ Performance-Optimised • 🏗️ Enterprise-Ready** 