#!/bin/bash
# DevContainer Setup Script
# This script prepares the development environment for DevContainer usage

set -e

echo "🔧 Setting up DICE DevContainer environment..."

# Get current user information
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "📋 Current user: UID=${CURRENT_UID}, GID=${CURRENT_GID}"

# Update DevContainer .env file with current user information
ENV_FILE=".devcontainer/.env"
if [ -f "$ENV_FILE" ]; then
    # Update existing .env file
    sed -i.bak "s/DOCKER_USER=.*/DOCKER_USER=${CURRENT_UID}/" "$ENV_FILE"
    sed -i.bak "s/DOCKER_GROUP=.*/DOCKER_GROUP=${CURRENT_GID}/" "$ENV_FILE"
    rm "${ENV_FILE}.bak" 2>/dev/null || true
    echo "✅ Updated DevContainer environment file with current user settings"
else
    echo "⚠️  DevContainer .env file not found, creating one..."
    cat > "$ENV_FILE" << EOF
# DevContainer Environment Configuration
DOCKER_USER=${CURRENT_UID}
DOCKER_GROUP=${CURRENT_GID}
COMPOSE_PROFILES=devcontainer
NODE_ENV=development
ASTRO_TELEMETRY_DISABLED=1
POSTGRES_DB=dice_db
POSTGRES_USER=dice_user
POSTGRES_PASSWORD=$(openssl rand -hex 16)
JWT_SECRET=$(openssl rand -hex 32)
DATABASE_URL=postgresql://dice_user:\$POSTGRES_PASSWORD@postgres:5432/dice_db
REDIS_URL=redis://redis:6379
TEMPORAL_ADDRESS=temporal:7233
LOCALSTACK_HOST=localhost
SERVICES=s3,dynamodb,kinesis
EOF
fi

# Create development environment file if it doesn't exist
DEV_ENV_FILE=".env.development"
if [ ! -f "$DEV_ENV_FILE" ]; then
    if [ -f ".env.sample" ]; then
        echo "📄 Copying .env.sample to .env.development..."
        cp ".env.sample" "$DEV_ENV_FILE"
        
        # Update with development defaults
        sed -i.bak "s/YOUR_SECURE_PASSWORD_HERE/$POSTGRES_PASSWORD/g" "$DEV_ENV_FILE"
sed -i.bak "s/REPLACE_WITH_STRONG_SECRET_32_CHARS_MIN/$JWT_SECRET/g" "$DEV_ENV_FILE"
        rm "${DEV_ENV_FILE}.bak" 2>/dev/null || true
        echo "✅ Created and configured .env.development"
    else
        echo "❌ .env.sample not found, cannot create .env.development"
        exit 1
    fi
else
    echo "✅ .env.development already exists"
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p infrastructure/data/traefik
mkdir -p infrastructure/temporal
mkdir -p workspace/backend/node_modules
mkdir -p workspace/pwa/node_modules

# Set proper permissions
echo "🔐 Setting permissions..."
chmod +x infrastructure/scripts/*.sh 2>/dev/null || true

# Validate Docker Compose files
echo "🐳 Validating Docker Compose configuration..."
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose -f .devcontainer/docker-compose.yml config >/dev/null
    echo "✅ DevContainer Docker Compose configuration is valid"
else
    echo "⚠️  docker-compose not available, skipping validation"
fi

echo ""
echo "🎉 DevContainer setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Open this project in VS Code"
echo "   2. Install the Dev Containers extension if not already installed"
echo "   3. Use 'Dev Containers: Reopen in Container' command"
echo "   4. Wait for the environment to build and start"
echo ""
echo "🔗 Once started, these services will be available:"
echo "   • Backend API: http://localhost:3001"
echo "   • PWA Frontend: http://localhost:3000"
echo "   • Storybook: http://localhost:6006"
echo "   • Temporal UI: http://localhost:8088"
echo "   • Traefik Dashboard: http://localhost:8080"
echo "" 