#!/bin/bash
source ./common.sh

show_banner "DICE Health Check" "Comprehensive service health validation"

echo "🔍 Testing Backend API..."
docker exec backend_dev curl -f http://localhost:3001/health 2>/dev/null && echo "✅ Backend API healthy" || echo "❌ Backend API failed"

echo "🔍 Testing PostgreSQL..."
docker exec backend_postgres pg_isready -U dice_user -d dice_db 2>/dev/null && echo "✅ PostgreSQL healthy" || echo "❌ PostgreSQL failed"

echo "🔍 Testing Redis..."
docker exec backend_redis redis-cli ping 2>/dev/null | grep -q "PONG" && echo "✅ Redis healthy" || echo "❌ Redis failed"

echo "🔍 Testing Temporal..."
docker exec backend_temporal tctl --address localhost:7233 workflow list 2>/dev/null && echo "✅ Temporal healthy" || echo "❌ Temporal failed"

echo "🔍 Testing Elasticsearch..."
docker exec dice_elasticsearch curl -f http://localhost:9200/_cluster/health 2>/dev/null && echo "✅ Elasticsearch healthy" || echo "❌ Elasticsearch failed"

echo "🔍 Testing Kibana..."
docker exec dice_kibana curl -f http://localhost:5601/api/status 2>/dev/null && echo "✅ Kibana healthy" || echo "❌ Kibana failed"

echo "🔍 Testing Fluent Bit..."
docker exec dice_fluent_bit curl -f http://localhost:2020/api/v1/health 2>/dev/null && echo "✅ Fluent Bit healthy" || echo "❌ Fluent Bit failed"

echo ""
echo "📊 Health Check Summary:"
echo "=========================="
echo "Backend API: $(docker exec backend_dev curl -f http://localhost:3001/health 2>/dev/null && echo "✅" || echo "❌")"
echo "PostgreSQL: $(docker exec backend_postgres pg_isready -U dice_user -d dice_db 2>/dev/null && echo "✅" || echo "❌")"
echo "Redis: $(docker exec backend_redis redis-cli ping 2>/dev/null | grep -q "PONG" && echo "✅" || echo "❌")"
echo "Temporal: $(docker exec backend_temporal tctl --address localhost:7233 workflow list 2>/dev/null && echo "✅" || echo "❌")"
echo "Elasticsearch: $(docker exec dice_elasticsearch curl -f http://localhost:9200/_cluster/health 2>/dev/null && echo "✅" || echo "❌")"
echo "Kibana: $(docker exec dice_kibana curl -f http://localhost:5601/api/status 2>/dev/null && echo "✅" || echo "❌")"
echo "Fluent Bit: $(docker exec dice_fluent_bit curl -f http://localhost:2020/api/v1/health 2>/dev/null && echo "✅" || echo "❌")" 