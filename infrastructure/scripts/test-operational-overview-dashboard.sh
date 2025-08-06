#!/bin/bash

# Test Operational Overview Dashboard
# Tests dashboard functionality and performance

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

show_banner "Operational Overview Dashboard Test" "Testing Operational Overview Dashboard functionality and performance"

# Configuration
KIBANA_HOST="http://localhost:5601"
ELASTICSEARCH_HOST="http://localhost:9200"
DASHBOARD_ID="dice-operational-overview-dashboard"

print_step "🔍 Testing Operational Overview Dashboard Components"

# Test 1: Check if dashboard exists
print_status "Testing dashboard existence..."
DASHBOARD_EXISTS=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=dice-operational-overview-dashboard" | jq '.total')

if [ "$DASHBOARD_EXISTS" -gt 0 ]; then
    print_success "✅ Operational Overview Dashboard found"
else
    print_warning "⚠️  Dashboard not found - manual creation required"
fi

# Test 2: Check visualizations
print_status "Testing visualization components..."
VISUALIZATIONS=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=visualization" | jq '.total')
print_info "Found $VISUALIZATIONS visualizations"

# Test 3: Check operational data availability
print_status "Testing operational data availability..."
OPERATIONAL_DOCS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_count" | jq '.count')
print_info "Found $OPERATIONAL_DOCS operational documents"

# Test 4: Test dashboard performance
print_status "Testing dashboard performance..."
START_TIME=$(date +%s)
DASHBOARD_RESPONSE=$(curl -s -w "%{http_code}" "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=dice-operational-overview-dashboard" -o /dev/null)
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

# Test 6: Validate operational data quality
print_status "Testing data quality..."
CORRELATED_REQUESTS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"exists": {"field": "correlationId"}},
  "size": 0
}' | jq '.hits.total.value')

UNIQUE_CORRELATION_IDS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "aggs": {"correlationIds": {"cardinality": {"field": "correlationId"}}},
  "size": 0
}' | jq '.aggregations.correlationIds.value')

ERROR_OPERATIONS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"level": "error"}},
  "size": 0
}' | jq '.hits.total.value')

print_info "Correlated requests: $CORRELATED_REQUESTS"
print_info "Unique correlation IDs: $UNIQUE_CORRELATION_IDS"
print_info "Error operations: $ERROR_OPERATIONS"

# Test 7: Performance metrics
print_status "Testing query performance..."
QUERY_START=$(date +%s.%N)
curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"range": {"@timestamp": {"gte": "now-1h"}}},
  "aggs": {
    "services": {"terms": {"field": "service", "size": 10}},
    "levels": {"terms": {"field": "level", "size": 5}},
    "correlation_coverage": {"cardinality": {"field": "correlationId"}}
  },
  "size": 0
}' > /dev/null
QUERY_END=$(date +%s.%N)
QUERY_TIME=$(echo "$QUERY_END - $QUERY_START" | bc -l)

print_info "Query performance: ${QUERY_TIME}s"

# Test 8: Check service distribution
print_status "Testing service distribution..."
SERVICES=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "aggs": {"services": {"terms": {"field": "service", "size": 10}}},
  "size": 0
}' | jq '.aggregations.services.buckets')

print_info "Service distribution:"
echo "$SERVICES" | jq -r '.[] | "  - \(.key): \(.doc_count) operations"'

# Test 9: Operational intelligence metrics
print_status "Testing operational intelligence metrics..."
if [ "$OPERATIONAL_DOCS" -gt 0 ]; then
    CORRELATION_COVERAGE=$(echo "scale=2; $CORRELATED_REQUESTS * 100 / $OPERATIONAL_DOCS" | bc -l)
    ERROR_RATE=$(echo "scale=2; $ERROR_OPERATIONS * 100 / $OPERATIONAL_DOCS" | bc -l)
    OPERATIONAL_HEALTH=$(echo "scale=0; 100 - $ERROR_RATE" | bc -l)
    
    print_info "Correlation coverage: ${CORRELATION_COVERAGE}%"
    print_info "Error rate: ${ERROR_RATE}%"
    print_info "Operational health: ${OPERATIONAL_HEALTH}%"
    
    if (( $(echo "$OPERATIONAL_HEALTH >= 95" | bc -l) )); then
        print_success "✅ Operational health: EXCELLENT (${OPERATIONAL_HEALTH}%)"
    elif (( $(echo "$OPERATIONAL_HEALTH >= 80" | bc -l) )); then
        print_success "✅ Operational health: GOOD (${OPERATIONAL_HEALTH}%)"
    elif (( $(echo "$OPERATIONAL_HEALTH >= 60" | bc -l) )); then
        print_warning "⚠️  Operational health: WARNING (${OPERATIONAL_HEALTH}%)"
    else
        print_error "❌ Operational health: CRITICAL (${OPERATIONAL_HEALTH}%)"
    fi
else
    print_warning "⚠️  No operational data available for health scoring"
fi

# Test 10: Check log volume analysis
print_status "Testing log volume analysis..."
LOG_VOLUME_BY_LEVEL=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "aggs": {"levels": {"terms": {"field": "level", "size": 5}}},
  "size": 0
}' | jq '.aggregations.levels.buckets')

print_info "Log volume by level:"
echo "$LOG_VOLUME_BY_LEVEL" | jq -r '.[] | "  - \(.key): \(.doc_count) logs"'

# Test 11: Cross-service correlation analysis
print_status "Testing cross-service correlation analysis..."
CORRELATION_PATTERNS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"exists": {"field": "correlationId"}},
  "aggs": {
    "correlation_services": {"terms": {"field": "service", "size": 10}},
    "correlation_ids": {"cardinality": {"field": "correlationId"}}
  },
  "size": 0
}')

CORRELATION_SERVICES=$(echo "$CORRELATION_PATTERNS" | jq '.aggregations.correlation_services.buckets | length')
UNIQUE_CORRELATIONS=$(echo "$CORRELATION_PATTERNS" | jq '.aggregations.correlation_ids.value')

print_info "Services with correlation: $CORRELATION_SERVICES"
print_info "Unique correlation patterns: $UNIQUE_CORRELATIONS"

# Test 12: Capacity planning indicators
print_status "Testing capacity planning indicators..."
RESOURCE_DATA=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"exists": {"field": "metadata.cpu"}},
  "size": 0
}' | jq '.hits.total.value')

if [ "$RESOURCE_DATA" -gt 0 ]; then
    print_success "✅ Resource usage data available: $RESOURCE_DATA records"
else
    print_warning "⚠️  No resource usage data available for capacity planning"
fi

# Summary
print_step "📊 Operational Overview Dashboard Test Summary"

if [ "$DASHBOARD_EXISTS" -gt 0 ] && [ "$OPERATIONAL_DOCS" -gt 0 ]; then
    print_success "✅ Operational Overview Dashboard is operational"
    print_info "📈 Dashboard components: $VISUALIZATIONS visualizations"
    print_info "📊 Operational data: $OPERATIONAL_DOCS documents"
    print_info "🚨 Alerts configured: $ALERTS"
    print_info "⚡ Query performance: ${QUERY_TIME}s"
    print_info "📊 Operational metrics:"
    print_info "   - Correlated requests: $CORRELATED_REQUESTS"
    print_info "   - Unique correlation IDs: $UNIQUE_CORRELATION_IDS"
    print_info "   - Error operations: $ERROR_OPERATIONS"
    print_info "   - Correlation coverage: ${CORRELATION_COVERAGE}%"
    print_info "   - Operational health: ${OPERATIONAL_HEALTH}%"
    
    print_step "🎯 Next Steps"
    print_info "1. Access dashboard: http://localhost:5601/app/dashboards"
    print_info "2. Verify visualizations are displaying correctly"
    print_info "3. Test alert functionality"
    print_info "4. Monitor real-time operational metrics"
    
else
    print_warning "⚠️  Dashboard requires manual setup"
    print_info "📋 Follow manual setup guide: infrastructure/logging/OPERATIONAL_OVERVIEW_DASHBOARD_MANUAL_SETUP.md"
fi

show_completion "Operational Overview Dashboard Test"
