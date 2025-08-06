#!/bin/bash

# Test Security Monitoring Dashboard
# Tests dashboard functionality and performance

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

show_banner "Security Dashboard Test" "Testing Security Monitoring Dashboard functionality and performance"

# Configuration
KIBANA_HOST="http://localhost:5601"
ELASTICSEARCH_HOST="http://localhost:9200"
DASHBOARD_ID="dice-security-monitoring-dashboard"

print_step "🔍 Testing Security Dashboard Components"

# Test 1: Check if dashboard exists
print_status "Testing dashboard existence..."
DASHBOARD_EXISTS=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=dice-security-monitoring-dashboard" | jq '.total')

if [ "$DASHBOARD_EXISTS" -gt 0 ]; then
    print_success "✅ Security Monitoring Dashboard found"
else
    print_warning "⚠️  Dashboard not found - manual creation required"
fi

# Test 2: Check visualizations
print_status "Testing visualization components..."
VISUALIZATIONS=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=visualization" | jq '.total')
print_info "Found $VISUALIZATIONS visualizations"

# Test 3: Check security data availability
print_status "Testing security data availability..."
SECURITY_DOCS=$(curl -s "${ELASTICSEARCH_HOST}/dice-security-*/_count" | jq '.count')
print_info "Found $SECURITY_DOCS security documents"

# Test 4: Test dashboard performance
print_status "Testing dashboard performance..."
START_TIME=$(date +%s)
DASHBOARD_RESPONSE=$(curl -s -w "%{http_code}" "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=dice-security-monitoring-dashboard" -o /dev/null)
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

# Test 6: Validate data quality
print_status "Testing data quality..."
OWASP_EVENTS=$(curl -s "${ELASTICSEARCH_HOST}/dice-security-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"exists": {"field": "owaspCategory"}},
  "size": 0
}' | jq '.hits.total.value')

AUTH_EVENTS=$(curl -s "${ELASTICSEARCH_HOST}/dice-security-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"action": "authentication.failure"}},
  "size": 0
}' | jq '.hits.total.value')

print_info "OWASP events: $OWASP_EVENTS"
print_info "Authentication events: $AUTH_EVENTS"

# Test 7: Performance metrics
print_status "Testing query performance..."
QUERY_START=$(date +%s.%N)
curl -s "${ELASTICSEARCH_HOST}/dice-security-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"range": {"@timestamp": {"gte": "now-1h"}}},
  "size": 0
}' > /dev/null
QUERY_END=$(date +%s.%N)
QUERY_TIME=$(echo "$QUERY_END - $QUERY_START" | bc -l)

print_info "Query performance: ${QUERY_TIME}s"

# Summary
print_step "📊 Security Dashboard Test Summary"

if [ "$DASHBOARD_EXISTS" -gt 0 ] && [ "$SECURITY_DOCS" -gt 0 ]; then
    print_success "✅ Security Monitoring Dashboard is operational"
    print_info "📈 Dashboard components: $VISUALIZATIONS visualizations"
    print_info "📊 Security data: $SECURITY_DOCS documents"
    print_info "🚨 Alerts configured: $ALERTS"
    print_info "⚡ Query performance: ${QUERY_TIME}s"
    
    print_step "🎯 Next Steps"
    print_info "1. Access dashboard: http://localhost:5601/app/dashboards"
    print_info "2. Verify visualizations are displaying correctly"
    print_info "3. Test alert functionality"
    print_info "4. Monitor real-time security events"
    
else
    print_warning "⚠️  Dashboard requires manual setup"
    print_info "📋 Follow manual setup guide: infrastructure/logging/SECURITY_DASHBOARD_MANUAL_SETUP.md"
fi

show_completion "Security Dashboard Test"
