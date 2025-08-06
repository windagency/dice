#!/bin/bash

# Test Service Health Dashboard
# Tests dashboard functionality and performance

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

show_banner "Service Health Dashboard Test" "Testing Service Health Dashboard functionality and performance"

# Configuration
KIBANA_HOST="http://localhost:5601"
ELASTICSEARCH_HOST="http://localhost:9200"
DASHBOARD_ID="dice-service-health-dashboard"

print_step "🔍 Testing Service Health Dashboard Components"

# Test 1: Check if dashboard exists
print_status "Testing dashboard existence..."
DASHBOARD_EXISTS=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=dice-service-health-dashboard" | jq '.total')

if [ "$DASHBOARD_EXISTS" -gt 0 ]; then
    print_success "✅ Service Health Dashboard found"
else
    print_warning "⚠️  Dashboard not found - manual creation required"
fi

# Test 2: Check visualizations
print_status "Testing visualization components..."
VISUALIZATIONS=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=visualization" | jq '.total')
print_info "Found $VISUALIZATIONS visualizations"

# Test 3: Check health data availability
print_status "Testing health data availability..."
HEALTH_DOCS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_count" | jq '.count')
print_info "Found $HEALTH_DOCS health documents"

# Test 4: Test dashboard performance
print_status "Testing dashboard performance..."
START_TIME=$(date +%s)
DASHBOARD_RESPONSE=$(curl -s -w "%{http_code}" "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=dice-service-health-dashboard" -o /dev/null)
END_TIME=$(date +%s)
RESPONSE_TIME=$((END_TIME - START_TIME))

if [ "$DASHBOARD_RESPONSE" = "200" ]; then
    print_success "✅ Dashboard API response: ${RESPONSE_TIME}s"
else
    print_error "❌ Dashboard API error: HTTP $DASHBOARD_RESPONSE"
fi

# Test 5: Check alert configurations
print_status "Testing alert configurations..."
ALERTS=$(curl -s "${KIBANA_HOST}/api/alerting/rules/_find" | jq '.total // 0')
print_info "Found $ALERTS configured alerts"

# Test 6: Validate health data quality
print_status "Testing data quality..."
ERROR_LOGS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"level": "error"}},
  "size": 0
}' | jq '.hits.total.value')

WARN_LOGS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"level": "warn"}},
  "size": 0
}' | jq '.hits.total.value')

INFO_LOGS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"level": "info"}},
  "size": 0
}' | jq '.hits.total.value')

print_info "Error logs: $ERROR_LOGS"
print_info "Warning logs: $WARN_LOGS"
print_info "Info logs: $INFO_LOGS"

# Test 7: Check service distribution
print_status "Testing service distribution..."
SERVICES=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "aggs": {"services": {"terms": {"field": "service", "size": 10}}},
  "size": 0
}' | jq '.aggregations.services.buckets')

print_info "Service distribution:"
echo "$SERVICES" | jq -r '.[] | "  - \(.key): \(.doc_count) logs"'

# Test 8: Performance metrics
print_status "Testing query performance..."
QUERY_START=$(date +%s.%N)
curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"range": {"@timestamp": {"gte": "now-1h"}}},
  "aggs": {
    "service_health": {"terms": {"field": "service", "size": 10}},
    "level_distribution": {"terms": {"field": "level", "size": 5}}
  },
  "size": 0
}' > /dev/null
QUERY_END=$(date +%s.%N)
QUERY_TIME=$(echo "$QUERY_END - $QUERY_START" | bc -l)

print_info "Query performance: ${QUERY_TIME}s"

# Test 9: Health score calculation
print_status "Testing health score calculation..."
TOTAL_LOGS=$((ERROR_LOGS + WARN_LOGS + INFO_LOGS))
if [ "$TOTAL_LOGS" -gt 0 ]; then
    ERROR_PERCENTAGE=$(echo "scale=2; $ERROR_LOGS * 100 / $TOTAL_LOGS" | bc -l)
    WARN_PERCENTAGE=$(echo "scale=2; $WARN_LOGS * 100 / $TOTAL_LOGS" | bc -l)
    HEALTH_SCORE=$(echo "scale=0; 100 - $ERROR_PERCENTAGE - ($WARN_PERCENTAGE * 0.5)" | bc -l)
    
    print_info "Health score: ${HEALTH_SCORE}%"
    print_info "Error rate: ${ERROR_PERCENTAGE}%"
    print_info "Warning rate: ${WARN_PERCENTAGE}%"
    
    if (( $(echo "$HEALTH_SCORE >= 80" | bc -l) )); then
        print_success "✅ System health: GOOD (${HEALTH_SCORE}%)"
    elif (( $(echo "$HEALTH_SCORE >= 60" | bc -l) )); then
        print_warning "⚠️  System health: WARNING (${HEALTH_SCORE}%)"
    else
        print_error "❌ System health: CRITICAL (${HEALTH_SCORE}%)"
    fi
else
    print_warning "⚠️  No health data available for scoring"
fi

# Test 10: Check infrastructure services
print_status "Testing infrastructure service monitoring..."
INFRASTRUCTURE_SERVICES=("postgresql" "redis" "temporal" "backend-api" "elasticsearch" "kibana" "fluent-bit")
for service in "${INFRASTRUCTURE_SERVICES[@]}"; do
    SERVICE_LOGS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d "{
      \"query\": {\"term\": {\"service\": \"$service\"}},
      \"size\": 0
    }" | jq '.hits.total.value')
    
    if [ "$SERVICE_LOGS" -gt 0 ]; then
        print_success "✅ $service: $SERVICE_LOGS logs"
    else
        print_warning "⚠️  $service: No logs found"
    fi
done

# Summary
print_step "📊 Service Health Dashboard Test Summary"

if [ "$DASHBOARD_EXISTS" -gt 0 ] && [ "$HEALTH_DOCS" -gt 0 ]; then
    print_success "✅ Service Health Dashboard is operational"
    print_info "📈 Dashboard components: $VISUALIZATIONS visualizations"
    print_info "📊 Health data: $HEALTH_DOCS documents"
    print_info "🚨 Alerts configured: $ALERTS"
    print_info "⚡ Query performance: ${QUERY_TIME}s"
    print_info "📊 Health metrics:"
    print_info "   - Total logs: $TOTAL_LOGS"
    print_info "   - Error rate: ${ERROR_PERCENTAGE}%"
    print_info "   - Warning rate: ${WARN_PERCENTAGE}%"
    print_info "   - Health score: ${HEALTH_SCORE}%"
    
    print_step "🎯 Next Steps"
    print_info "1. Access dashboard: http://localhost:5601/app/dashboards"
    print_info "2. Verify visualizations are displaying correctly"
    print_info "3. Test alert functionality"
    print_info "4. Monitor real-time health metrics"
    
else
    print_warning "⚠️  Dashboard requires manual setup"
    print_info "📋 Follow manual setup guide: infrastructure/logging/SERVICE_HEALTH_DASHBOARD_MANUAL_SETUP.md"
fi

show_completion "Service Health Dashboard Test"
