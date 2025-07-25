# DICE Infrastructure Services Testing Procedure

**Document Version**: 1.0  
**Last Updated**: 2024-12-26  
**Purpose**: Systematic verification of DICE development environment infrastructure

---

## 🎯 **Overview**

This procedure validates that all DICE infrastructure services start correctly and are ready for development. Follow these steps in order to ensure a fully functional development environment.

## ✅ **Prerequisites**

### Required Tools

- [ ] **Rancher Desktop** or Docker Desktop running
- [ ] **Docker Compose** v2.0+ available
- [ ] **curl** command available
- [ ] **jq** (optional, for JSON parsing)

### Required Files

- [ ] `docker-compose.yml` exists in project root
- [ ] `.env.development` exists in project root
- [ ] `infrastructure/scripts/` directory exists
- [ ] Database seed files exist in `infrastructure/scripts/seed-data/`

### System Requirements

- [ ] **RAM**: Minimum 6GB available
- [ ] **Ports**: 80, 443, 3001, 3000, 3002, 5432, 6379, 8080 available
- [ ] **Disk Space**: Minimum 3GB available

---

## 🚀 **Step 1: Pre-Flight Checks**

### 1.1 Verify Docker Status

```bash
# Check Docker daemon is running
docker info

# Expected: Should show server information without errors
# If error: Start Rancher Desktop/Docker Desktop
```

### 1.2 Check Port Availability

```bash
# Check if required ports are free
lsof -Pi :80 -sTCP:LISTEN
lsof -Pi :443 -sTCP:LISTEN  
lsof -Pi :5432 -sTCP:LISTEN
lsof -Pi :6379 -sTCP:LISTEN
lsof -Pi :8080 -sTCP:LISTEN

# Expected: No output (ports are free)
# If occupied: Stop services using these ports
```

### 1.3 Verify Configuration Files

```bash
# Check essential files exist
ls -la docker-compose.yml .env.development
ls -la infrastructure/scripts/setup-dev-environment.sh
ls -la infrastructure/scripts/validate-phase1.sh

# Expected: All files should exist and be readable
```

---

## 🔧 **Step 2: Infrastructure Services Startup**

### 2.1 Start Core Infrastructure Services

```bash
# Start essential services only (no application services yet)
docker compose up -d postgres redis traefik localstack

# Expected output: 
# - Network created
# - Volumes created  
# - 4 containers started
```

### 2.2 Monitor Service Startup

```bash
# Check service status
docker compose ps

# Expected status for each service:
# - postgres: Up X seconds (healthy)
# - redis: Up X seconds (healthy)  
# - traefik: Up X seconds
# - localstack: Up X seconds (or Restarting - normal for LocalStack)
```

### 2.3 Wait for Health Checks

```bash
# Wait for services to become healthy (30-60 seconds)
sleep 30
docker compose ps

# Monitor logs if issues
docker compose logs postgres
docker compose logs redis
docker compose logs traefik
```

---

## 🧪 **Step 3: Service Connectivity Tests**

### 3.1 PostgreSQL Database Test

```bash
# Test database connectivity
docker compose exec postgres pg_isready -U dice_user -d dice_db

# Expected: "/var/run/postgresql:5432 - accepting connections"

# Test database login
docker compose exec postgres psql -U dice_user -d dice_db -c "\dt"

# Expected: List of tables (users, characters, auth_tokens, system_logs)
```

### 3.2 Verify Database Seed Data

```bash
# Check user count
docker compose exec postgres psql -U dice_user -d dice_db -c "SELECT COUNT(*) as user_count FROM users;"

# Expected: user_count = 2

# Check character count  
docker compose exec postgres psql -U dice_user -d dice_db -c "SELECT COUNT(*) as character_count FROM characters;"

# Expected: character_count = 3

# View sample data
docker compose exec postgres psql -U dice_user -d dice_db -c "SELECT email, role FROM users;"
```

### 3.3 Redis Cache Test

```bash
# Test Redis connectivity
docker compose exec redis redis-cli ping

# Expected: "PONG"

# Test Redis operations
docker compose exec redis redis-cli set test_key "DICE_TEST"
docker compose exec redis redis-cli get test_key

# Expected: "DICE_TEST"

# Clean up test
docker compose exec redis redis-cli del test_key
```

### 3.4 Traefik Reverse Proxy Test

```bash
# Test Traefik dashboard (local access)
curl -f http://localhost:8080/api/overview

# Expected: JSON response with Traefik overview

# Check if Traefik detects services
curl -s http://localhost:8080/api/http/services | jq .

# Expected: JSON object (empty services list is normal at this stage)
```

---

## 🌐 **Step 4: Network and DNS Tests**

### 4.1 Check Docker Network

```bash
# Verify Docker network exists
docker network ls | grep dice

# Expected: dice_dice_network bridge network

# Inspect network configuration
docker network inspect dice_dice_network
```

### 4.2 Test Internal Service Communication

```bash
# Test postgres from redis container (internal network)
docker compose exec redis ping -c 1 postgres

# Expected: Successful ping response

# Test redis from postgres container
docker compose exec postgres ping -c 1 redis

# Expected: Successful ping response
```

### 4.3 Hosts File Check (Optional)

```bash
# Check if local domains are configured
grep "dice.local" /etc/hosts

# Expected (if configured):
# 127.0.0.1 pwa.dice.local api.dice.local cms.dice.local traefik.dice.local monitoring.dice.local

# If not configured, add manually:
# echo '127.0.0.1 pwa.dice.local api.dice.local cms.dice.local traefik.dice.local monitoring.dice.local' | sudo tee -a /etc/hosts
```

---

## 📊 **Step 5: Resource Usage Verification**

### 5.1 Check Container Resource Usage

```bash
# Check memory and CPU usage
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

# Expected: 
# - Total memory usage should be under 2GB for infrastructure services
# - CPU usage should be low (<10% per service)
```

### 5.2 Check Disk Usage

```bash
# Check Docker volume usage
docker system df

# Expected: Reasonable space usage (under 1GB for fresh install)
```

---

## 🔍 **Step 6: Automated Validation**

### 6.1 Run Phase 1 Validation Script

```bash
# Execute comprehensive validation
chmod +x infrastructure/scripts/validate-phase1.sh
./infrastructure/scripts/validate-phase1.sh

# Expected: All checks should pass with ✅ symbols
# If failures: Review error messages and fix issues
```

---

## 🎯 **Success Criteria**

### ✅ **Infrastructure Ready Checklist**

- [ ] PostgreSQL accepting connections and seeded with development data
- [ ] Redis responding to ping commands
- [ ] Traefik dashboard accessible at <http://localhost:8080>
- [ ] LocalStack running (may show as restarting - this is normal)
- [ ] Docker network and volumes created successfully
- [ ] All health checks passing
- [ ] Memory usage under 2GB total
- [ ] No error messages in service logs

### 📈 **Performance Benchmarks**

- **Startup Time**: All services healthy within 60 seconds
- **Memory Usage**: <2GB total for infrastructure services
- **Database Response**: pg_isready response <1 second
- **Redis Response**: PING response <100ms

---

## 🚨 **Troubleshooting Guide**

### Common Issues and Solutions

#### PostgreSQL Won't Start

```bash
# Check logs
docker compose logs postgres

# Common fixes:
# 1. Port 5432 already in use
sudo lsof -i :5432
# Kill process using port or change POSTGRES_PORT in .env.development

# 2. Volume permission issues
docker compose down -v
docker volume rm dice_postgres_data
docker compose up -d postgres
```

#### Redis Connection Failed  

```bash
# Check logs
docker compose logs redis

# Common fixes:
# 1. Port 6379 already in use
sudo lsof -i :6379

# 2. Redis not ready yet
sleep 10 && docker compose exec redis redis-cli ping
```

#### Traefik Not Accessible

```bash
# Check if Traefik is running
docker compose ps traefik

# Check logs
docker compose logs traefik

# Common fixes:
# 1. Ports 80/443/8080 already in use
sudo lsof -i :80 -i :443 -i :8080

# 2. Try direct access
curl http://localhost:8080/ping
```

#### LocalStack Keeps Restarting

```bash
# This is often normal - check if it stabilizes
watch docker compose ps localstack

# If persistent issues:
docker compose logs localstack

# LocalStack may need more time/memory on slower systems
```

### Emergency Reset Procedure

```bash
# Complete infrastructure reset
docker compose down -v --remove-orphans
docker system prune -f
rm -rf infrastructure/data/*
./infrastructure/scripts/setup-dev-environment.sh
docker compose up -d postgres redis traefik localstack
```

---

## 📝 **Test Results Log Template**

```plaintext
DICE Infrastructure Test Results
================================
Date: _______________
Tester: _____________
System: _____________

Prerequisites:
□ Docker running
□ Ports available  
□ Files present

Service Startup:
□ PostgreSQL: _____ (healthy/issues)
□ Redis: _____ (healthy/issues) 
□ Traefik: _____ (healthy/issues)
□ LocalStack: _____ (healthy/issues)

Connectivity Tests:
□ Database connection: _____ (pass/fail)
□ Seed data loaded: _____ (pass/fail)
□ Redis ping: _____ (pass/fail)
□ Traefik dashboard: _____ (pass/fail)

Performance:
□ Total memory usage: _____ MB
□ Startup time: _____ seconds

Overall Result: _____ (PASS/FAIL)

Notes:
_________________________________
_________________________________
```

---

## 🎉 **Next Steps After Successful Infrastructure Test**

1. **Implement Backend Service**: Create Nest.js application with health endpoints
2. **Implement PWA Frontend**: Create Astro.js application with service worker
3. **Test Service Integration**: Verify backend↔frontend communication
4. **Configure Hot Reload**: Optimize development workflow
5. **Run Full Phase 1 Validation**: Complete end-to-end testing

---

*For support or questions, refer to the main implementation guide or project documentation.*
