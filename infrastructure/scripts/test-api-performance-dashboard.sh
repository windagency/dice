#!/bin/bash

# Test API Performance Dashboard
# Tests dashboard functionality and performance

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

show_banner "API Performance Dashboard Test" "Testing API Performance Dashboard functionality and performance"

# Configuration
KIBANA_HOST="http://localhost:5601"
ELASTICSEARCH_HOST="http://localhost:9200"
DASHBOARD_ID="dice-api-performance-dashboard"

print_step "🔍 Testing API Performance Dashboard Components"

# Test 1: Check if dashboard exists
print_status "Testing dashboard existence..."
DASHBOARD_EXISTS=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=dice-api-performance-dashboard" | jq '.total')

if [ "$DASHBOARD_EXISTS" -gt 0 ]; then
    print_success "✅ API Performance Dashboard found"
else
    print_warning "⚠️  Dashboard not found - manual creation required"
fi

# Test 2: Check visualizations
print_status "Testing visualization components..."
VISUALIZATIONS=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=visualization" | jq '.total')
print_info "Found $VISUALIZATIONS visualizations"

# Test 3: Check performance data availability
print_status "Testing performance data availability..."
PERFORMANCE_DOCS=$(curl -s "${ELASTICSEARCH_HOST}/dice-performance-*/_count" | jq '.count')
print_info "Found $PERFORMANCE_DOCS performance documents"

# Test 4: Test dashboard performance
print_status "Testing dashboard performance..."
START_TIME=$(date +%s)
DASHBOARD_RESPONSE=$(curl -s -w "%{http_code}" "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=dice-api-performance-dashboard" -o /dev/null)
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

# Test 6: Validate performance data quality
print_status "Testing data quality..."
SLOW_REQUESTS=$(curl -s "${ELASTICSEARCH_HOST}/dice-performance-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"range": {"metadata.duration": {"gte": 1000}}},
  "size": 0
}' | jq '.hits.total.value')

ERROR_REQUESTS=$(curl -s "${ELASTICSEARCH_HOST}/dice-performance-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"range": {"metadata.statusCode": {"gte": 400}}},
  "size": 0
}' | jq '.hits.total.value')

AVG_DURATION=$(curl -s "${ELASTICSEARCH_HOST}/dice-performance-*/_search" -H 'Content-Type: application/json' -d '{
  "aggs": {"avg_duration": {"avg": {"field": "metadata.duration"}}},
  "size": 0
}' | jq '.aggregations.avg_duration.value')

print_info "Slow requests (>1s): $SLOW_REQUESTS"
print_info "Error requests (4xx/5xx): $ERROR_REQUESTS"
print_info "Average duration: ${AVG_DURATION}ms"

# Test 7: Performance metrics
print_status "Testing query performance..."
QUERY_START=$(date +%s.%N)
curl -s "${ELASTICSEARCH_HOST}/dice-performance-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"range": {"@timestamp": {"gte": "now-1h"}}},
  "aggs": {
    "p50": {"percentiles": {"field": "metadata.duration", "percents": [50]}},
    "p95": {"percentiles": {"field": "metadata.duration", "percents": [95]}},
    "p99": {"percentiles": {"field": "metadata.duration", "percents": [99]}}
  },
  "size": 0
}' > /dev/null
QUERY_END=$(date +%s.%N)
QUERY_TIME=$(echo "$QUERY_END - $QUERY_START" | bc -l)

print_info "Query performance: ${QUERY_TIME}s"

# Test 8: Check endpoint distribution
print_status "Testing endpoint distribution..."
ENDPOINTS=$(curl -s "${ELASTICSEARCH_HOST}/dice-performance-*/_search" -H 'Content-Type: application/json' -d '{
  "aggs": {"endpoints": {"terms": {"field": "metadata.endpoint", "size": 10}}},
  "size": 0
}' | jq '.aggregations.endpoints.buckets | length')

print_info "Unique endpoints: $ENDPOINTS"

# Test 9: Performance percentiles
print_status "Testing performance percentiles..."
PERCENTILES=$(curl -s "${ELASTICSEARCH_HOST}/dice-performance-*/_search" -H 'Content-Type: application/json' -d '{
  "aggs": {
    "p50": {"percentiles": {"field": "metadata.duration", "percents": [50]}},
    "p95": {"percentiles": {"field": "metadata.duration", "percents": [95]}},
    "p99": {"percentiles": {"field": "metadata.duration", "percents": [99]}}
  },
  "size": 0
}')

P50=$(echo "$PERCENTILES" | jq '.aggregations.p50.values["50.0"]')
P95=$(echo "$PERCENTILES" | jq '.aggregations.p95.values["95.0"]')
P99=$(echo "$PERCENTILES" | jq '.aggregations.p99.values["99.0"]')

print_info "P50 response time: ${P50}ms"
print_info "P95 response time: ${P95}ms"
print_info "P99 response time: ${P99}ms"

# Summary
print_step "📊 API Performance Dashboard Test Summary"

if [ "$DASHBOARD_EXISTS" -gt 0 ] && [ "$PERFORMANCE_DOCS" -gt 0 ]; then
    print_success "✅ API Performance Dashboard is operational"
    print_info "📈 Dashboard components: $VISUALIZATIONS visualizations"
    print_info "📊 Performance data: $PERFORMANCE_DOCS documents"
    print_info "🚨 Alerts configured: $ALERTS"
    print_info "⚡ Query performance: ${QUERY_TIME}s"
    print_info "📊 Performance metrics:"
    print_info "   - P50: ${P50}ms"
    print_info "   - P95: ${P95}ms"
    print_info "   - P99: ${P99}ms"
    print_info "   - Slow requests: $SLOW_REQUESTS"
    print_info "   - Error rate: $ERROR_REQUESTS"
    
    print_step "🎯 Next Steps"
    print_info "1. Access dashboard: http://localhost:5601/app/dashboards"
    print_info "2. Verify visualizations are displaying correctly"
    print_info "3. Test alert functionality"
    print_info "4. Monitor real-time performance metrics"
    
else
    print_warning "⚠️  Dashboard requires manual setup"
    print_info "📋 Follow manual setup guide: infrastructure/logging/API_PERFORMANCE_DASHBOARD_MANUAL_SETUP.md"
fi

show_completion "API Performance Dashboard Test"
