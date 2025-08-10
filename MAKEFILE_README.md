# DICE Makefile Documentation

**Version**: 4.1 - Integrated Backend LocalStack
**Last Updated**: August 8, 2025 2:25 p.m.  
**Status**: ✅ Production Ready

## 📋 **Overview**

The DICE Makefile provides a comprehensive interface for managing the distributed Docker development environment using the new unified script architecture. It includes production startup with integrated LocalStack AWS services emulation, debug-enabled development workflows, comprehensive logging, testing, and validation capabilities.

---

## 🏗️ **Architecture Overview**

The Makefile is organized into logical sections that mirror the distributed architecture:

### **Section Structure**

```
├── HELP & SETUP                    # Basic setup and help
├── SERVICE STARTUP (Production)    # Standard service startup
├── UNIFIED SERVICE MANAGEMENT      # Unified service operations
├── SERVICE STARTUP WITH PROFILES   # Profile-based startup
├── DEVELOPMENT MODE (Debug)        # Debug-enabled development
├── ELK LOGGING STACK MANAGEMENT    # Logging infrastructure
├── LOGGING & MONITORING           # Comprehensive logging
├── LOGGING MONITORING & TESTING   # Advanced logging features
├── HEALTH & STATUS                # Health checking
├── DATABASE MANAGEMENT            # Database operations
├── QUICK ACCESS TARGETS          # One-command workflows
└── CLEANUP TARGETS               # Comprehensive cleanup
```

---

## 🏗️ **Unified Architecture Benefits**

The Makefile now leverages the new unified script architecture:

### **📉 Code Reduction**

- **80% less code** - Consolidated from 15+ scripts to 3 core unified scripts
- **Eliminated duplication** - Single source of truth for each domain
- **Reduced maintenance** - Fewer files to maintain and update
- **Legacy cleanup** - Removed duplicate target definitions and legacy code

### **🎯 Unified Scripts**

- **`unified-service-manager.sh`** - Single interface for all service operations
- **`unified-validation-framework.sh`** - Comprehensive validation with configurable thresholds
- **`dashboard-test-framework.sh`** - Unified dashboard testing for all types

### **🔧 Enhanced Features**

- **Configurable thresholds** - Adjustable validation criteria
- **Comprehensive reporting** - Detailed validation reports
- **Backup/restore** - Integrated backup functionality
- **Performance metrics** - Real-time performance monitoring
- **Verbose progress indicators** - Real-time step-by-step progress tracking
- **Time estimates** - Estimated and actual execution times
- **Service component breakdown** - Detailed component descriptions
- **Container health monitoring** - Real-time container status updates

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

## 🎯 **Enhanced Verbose Progress Indicators (v4.3)**

### **📊 Progress Tracking Features**

The enhanced startup commands now provide comprehensive progress indicators:

#### **🔄 Step-by-Step Progress**

```
🔄 [1/4] Starting Backend API + Database + Temporal
⏱️  Estimated time: 15-20s
```

#### **🔧 Service Component Breakdown**

```
🔧 Backend Service Components:
   📦 Backend API (NestJS)
   🗄️  PostgreSQL Database
   ⚡ Redis Cache
   🔄 Temporal Workflow Engine
   🖥️  Temporal UI
```

#### **⏳ Real-Time Container Monitoring**

```
⏳ Waiting for backend containers to be ready...
⏳ backend: 3/5 containers ready...
⏳ backend: 4/5 containers ready...
✅ backend containers are ready!
```

#### **📊 Progress Summary**

```
📊 Progress Summary:
✅ Completed: 4/4 steps
⏳ Remaining: 0 steps
⏱️  Actual total time: 157s
```

### **🎯 Enhanced Commands**

| Command          | Enhanced Features                                                 | Usage                 |
| ---------------- | ----------------------------------------------------------------- | --------------------- |
| `start-all`      | Full stack with verbose progress + time tracking                  | `make start-all`      |
| `start-backend`  | Backend with LocalStack + component breakdown + health monitoring | `make start-backend`  |
| `start-frontend` | PWA with Storybook status + container monitoring                  | `make start-frontend` |

### **⏱️ Time Estimates**

- **Backend**: 25-35 seconds (API + Database + Temporal + Redis + LocalStack)
- **PWA**: 5-10 seconds (Frontend + Storybook)
- **ELK**: 30-45 seconds (Elasticsearch + Kibana + Fluent Bit)
- **Orchestrator**: 5-10 seconds (Traefik)
- **Total**: 60-90 seconds for full stack

---

## 📚 **Command Reference**

### **🔧 HELP & SETUP**

| Command              | Description                            | Usage                     |
| -------------------- | -------------------------------------- | ------------------------- |
| `help`               | Show all available commands            | `make help`               |
| `setup`              | Initial development environment setup  | `make setup`              |
| `setup-devcontainer` | Setup DevContainer environment         | `make setup-devcontainer` |
| `setup-localstack`   | Setup LocalStack AWS services emulator | `make setup-localstack`   |

### **🎛️ UNIFIED SERVICE MANAGEMENT**

| Command           | Description                | Usage                  |
| ----------------- | -------------------------- | ---------------------- |
| `service-start`   | Start all services         | `make service-start`   |
| `service-stop`    | Stop all services          | `make service-stop`    |
| `service-restart` | Restart all services       | `make service-restart` |
| `service-status`  | Show service status        | `make service-status`  |
| `service-health`  | Health check all services  | `make service-health`  |
| `service-logs`    | Show logs for all services | `make service-logs`    |
| `service-clean`   | Clean all containers       | `make service-clean`   |
| `service-backup`  | Create backup              | `make service-backup`  |

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
- **Integrated LocalStack for backend**
- **Enhanced verbose progress indicators**
- **Real-time step tracking**
- **Time estimates and actual execution times**
- **Service component breakdown**

### **🎛️ SERVICE STARTUP WITH PROFILES**

**Available Profiles:**

- `--proxy` - Traefik reverse proxy
- `--monitoring` - Prometheus + Grafana
- `--logging` - ELK stack (Elasticsearch, Kibana, Fluent Bit)

### **🔧 DEVELOPMENT MODE (Debug Enabled)**

| Command          | Description              | Debug Features                 | Usage                 |
| ---------------- | ------------------------ | ------------------------------ | --------------------- |
| `dev-backend`    | Backend with debug mode  | Port 9229, logs                | `make dev-backend`    |
| `dev-frontend`   | Frontend with debug mode | DevTools, Chrome Debug (9222)  | `make dev-frontend`   |
| `dev-full`       | Full stack with debug    | All debug ports, logs          | `make dev-full`       |
| `dev-full-debug` | Full stack + ELK + debug | Complete debug setup + logging | `make dev-full-debug` |

**Debug Features:**

- **Backend**: Node.js debugger on port 9229, LocalStack on port 4566
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

### **🧪 UNIFIED VALIDATION**

| Command                   | Description               | Usage                          |
| ------------------------- | ------------------------- | ------------------------------ |
| `validate-all`            | Run all validation phases | `make validate-all`            |
| `validate-infrastructure` | Validate infrastructure   | `make validate-infrastructure` |
| `validate-services`       | Validate services         | `make validate-services`       |
| `validate-security`       | Validate security         | `make validate-security`       |
| `validate-logging`        | Validate logging          | `make validate-logging`        |
| `validate-performance`    | Validate performance      | `make validate-performance`    |
| `validate-integration`    | Validate integration      | `make validate-integration`    |

### **🏥 HEALTH & STATUS**

| Command           | Description                | Usage                  |
| ----------------- | -------------------------- | ---------------------- |
| `service-status`  | Show service status        | `make service-status`  |
| `service-health`  | Check all service health   | `make service-health`  |
| `health-backend`  | Check backend health only  | `make health-backend`  |
| `health-frontend` | Check frontend health only | `make health-frontend` |
| `health-elk`      | Check ELK stack health     | `make health-elk`      |

### **🗄️ DATABASE MANAGEMENT**

| Command          | Description                  | Usage                                                                  |
| ---------------- | ---------------------------- | ---------------------------------------------------------------------- |
| `backup-db`      | Backup PostgreSQL database   | `make backup-db`                                                       |
| `service-backup` | Backup all data              | `make service-backup`                                                  |
| `restore-db`     | Restore database from backup | `make restore-db BACKUP=filename` or `make restore-db` for interactive |

**Enhanced Features:**

- **Interactive Mode**: `make restore-db` shows available backups and prompts for selection
- **Parameter Validation**: Automatically validates backup file existence
- **Graceful Fallback**: Invalid parameters trigger interactive mode
- **Cancellation Support**: Users can cancel restore with Enter key

### **📊 UNIFIED DASHBOARD TESTING**

| Command                        | Description                  | Usage                               |
| ------------------------------ | ---------------------------- | ----------------------------------- |
| `test-dashboards-all`          | Test all dashboards          | `make test-dashboards-all`          |
| `test-dashboard-security`      | Test security dashboard      | `make test-dashboard-security`      |
| `test-dashboard-performance`   | Test performance dashboard   | `make test-dashboard-performance`   |
| `test-dashboard-health`        | Test health dashboard        | `make test-dashboard-health`        |
| `test-dashboard-user-activity` | Test user activity dashboard | `make test-dashboard-user-activity` |
| `test-dashboard-operational`   | Test operational dashboard   | `make test-dashboard-operational`   |

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

### **8. Database Management**

```bash
# Create database backup
make backup-db

# Restore database (interactive mode)
make restore-db

# Restore specific backup
make restore-db BACKUP=backup_20240806_143022.sql

# Create comprehensive backup
make service-backup
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
make validate-security

# Validate entire infrastructure
make validate-all

# Test LocalStack AWS services (now part of backend)
make health-backend
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
SERVICE_MANAGER := ./infrastructure/scripts/unified-service-manager.sh
VALIDATION_FRAMEWORK := ./infrastructure/scripts/unified-validation-framework.sh
DASHBOARD_TESTER := ./infrastructure/scripts/dashboard-test-framework.sh
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

# Restore database (interactive)
make restore-db

# Restore database (specific file)
make restore-db BACKUP=backup_20240806_143022.sql
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
| `start-backend`  | 6        | ~25-35s      | ~1.1GB       |
| `start-frontend` | 1        | ~0.4s        | ~180MB       |
| `start-all`      | 8-9      | ~60-90s      | ~1.8GB       |
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

**🎯 RESULT**: The DICE Makefile provides **enterprise-grade development workflows** with **unified script architecture**, **comprehensive debugging**, **logging integration**, **enhanced database management**, and **integrated LocalStack AWS services emulation for the backend**!

---

**🛡️ Security-First • ⚡ Performance-Optimised • 🏗️ Enterprise-Ready**
