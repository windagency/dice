#!/bin/bash
set -e

echo "🚀 Setting up DICE Development Environment..."

# Create required directories
echo "📁 Creating directory structure..."
mkdir -p infrastructure/data/{postgres,redis,localstack,uploads,backups,traefik}
mkdir -p infrastructure/config
mkdir -p infrastructure/scripts/seed-data
mkdir -p workspace/backend/{src,.devcontainer}
mkdir -p workspace/pwa/{src,public,.devcontainer}
mkdir -p workspace/shared/{types,utils,.devcontainer}

# Create environment file if it doesn't exist
if [ ! -f .env.development ]; then
    echo "📝 Creating development environment file..."
    cat > .env.development << 'EOF'
# DICE Development Environment Configuration
# Last Updated: 2024-12-26

# Database Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=dice_db
POSTGRES_USER=dice_user
# ⚠️ SECURITY: Generate a strong database password
POSTGRES_PASSWORD=dice_dev_secure_password_$(openssl rand -hex 16)
DATABASE_URL=postgresql://dice_user:\$POSTGRES_PASSWORD@postgres:5432/dice_db

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_URL=redis://redis:6379

# LocalStack Configuration (AWS Simulation)
# NOTE: 'test' credentials are LocalStack's standard development values (safe for local development)
LOCALSTACK_ENDPOINT=http://localstack:4566
LOCALSTACK_ACCESS_KEY_ID=test
LOCALSTACK_SECRET_ACCESS_KEY=test
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_DEFAULT_REGION=eu-west-3

# Service URLs (Internal Docker Network)
BACKEND_URL=http://backend:3001
PWA_URL=http://pwa:3000
CMS_URL=http://payloadcms:3002

# Authentication Secrets (DEVELOPMENT ONLY!)
# ⚠️ SECURITY: These are development-only secrets. Generate new ones with: openssl rand -hex 32
JWT_SECRET=dice_jwt_development_secret_$(openssl rand -hex 16)
BACKEND_API_KEY=dice_backend_api_dev_key_$(openssl rand -hex 16)
CMS_API_KEY=dice_cms_api_dev_key_$(openssl rand -hex 16)
INTERNAL_JWT_SECRET=dice_internal_jwt_dev_$(openssl rand -hex 16)

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
EOF
    echo "✅ Environment file created at .env.development"
echo "⚠️ SECURITY WARNING: Review all secrets before starting services"
echo "⚠️ Never commit .env.development to version control"
fi

# Set proper permissions
echo "🔒 Setting permissions..."
chmod +x infrastructure/scripts/*.sh
chmod 755 infrastructure/data/

# Check Docker installation
echo "🐳 Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop or Rancher Desktop."
    exit 1
fi

# Check if docker compose is available (modern Docker includes compose)
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please update Docker to latest version."
    exit 1
fi

# Check if ports are available
echo "🔍 Checking port availability..."
for port in 80 443 3001 3000 3002 5432 6379 8080; do
    if lsof -Pi :$port -sTCP:LISTEN -t &> /dev/null; then
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

echo "Required /etc/hosts entries:"
for entry in "${HOSTS_ENTRIES[@]}"; do
    echo "  $entry"
    if ! grep -q "$entry" "$HOSTS_FILE" 2>/dev/null; then
        echo "⚠️  Missing: $entry"
        echo "   Add manually or run: echo '$entry' | sudo tee -a $HOSTS_FILE"
    else
        echo "✅ Found: $entry"
    fi
done

echo ""
echo "✅ Development environment directory structure created!"
echo ""
echo "📋 Next Steps:"
echo "1. Add missing /etc/hosts entries (see above)"
echo "2. Review .env.development file"
echo "3. Create service Dockerfiles and source code"
echo "4. Run 'make start-all' to start all services"
echo ""
echo "🔍 For help: make help"
echo "📚 Check the implementation guide for detailed instructions" 