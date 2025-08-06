#!/bin/bash

# Test User Activity Dashboard
# Tests dashboard functionality and performance

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

show_banner "User Activity Dashboard Test" "Testing User Activity Dashboard functionality and performance"

# Configuration
KIBANA_HOST="http://localhost:5601"
ELASTICSEARCH_HOST="http://localhost:9200"
DASHBOARD_ID="dice-user-activity-dashboard"

print_step "🔍 Testing User Activity Dashboard Components"

# Test 1: Check if dashboard exists
print_status "Testing dashboard existence..."
DASHBOARD_EXISTS=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=dice-user-activity-dashboard" | jq '.total')

if [ "$DASHBOARD_EXISTS" -gt 0 ]; then
    print_success "✅ User Activity Dashboard found"
else
    print_warning "⚠️  Dashboard not found - manual creation required"
fi

# Test 2: Check visualizations
print_status "Testing visualization components..."
VISUALIZATIONS=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=visualization" | jq '.total')
print_info "Found $VISUALIZATIONS visualizations"

# Test 3: Check user activity data availability
print_status "Testing user activity data availability..."
USER_ACTIVITY_DOCS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"service": "pwa-frontend"}},
  "size": 0
}' | jq '.hits.total.value')
print_info "Found $USER_ACTIVITY_DOCS user activity documents"

# Test 4: Test dashboard performance
print_status "Testing dashboard performance..."
START_TIME=$(date +%s)
DASHBOARD_RESPONSE=$(curl -s -w "%{http_code}" "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=dice-user-activity-dashboard" -o /dev/null)
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

# Test 6: Validate user activity data quality
print_status "Testing data quality..."
CLICK_INTERACTIONS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"action": "handleClick"}},
  "size": 0
}' | jq '.hits.total.value')

ERROR_INTERACTIONS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"bool": {"must": [{"term": {"service": "pwa-frontend"}}, {"term": {"level": "error"}}]}},
  "size": 0
}' | jq '.hits.total.value')

COMPONENT_INTERACTIONS=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"service": "pwa-frontend"}},
  "aggs": {"components": {"terms": {"field": "component", "size": 10}}},
  "size": 0
}' | jq '.aggregations.components.buckets | length')

print_info "Click interactions: $CLICK_INTERACTIONS"
print_info "Error interactions: $ERROR_INTERACTIONS"
print_info "Unique components: $COMPONENT_INTERACTIONS"

# Test 7: Performance metrics
print_status "Testing query performance..."
QUERY_START=$(date +%s.%N)
curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"range": {"@timestamp": {"gte": "now-1h"}}},
  "aggs": {
    "user_actions": {"terms": {"field": "action", "size": 10}},
    "components": {"terms": {"field": "component", "size": 10}}
  },
  "size": 0
}' > /dev/null
QUERY_END=$(date +%s.%N)
QUERY_TIME=$(echo "$QUERY_END - $QUERY_START" | bc -l)

print_info "Query performance: ${QUERY_TIME}s"

# Test 8: Check user engagement patterns
print_status "Testing user engagement patterns..."
HOURLY_ACTIVITY=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"service": "pwa-frontend"}},
  "aggs": {
    "hourly_activity": {
      "date_histogram": {
        "field": "@timestamp",
        "interval": "1h",
        "format": "yyyy-MM-dd HH:mm"
      }
    }
  },
  "size": 0
}' | jq '.aggregations.hourly_activity.buckets | length')

print_info "Hourly activity periods: $HOURLY_ACTIVITY"

# Test 9: Browser compatibility check
print_status "Testing browser compatibility data..."
BROWSER_DATA=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"service": "pwa-frontend"}},
  "aggs": {"browsers": {"terms": {"field": "metadata.userAgent", "size": 5}}},
  "size": 0
}' | jq '.aggregations.browsers.buckets')

print_info "Browser data available:"
echo "$BROWSER_DATA" | jq -r '.[] | "  - \(.key // "Unknown"): \(.doc_count) interactions"'

# Test 10: User experience metrics
print_status "Testing user experience metrics..."
if [ "$USER_ACTIVITY_DOCS" -gt 0 ]; then
    ENGAGEMENT_RATE=$(echo "scale=2; $CLICK_INTERACTIONS * 100 / $USER_ACTIVITY_DOCS" | bc -l)
    ERROR_RATE=$(echo "scale=2; $ERROR_INTERACTIONS * 100 / $USER_ACTIVITY_DOCS" | bc -l)
    
    print_info "Engagement rate: ${ENGAGEMENT_RATE}%"
    print_info "Error rate: ${ERROR_RATE}%"
    
    if (( $(echo "$ERROR_RATE < 5" | bc -l) )); then
        print_success "✅ User experience: GOOD (Error rate: ${ERROR_RATE}%)"
    elif (( $(echo "$ERROR_RATE < 10" | bc -l) )); then
        print_warning "⚠️  User experience: WARNING (Error rate: ${ERROR_RATE}%)"
    else
        print_error "❌ User experience: CRITICAL (Error rate: ${ERROR_RATE}%)"
    fi
else
    print_warning "⚠️  No user activity data available for UX scoring"
fi

# Test 11: Feature usage analysis
print_status "Testing feature usage analysis..."
COMPONENT_USAGE=$(curl -s "${ELASTICSEARCH_HOST}/dice-logs-*/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"service": "pwa-frontend"}},
  "aggs": {"components": {"terms": {"field": "component", "size": 10}}},
  "size": 0
}' | jq '.aggregations.components.buckets')

print_info "Component usage:"
echo "$COMPONENT_USAGE" | jq -r '.[] | "  - \(.key): \(.doc_count) interactions"'

# Summary
print_step "📊 User Activity Dashboard Test Summary"

if [ "$DASHBOARD_EXISTS" -gt 0 ] && [ "$USER_ACTIVITY_DOCS" -gt 0 ]; then
    print_success "✅ User Activity Dashboard is operational"
    print_info "📈 Dashboard components: $VISUALIZATIONS visualizations"
    print_info "📊 User activity data: $USER_ACTIVITY_DOCS documents"
    print_info "🚨 Alerts configured: $ALERTS"
    print_info "⚡ Query performance: ${QUERY_TIME}s"
    print_info "📊 UX metrics:"
    print_info "   - Click interactions: $CLICK_INTERACTIONS"
    print_info "   - Error interactions: $ERROR_INTERACTIONS"
    print_info "   - Unique components: $COMPONENT_INTERACTIONS"
    print_info "   - Engagement rate: ${ENGAGEMENT_RATE}%"
    print_info "   - Error rate: ${ERROR_RATE}%"
    
    print_step "🎯 Next Steps"
    print_info "1. Access dashboard: http://localhost:5601/app/dashboards"
    print_info "2. Verify visualizations are displaying correctly"
    print_info "3. Test alert functionality"
    print_info "4. Monitor real-time user activity"
    
else
    print_warning "⚠️  Dashboard requires manual setup"
    print_info "📋 Follow manual setup guide: infrastructure/logging/USER_ACTIVITY_DASHBOARD_MANUAL_SETUP.md"
fi

show_completion "User Activity Dashboard Test"
