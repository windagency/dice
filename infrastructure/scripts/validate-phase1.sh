#!/bin/bash
set -e

echo "🔍 Validating Phase 1 Implementation..."
echo "========================================"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found"
    exit 1
fi

# Check if environment file exists
if [ ! -f ".env.development" ]; then
    echo "❌ .env.development not found"
    exit 1
fi

echo "✅ Configuration files found"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker."
    exit 1
fi

echo "✅ Docker is running"

# Check service health
echo ""
echo "🔧 Checking service health..."

# Check if services are running
POSTGRES_STATUS=$(docker compose ps postgres --format json 2>/dev/null | jq -r '.[0].State' 2>/dev/null || echo "not found")
REDIS_STATUS=$(docker compose ps redis --format json 2>/dev/null | jq -r '.[0].State' 2>/dev/null || echo "not found")
TRAEFIK_STATUS=$(docker compose ps traefik --format json 2>/dev/null | jq -r '.[0].State' 2>/dev/null || echo "not found")

if [ "$POSTGRES_STATUS" = "running" ]; then
    echo "✅ PostgreSQL is running"
else
    echo "❌ PostgreSQL is not running (Status: $POSTGRES_STATUS)"
    echo "   Try: docker compose up -d postgres"
    exit 1
fi

if [ "$REDIS_STATUS" = "running" ]; then
    echo "✅ Redis is running"
else
    echo "❌ Redis is not running (Status: $REDIS_STATUS)"
    echo "   Try: docker compose up -d redis"
    exit 1
fi

if [ "$TRAEFIK_STATUS" = "running" ]; then
    echo "✅ Traefik is running"
else
    echo "❌ Traefik is not running (Status: $TRAEFIK_STATUS)"
    echo "   Try: docker compose up -d traefik"
    exit 1
fi

# Check database connectivity
echo ""
echo "🗄️ Checking database connectivity..."

if docker compose exec postgres pg_isready -U dice_user -d dice_db &> /dev/null; then
    echo "✅ Database connection working"
else
    echo "❌ Database connection failed"
    echo "   Try: docker compose logs postgres"
    exit 1
fi

# Check seed data
echo ""
echo "🌱 Checking seed data..."

USER_COUNT=$(docker compose exec postgres psql -U dice_user -d dice_db -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d ' ' || echo "0")
if [ "$USER_COUNT" -gt 0 ]; then
    echo "✅ Database seeded with development data ($USER_COUNT users)"
else
    echo "❌ Database seed data missing"
    echo "   Database may still be initializing. Wait a moment and try again."
    exit 1
fi

# Check Redis connectivity
echo ""
echo "⚡ Checking Redis connectivity..."

if docker compose exec redis redis-cli ping &> /dev/null; then
    echo "✅ Redis connection working"
else
    echo "❌ Redis connection failed"
    echo "   Try: docker compose logs redis"
    exit 1
fi

# Check required hosts entries
echo ""
echo "🌐 Checking /etc/hosts entries..."

HOSTS_ENTRIES=(
    "pwa.dice.local"
    "api.dice.local"
    "traefik.dice.local"
)

MISSING_HOSTS=()
for host in "${HOSTS_ENTRIES[@]}"; do
    if ! grep -q "$host" /etc/hosts 2>/dev/null; then
        MISSING_HOSTS+=("$host")
    fi
done

if [ ${#MISSING_HOSTS[@]} -eq 0 ]; then
    echo "✅ All required hosts entries found"
else
    echo "⚠️  Missing hosts entries: ${MISSING_HOSTS[*]}"
    echo "   Add them with: echo '127.0.0.1 pwa.dice.local api.dice.local traefik.dice.local' | sudo tee -a /etc/hosts"
fi

# Check if backend and pwa can be built (if Dockerfiles exist)
echo ""
echo "🐳 Checking service build capability..."

if [ -f "workspace/backend/Dockerfile" ]; then
    echo "✅ Backend Dockerfile found"
else
    echo "⚠️  Backend Dockerfile not found - will need to be created for services to start"
fi

if [ -f "workspace/pwa/Dockerfile" ]; then
    echo "✅ PWA Dockerfile found"
else
    echo "⚠️  PWA Dockerfile not found - will need to be created for services to start"
fi

# Check if Traefik dashboard is accessible
echo ""
echo "🔍 Checking Traefik dashboard..."

if curl -k -f http://localhost:8080 &> /dev/null; then
    echo "✅ Traefik dashboard accessible at http://localhost:8080"
else
    echo "⚠️  Traefik dashboard not accessible"
    echo "   This is normal if Traefik just started. Try: docker compose logs traefik"
fi

# Summary
echo ""
echo "📊 Phase 1 Validation Summary"
echo "============================="

# Count issues
ISSUES=0

# Check critical components
if [ "$POSTGRES_STATUS" != "running" ]; then ((ISSUES++)); fi
if [ "$REDIS_STATUS" != "running" ]; then ((ISSUES++)); fi
if [ "$TRAEFIK_STATUS" != "running" ]; then ((ISSUES++)); fi
if [ "$USER_COUNT" -le 0 ]; then ((ISSUES++)); fi

if [ $ISSUES -eq 0 ]; then
    echo "✅ Phase 1 validation PASSED - Core infrastructure is ready!"
    echo ""
    echo "🎯 Ready for next steps:"
    echo "   1. Implement backend service (Nest.js + TypeScript)"
    echo "   2. Implement PWA frontend (Astro.js + React)"
    echo "   3. Test service integration and hot reload"
    echo ""
    echo "🚀 Continue with: Backend and PWA service implementation"
else
    echo "❌ Phase 1 validation FAILED - $ISSUES critical issues found"
    echo ""
    echo "🔧 Fix the issues above and run validation again:"
    echo "   ./infrastructure/scripts/validate-phase1.sh"
    exit 1
fi

echo "🎉 Phase 1 core infrastructure validation complete!" 