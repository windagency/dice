#!/bin/bash
set -e

echo "🎲 DICE Development Environment Health Check 🎲"
echo "================================================="

# Backend API
echo "🚀 Backend API Health:"
if response=$(curl -s localhost:3001/health 2>/dev/null); then
    echo "$response" | jq -r '"✅ \(.status) - \(.service) (uptime: \(.uptime)s)"'
else
    echo "❌ Backend API is not responding"
fi

# PWA Frontend
echo "🎨 PWA Frontend:"
if curl -s localhost:3000 > /dev/null 2>&1; then
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
if curl -s localhost:4566/_localstack/health > /dev/null 2>&1; then
    echo "✅ LocalStack is healthy"
    if command -v jq > /dev/null 2>&1; then
        available_services=$(curl -s localhost:4566/_localstack/health | jq -r '.services | to_entries | map(select(.value == "available")) | map(.key) | join(", ")')
        echo "   Available services: $available_services"
    fi
else
    echo "❌ LocalStack is not responding"
fi

# Traefik
echo "🌐 Traefik Proxy:"
if docker ps --filter name=dice_traefik --format "{{.Status}}" | grep -q "Up"; then
    echo "✅ Traefik container is running"  
else
    echo "❌ Traefik container is not running"
fi

echo "================================================="

# Summary
all_healthy=true
if ! curl -s localhost:3001/health > /dev/null 2>&1; then all_healthy=false; fi
if ! curl -s localhost:3000 > /dev/null 2>&1; then all_healthy=false; fi
if ! docker compose exec -T postgres pg_isready -U dice_user -d dice_db > /dev/null 2>&1; then all_healthy=false; fi
if ! docker compose exec -T redis redis-cli ping > /dev/null 2>&1; then all_healthy=false; fi
if ! curl -s localhost:4566/_localstack/health > /dev/null 2>&1; then all_healthy=false; fi
if ! docker ps --filter name=dice_traefik --format "{{.Status}}" | grep -q "Up"; then all_healthy=false; fi

if [ "$all_healthy" = true ]; then
    echo "🎉 All services are healthy! Development environment is ready."
    exit 0
else
    echo "⚠️  Some services are not healthy. Check the details above."
    exit 1
fi 