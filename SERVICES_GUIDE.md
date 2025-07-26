# DICE Development Environment - Services Guide

**Last Updated**: July 26, 2025  
**Version**: 1.0  
**Environment**: Local Development with Docker Compose

## 🚀 Quick Start - All Services

### Start Complete Environment

```bash
# Start all services in detached mode
docker compose up -d

# Check all service statuses
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Follow logs for all services
docker compose logs -f
```

### Stop All Services

```bash
# Stop all services
docker compose down

# Stop and remove volumes (clean slate)
docker compose down -v
```

## 📋 Individual Service Management

### 🗄️ Database Services

#### PostgreSQL Database

```bash
# Start PostgreSQL
docker compose up postgres -d

# Health Check
docker compose exec postgres pg_isready -U dice_user -d dice_db

# Connect to Database
docker compose exec postgres psql -U dice_user -d dice_db

# Alternative: Connect from host
psql -h localhost -p 5432 -U dice_user -d dice_db

# Check Status
curl -s localhost:3001/health | jq
```

#### Redis Cache

```bash
# Start Redis
docker compose up redis -d

# Health Check
docker compose exec redis redis-cli ping

# Alternative: Connect from host
redis-cli -h localhost -p 6379 ping

# Check Redis Info
redis-cli -h localhost -p 6379 info server
```

### 🌐 Infrastructure Services

#### Traefik Reverse Proxy

```bash
# Start Traefik
docker compose up traefik -d

# Health Check - Dashboard
curl -s localhost:8080/ping

# View Dashboard
open http://localhost:8080

# Check API Overview
curl -s localhost:8080/api/overview | jq '.http.routers | keys'
```

#### LocalStack (AWS Simulation)

```bash
# Start LocalStack
docker compose up localstack -d

# Health Check
curl -s localhost:4566/_localstack/health | jq

# List Available Services
curl -s localhost:4566/_localstack/health | jq '.services'

# Test S3 Service
aws --endpoint-url=https://localhost.localstack.cloud:4566 s3 ls

# Test DynamoDB Service
aws --endpoint-url=https://localhost.localstack.cloud:4566 dynamodb list-tables
```

##### Configure AWS CLI for LocalStack (Containerised Approach)

```bash
# Build and start AWS CLI container (preferred method)
docker compose build awscli
docker compose --profile tools up awscli -d

# Use containerised awslocal command
docker compose run --rm awscli awslocal s3 ls

# OR use containerised standard aws CLI
docker compose run --rm awscli aws --endpoint-url=http://localstack:4566 s3 ls

# Quick setup all LocalStack data (containerised)
./scripts/setup-localstack-dev-data-container.sh
```

##### Alternative: Local AWS CLI Installation

```bash
# Install AWS CLI locally (alternative method)
pip install awscli-local  # Provides 'awslocal' command

# Configure local AWS CLI with LocalStack development credentials
# NOTE: These 'test' credentials are standard for LocalStack development
aws configure set aws_access_key_id test
aws configure set aws_secret_access_key test
aws configure set default.region eu-west-3

# Use local awslocal (automatically points to LocalStack)
awslocal s3 ls

# OR use local standard aws with endpoint
aws --endpoint-url=https://localhost.localstack.cloud:4566 s3 ls
```

##### S3 Operations (Containerised)

```bash
# Create S3 bucket (containerised)
docker compose run --rm awscli awslocal s3 mb s3://dice-assets

# List buckets
docker compose run --rm awscli awslocal s3 ls

# Upload file to bucket
echo "test content" > test.txt
docker compose run --rm awscli awslocal s3 cp /workspace/project/test.txt s3://dice-assets/

# List objects in bucket
docker compose run --rm awscli awslocal s3 ls s3://dice-assets/

# Download file from bucket
docker compose run --rm awscli awslocal s3 cp s3://dice-assets/test.txt /workspace/project/downloaded.txt

# Delete object
docker compose run --rm awscli awslocal s3 rm s3://dice-assets/test.txt

# Delete bucket
docker compose run --rm awscli awslocal s3 rb s3://dice-assets
```

##### S3 Operations (Local - Alternative)

```bash
# If using local AWS CLI installation
awslocal s3 mb s3://dice-assets
awslocal s3 ls
awslocal s3 cp test.txt s3://dice-assets/
awslocal s3 ls s3://dice-assets/
awslocal s3 cp s3://dice-assets/test.txt downloaded.txt
awslocal s3 rm s3://dice-assets/test.txt
awslocal s3 rb s3://dice-assets
```

##### DynamoDB Operations (Containerised)

```bash
# Create DynamoDB table (containerised)
docker compose run --rm awscli awslocal dynamodb create-table \
    --table-name Characters \
    --attribute-definitions \
        AttributeName=CharacterId,AttributeType=S \
    --key-schema \
        AttributeName=CharacterId,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5

# List tables
docker compose run --rm awscli awslocal dynamodb list-tables

# Put item in table
docker compose run --rm awscli awslocal dynamodb put-item \
    --table-name Characters \
    --item '{
        "CharacterId": {"S": "char-001"},
        "Name": {"S": "Gandalf"},
        "Class": {"S": "Wizard"},
        "Level": {"N": "20"}
    }'

# Get item from table
docker compose run --rm awscli awslocal dynamodb get-item \
    --table-name Characters \
    --key '{"CharacterId": {"S": "char-001"}}'

# Scan table (get all items)
docker compose run --rm awscli awslocal dynamodb scan --table-name Characters

# Delete table
docker compose run --rm awscli awslocal dynamodb delete-table --table-name Characters
```

##### DynamoDB Operations (Local - Alternative)

```bash
# If using local AWS CLI installation
awslocal dynamodb create-table --table-name Characters [...]
awslocal dynamodb list-tables
awslocal dynamodb put-item --table-name Characters [...]
awslocal dynamodb get-item --table-name Characters [...]
awslocal dynamodb scan --table-name Characters
awslocal dynamodb delete-table --table-name Characters
```

##### LocalStack Web UI (Pro Feature)

```bash
# LocalStack Web UI is available for Pro users
# For community version, use AWS CLI or direct API calls

# Access LocalStack resource browser (if available)
open https://localhost.localstack.cloud:4566/_localstack/health

# Check LocalStack logs
docker compose logs localstack -f
```

##### Advanced LocalStack Operations

```bash
# Check LocalStack version and edition
curl -s localhost:4566/_localstack/health | jq '{version: .version, edition: .edition}'

# List all created resources
curl -s localhost:4566/_localstack/resources

# Reset LocalStack state (clear all resources)
curl -X POST localhost:4566/_localstack/state/reset

# Check specific service endpoints
curl -s localhost:4566/_localstack/health | jq '.services | to_entries[] | select(.value == "available")'
```

### 🎲 Application Services

#### Backend API (NestJS)

```bash
# Start Backend
docker compose up backend -d

# Health Check
curl -s localhost:3001/health | jq

# API Info
curl -s localhost:3001 | jq

# Check Logs
docker compose logs backend -f

# Access Container Shell
docker compose exec backend sh

# Install Dependencies (if needed)
docker compose exec backend pnpm install
```

#### PWA Frontend (Astro)

```bash
# Start PWA
docker compose up pwa -d

# Health Check
curl -s localhost:3000 | head -3

# Open in Browser
open http://localhost:3000

# Check Logs
docker compose logs pwa -f

# Access Container Shell
docker compose exec pwa sh

# Install Dependencies (if needed)
docker compose exec pwa pnpm install
```

## 🏥 Comprehensive Health Checks

### Automated Health Check Script

```bash
#!/bin/bash
echo "🎲 DICE Development Environment Health Check 🎲"
echo "================================================="

# Backend API
echo "🚀 Backend API Health:"
curl -s localhost:3001/health | jq -r '"\(.status) - \(.service) (uptime: \(.uptime)s)"'

# PWA Frontend
echo "🎨 PWA Frontend:"
if curl -s localhost:3000 > /dev/null; then
    echo "✅ PWA is responding"
else
    echo "❌ PWA is not responding"
fi

# PostgreSQL
echo "🗄️ PostgreSQL Database:"
if docker compose exec -T postgres pg_isready -U dice_user -d dice_db > /dev/null 2>&1; then
    echo "✅ PostgreSQL is ready"
else
    echo "❌ PostgreSQL is not ready"
fi

# Redis
echo "⚡ Redis Cache:"
if docker compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis is responding"
else
    echo "❌ Redis is not responding"
fi

# LocalStack
echo "☁️ LocalStack (AWS Simulation):"
if curl -s localhost:4566/_localstack/health > /dev/null; then
    echo "✅ LocalStack is healthy"
    echo "   Available services: $(curl -s localhost:4566/_localstack/health | jq -r '.services | to_entries | map(select(.value == "available")) | map(.key) | join(", ")')"
else
    echo "❌ LocalStack is not responding"
fi

# Traefik
echo "🌐 Traefik Proxy:"
if curl -s localhost:8080/ping > /dev/null; then
    echo "✅ Traefik is responding"  
else
    echo "❌ Traefik is not responding"
fi

echo "================================================="
echo "Health check complete!"
```

Save this script as `scripts/health-check.sh` and run:

```bash
chmod +x scripts/health-check.sh
./scripts/health-check.sh
```

### Manual Health Verification

#### 1. Container Status Check

```bash
# Check all DICE containers
docker ps --filter name=dice --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Expected output:
# dice_backend      Up X minutes (healthy)   0.0.0.0:3001->3001/tcp
# dice_pwa          Up X minutes (healthy)   0.0.0.0:3000->3000/tcp  
# dice_postgres     Up X minutes (healthy)   0.0.0.0:5432->5432/tcp
# dice_redis        Up X minutes (healthy)   0.0.0.0:6379->6379/tcp
# dice_localstack   Up X minutes (healthy)   0.0.0.0:4566->4566/tcp
# dice_traefik      Up X minutes            0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
```

#### 2. Network Connectivity

```bash
# Test internal network connectivity
docker compose exec backend ping postgres -c 1
docker compose exec backend ping redis -c 1
docker compose exec pwa ping backend -c 1
```

#### 3. Volume Mounts

```bash
# Verify volume mounts are working
docker compose exec backend ls -la /app
docker compose exec pwa ls -la /app

# Check node_modules volumes
docker compose exec backend ls /app/node_modules
docker compose exec pwa ls /app/node_modules
```

## 🔧 Development Workflow

### Hot Reload Verification

```bash
# Make a change to backend code
echo 'console.log("Hot reload test");' >> workspace/backend/src/main.ts

# Watch backend logs for restart
docker compose logs backend -f

# Make a change to frontend code  
echo '<!-- Hot reload test -->' >> workspace/pwa/src/pages/index.astro

# Watch PWA logs for reload
docker compose logs pwa -f
```

### Package Management (pnpm)

```bash
# Install backend dependencies
docker compose exec backend pnpm install

# Add new backend dependency
docker compose exec backend pnpm add @nestjs/typeorm

# Install frontend dependencies
docker compose exec pwa pnpm install

# Add new frontend dependency
docker compose exec pwa pnpm add react-router-dom

# Update all dependencies
docker compose exec backend pnpm update
docker compose exec pwa pnpm update
```

### Database Operations

```bash
# Create database backup
docker compose exec postgres pg_dump -U dice_user dice_db > backup.sql

# Restore database
docker compose exec -T postgres psql -U dice_user dice_db < backup.sql

# Reset database
docker compose down postgres
docker volume rm dice_postgres_data
docker compose up postgres -d
```

### AWS Services Development (LocalStack)

#### Setting up Local AWS Environment (Containerised)

```bash
# Start AWS CLI container with LocalStack support
docker compose --profile tools up awscli -d

# Test LocalStack connectivity (containerised)
docker compose run --rm awscli awslocal s3 ls || echo "LocalStack not ready yet"

# Quick setup all D&D development data
./scripts/setup-localstack-dev-data-container.sh

# Interactive AWS CLI session
docker compose run --rm awscli sh
```

#### Alternative: Local AWS Environment Setup

```bash
# Create alias for easier LocalStack usage (local installation)
alias awslocal="aws --endpoint-url=https://localhost.localstack.cloud:4566"

# Set up environment variables
# NOTE: Standard LocalStack development credentials (safe for local development)
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=eu-west-3

# Test LocalStack connectivity
awslocal s3 ls || echo "LocalStack not ready yet"
```

#### D&D Project AWS Resources Setup (Containerised)

```bash
# Automated setup using containerised script (RECOMMENDED)
./scripts/setup-localstack-dev-data-container.sh

# OR manual setup using containerised AWS CLI:

# Create S3 buckets for D&D assets
docker compose run --rm awscli awslocal s3 mb s3://dice-character-portraits
docker compose run --rm awscli awslocal s3 mb s3://dice-campaign-maps
docker compose run --rm awscli awslocal s3 mb s3://dice-rule-documents

# Create DynamoDB tables for game data
docker compose run --rm awscli awslocal dynamodb create-table \
    --table-name DiceCharacters \
    --attribute-definitions \
        AttributeName=UserId,AttributeType=S \
        AttributeName=CharacterId,AttributeType=S \
    --key-schema \
        AttributeName=UserId,KeyType=HASH \
        AttributeName=CharacterId,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

docker compose run --rm awscli awslocal dynamodb create-table \
    --table-name DiceCampaigns \
    --attribute-definitions \
        AttributeName=CampaignId,AttributeType=S \
    --key-schema \
        AttributeName=CampaignId,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Verify tables created
docker compose run --rm awscli awslocal dynamodb list-tables
```

#### Sample Data for Development

```bash
# Add sample character data
awslocal dynamodb put-item \
    --table-name DiceCharacters \
    --item '{
        "UserId": {"S": "user-123"},
        "CharacterId": {"S": "char-gandalf"},
        "Name": {"S": "Gandalf the Grey"},
        "Class": {"S": "Wizard"},
        "Level": {"N": "10"},
        "Race": {"S": "Maia"},
        "Stats": {
            "M": {
                "Strength": {"N": "12"},
                "Dexterity": {"N": "14"},
                "Constitution": {"N": "16"},
                "Intelligence": {"N": "20"},
                "Wisdom": {"N": "18"},
                "Charisma": {"N": "16"}
            }
        },
        "CreatedAt": {"S": "2025-07-26T21:00:00Z"}
    }'

# Add sample campaign data
awslocal dynamodb put-item \
    --table-name DiceCampaigns \
    --item '{
        "CampaignId": {"S": "campaign-lotr"},
        "Name": {"S": "Lord of the Rings"},
        "DungeonMaster": {"S": "user-123"},
        "Players": {"L": [
            {"S": "user-123"},
            {"S": "user-456"}
        ]},
        "Status": {"S": "Active"},
        "CreatedAt": {"S": "2025-07-26T21:00:00Z"}
    }'

# Upload sample assets to S3
echo "Sample character portrait data" | awslocal s3 cp - s3://dice-character-portraits/gandalf.jpg
echo "Sample campaign map data" | awslocal s3 cp - s3://dice-campaign-maps/middle-earth.jpg

# Verify data exists
awslocal dynamodb scan --table-name DiceCharacters
awslocal s3 ls s3://dice-character-portraits/
```

## 🚨 Troubleshooting

### Common Issues and Solutions

#### Services Won't Start

```bash
# Check for port conflicts
sudo lsof -i :3000 -i :3001 -i :5432 -i :6379 -i :4566 -i :8080

# Clean up Docker
docker compose down
docker system prune -f
docker volume prune -f

# Rebuild containers
docker compose build --no-cache
docker compose up -d
```

#### LocalStack Issues

```bash
# Remove problematic volumes
docker compose down localstack
docker volume rm dice_localstack_data
docker compose up localstack -d

# Check LocalStack logs
docker compose logs localstack --tail=20

# Reset LocalStack state without restart
curl -X POST localhost:4566/_localstack/state/reset

# Verify LocalStack services are available
curl -s localhost:4566/_localstack/health | jq '.services | to_entries[] | select(.value == "available")'

# Test AWS CLI connectivity
awslocal s3 ls || echo "AWS CLI not configured or LocalStack not ready"

# Debug LocalStack API calls
curl -v localhost:4566/_localstack/health
```

#### Permission Issues

```bash
# Fix file permissions
sudo chown -R $USER:$USER workspace/
chmod -R 755 workspace/

# Rebuild with clean slate
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

#### Database Connection Issues

```bash
# Reset PostgreSQL
docker compose restart postgres

# Wait for health check
sleep 10
docker compose exec postgres pg_isready -U dice_user -d dice_db

# Check connection from backend
docker compose exec backend nc -z postgres 5432
```

### Service-Specific Debugging

#### Backend Debugging

```bash
# Enable debug mode
docker compose exec backend npm run start:dev

# Connect debugger to port 9229
# VS Code: Add configuration for Node.js attach to port 9229

# View backend logs
docker compose logs backend -f --tail=100
```

#### Frontend Debugging

```bash
# Check Astro build
docker compose exec pwa pnpm run build

# Inspect generated files
docker compose exec pwa ls -la dist/

# Check Tailwind compilation
docker compose exec pwa pnpm exec tailwindcss --version
```

## 📊 Service Endpoints Reference

| Service               | URL                                                | Purpose         | Health Check                             |
| --------------------- | -------------------------------------------------- | --------------- | ---------------------------------------- |
| **Backend API**       | <http://localhost:3001>                            | NestJS REST API | `curl localhost:3001/health`             |
| **PWA Frontend**      | <http://localhost:3000>                            | Astro PWA       | `curl localhost:3000`                    |
| **PostgreSQL**        | localhost:5432                                     | Database        | `pg_isready -h localhost -p 5432`        |
| **Redis**             | localhost:6379                                     | Cache           | `redis-cli -h localhost ping`            |
| **LocalStack**        | <https://localhost.localstack.cloud:4566>          | AWS Services    | `curl localhost:4566/_localstack/health` |
| **LocalStack Web UI** | <https://app.localstack.cloud/inst/default/status> | AWS Services    |                                          |
| **Traefik Dashboard** | <http://localhost:8080>                            | Proxy Admin     | `curl localhost:8080/ping`               |

## 🎯 Development Environment Validation

### Complete Environment Test

```bash
# 1. Start all services
docker compose up -d

# 2. Wait for services to be ready
sleep 30

# 3. Run comprehensive health check
./scripts/health-check.sh

# 4. Test API endpoints
curl localhost:3001/health
curl localhost:3001

# 5. Test frontend
curl localhost:3000 | head -5

# 6. Test database
docker compose exec postgres pg_isready -U dice_user -d dice_db

# 7. Test cache
docker compose exec redis redis-cli ping

# 8. Test AWS services
curl localhost:4566/_localstack/health

# 9. Verify hot reload (make a code change and check logs)
echo "// Test change" >> workspace/backend/src/main.ts
docker compose logs backend --tail=5

# 10. Success confirmation
echo "✅ DICE Development Environment is fully operational!"
```

---

## 📝 Notes

- **pnpm**: All services use pnpm for faster, more efficient package management
- **Hot Reload**: Code changes automatically trigger service restarts
- **Health Checks**: Docker health checks ensure services are truly ready
- **Debugging**: Backend debug port (9229) exposed for IDE integration
- **SSL Ready**: Traefik handles SSL termination for production-like testing
- **AWS Simulation**: LocalStack provides S3, DynamoDB, and RDS for development

### LocalStack Development Tips

- **AWS CLI**: Use containerised `docker compose run --rm awscli awslocal` (recommended) or local `awslocal` command
- **Persistence**: LocalStack community edition doesn't persist data between restarts
- **Services**: S3, DynamoDB, Kinesis, and basic RDS functionality available
- **Testing**: Perfect for testing AWS integrations without cloud costs
- **Reset**: Use `curl -X POST localhost:4566/_localstack/state/reset` to clear all data
- **Setup Scripts**:
  - Containerised: `./scripts/setup-localstack-dev-data-container.sh` (recommended)
  - Local: `./scripts/setup-localstack-dev-data.sh` (requires local AWS CLI)

#### Known Issues with LocalStack Community Edition

- **DynamoDB Tables**: May occasionally fail to create tables in batch operations
- **Workaround**: Create tables individually if the setup script fails:

  ```bash
  # Manual table creation if needed
  aws --endpoint-url=https://localhost.localstack.cloud:4566 dynamodb create-table \
    --table-name DiceCharacters \
    --attribute-definitions AttributeName=UserId,AttributeType=S AttributeName=CharacterId,AttributeType=S \
    --key-schema AttributeName=UserId,KeyType=HASH AttributeName=CharacterId,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
  ```

- **Data Persistence**: Community edition may not persist data between container restarts
- **Pro Features**: Advanced features require LocalStack Pro subscription

## 🔗 Related Documentation

- [TODO.md](./TODO.md) - Development roadmap and progress tracking
- [CHANGELOG.md](./CHANGELOG.md) - Version history and updates
- [docker-compose.yml](./docker-compose.yml) - Service definitions
- [Infrastructure Scripts](./infrastructure/scripts/) - Automation tools
