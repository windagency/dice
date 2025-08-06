#!/bin/bash

# DICE Security Monitoring Dashboard Creation Script
# Creates Security Monitoring Dashboard with visualizations and alerts
# Usage: ./create-security-dashboard.sh

set -euo pipefail

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
KIBANA_HOST="localhost:5601"
ELASTICSEARCH_HOST="localhost:9200"

echo -e "${MAGENTA}🚀 Creating DICE Security Monitoring Dashboard...${NC}"

# Function to create visualization using correct API format
create_visualization() {
    local viz_name="$1"
    local viz_title="$2"
    local index_pattern="$3"
    local vis_state="$4"
    
    echo -e "${CYAN}Creating visualization: ${viz_title}${NC}"
    
    # Create visualization using Kibana 7.17.0 API format
    curl -X POST "http://${KIBANA_HOST}/api/saved_objects/visualization/${viz_name}" \
        -H 'Content-Type: application/json' \
        -H 'kbn-xsrf: true' \
        -d "{
            \"type\": \"visualization\",
            \"id\": \"${viz_name}\",
            \"attributes\": {
                \"title\": \"${viz_title}\",
                \"visState\": ${vis_state},
                \"uiStateJSON\": \"{}\",
                \"description\": \"DICE Security Monitoring - ${viz_title}\",
                \"savedSearchRefName\": \"search_0\"
            },
            \"references\": [
                {
                    \"name\": \"search_0\",
                    \"type\": \"search\",
                    \"id\": \"${index_pattern}\"
                }
            ],
            \"migrationVersion\": {
                \"visualization\": \"7.11.0\"
            },
            \"coreMigrationVersion\": \"7.17.0\"
        }" && echo -e "${GREEN}✅ Visualization created: ${viz_title}${NC}" || echo -e "${YELLOW}⚠️  Visualization may already exist: ${viz_title}${NC}"
}

# Function to create dashboard
create_dashboard() {
    local dashboard_name="$1"
    local dashboard_title="$2"
    local visualizations="$3"
    
    echo -e "${MAGENTA}Creating dashboard: ${dashboard_title}${NC}"
    
    # Create dashboard configuration
    local dashboard_config="{
        \"title\": \"${dashboard_title}\",
        \"hits\": 0,
        \"description\": \"DICE Security Monitoring Dashboard - Real-time threat detection and OWASP compliance tracking\",
        \"panelsJSON\": \"${visualizations}\",
        \"optionsJSON\": \"{\\\"hidePanelTitles\\\":false,\\\"useMargins\\\":true}\",
        \"version\": \"7.17.0\",
        \"timeRestore\": false,
        \"kibanaSavedObjectMeta\": {
            \"searchSourceJSON\": \"{\\\"query\\\":{\\\"query\\\":\\\"\\\",\\\"language\\\":\\\"kuery\\\"},\\\"filter\\\":[]}\"
        }
    }"
    
    curl -X POST "http://${KIBANA_HOST}/api/saved_objects/dashboard/${dashboard_name}" \
        -H 'Content-Type: application/json' \
        -H 'kbn-xsrf: true' \
        -d "{
            \"type\": \"dashboard\",
            \"id\": \"${dashboard_name}\",
            \"attributes\": ${dashboard_config},
            \"migrationVersion\": {
                \"dashboard\": \"7.11.0\"
            },
            \"coreMigrationVersion\": \"7.17.0\"
        }" && echo -e "${GREEN}✅ Dashboard created: ${dashboard_title}${NC}" || echo -e "${YELLOW}⚠️  Dashboard may already exist: ${dashboard_title}${NC}"
}

# Create Security Visualizations

# 1. Authentication Events Timeline
echo -e "${BLUE}Creating Authentication Events Timeline...${NC}"
create_visualization "security-auth-events-timeline" "Authentication Events Timeline" "dice-security" '{
    "title": "Authentication Events Timeline",
    "type": "line",
    "params": {
        "type": "line",
        "grid": {"categoryLines": false},
        "categoryAxes": [{"id": "CategoryAxis-1", "type": "category", "position": "bottom"}],
        "valueAxes": [{"id": "ValueAxis-1", "type": "value", "position": "left"}],
        "seriesParams": [{"show": true, "type": "line", "mode": "normal", "data": {"label": "Authentication Events", "id": "1"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": true, "lineWidth": 2, "interpolate": "linear", "showCircles": true}],
        "addTooltip": true,
        "addLegend": true,
        "legendPosition": "right"
    },
    "aggs": [
        {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
        {"id": "2", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-24h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT1H", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}},
        {"id": "3", "enabled": true, "type": "terms", "schema": "group", "params": {"field": "action", "size": 5, "order": "desc", "orderBy": "1"}}
    ]
}'

# 2. OWASP Top 10 Distribution
echo -e "${BLUE}Creating OWASP Top 10 Distribution...${NC}"
create_visualization "security-owasp-distribution" "OWASP Top 10 Distribution" "dice-security" '{
    "title": "OWASP Top 10 Distribution",
    "type": "pie",
    "params": {
        "type": "pie",
        "addTooltip": true,
        "addLegend": true,
        "legendPosition": "right",
        "isDonut": false,
        "labels": {"show": false, "values": true, "position": "default"}
    },
    "aggs": [
        {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
        {"id": "2", "enabled": true, "type": "terms", "schema": "segment", "params": {"field": "owaspCategory", "size": 10, "order": "desc", "orderBy": "1"}}
    ]
}'

# 3. IP Threat Analysis
echo -e "${BLUE}Creating IP Threat Analysis...${NC}"
create_visualization "security-ip-threat-analysis" "IP Threat Analysis" "dice-security" '{
    "title": "IP Threat Analysis",
    "type": "heatmap",
    "params": {
        "type": "heatmap",
        "addTooltip": true,
        "enableHover": false,
        "legendPosition": "right",
        "legendMaxLines": 1,
        "times": [],
        "addLegend": true,
        "dimensions": {"x": {"accessor": 0, "format": {"id": "string", "params": {"transform": "lowercase"}}, "params": {"date": true, "interval": "PT30M", "intervalESValue": 30, "intervalESUnit": "m", "format": "HH:mm", "bounds": {"min": "2025-08-06T00:00:00.000Z", "max": "2025-08-06T23:59:59.999Z"}}, "aggType": "date_histogram"}, "y": {"accessor": 1, "format": {"id": "string", "params": {"transform": "lowercase"}}, "params": {"field": "metadata.ip", "size": 10, "order": "desc", "orderBy": "_count"}, "aggType": "terms"}}
    },
    "aggs": [
        {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
        {"id": "2", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-24h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT30M", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}},
        {"id": "3", "enabled": true, "type": "terms", "schema": "group", "params": {"field": "metadata.ip", "size": 10, "order": "desc", "orderBy": "1"}}
    ]
}'

# 4. Security Events by Level
echo -e "${BLUE}Creating Security Events by Level...${NC}"
create_visualization "security-events-by-level" "Security Events by Level" "dice-security" '{
    "title": "Security Events by Level",
    "type": "histogram",
    "params": {
        "type": "histogram",
        "grid": {"categoryLines": false},
        "categoryAxes": [{"id": "CategoryAxis-1", "type": "category", "position": "bottom"}],
        "valueAxes": [{"id": "ValueAxis-1", "type": "value", "position": "left"}],
        "seriesParams": [{"show": true, "type": "histogram", "mode": "stacked", "data": {"label": "Security Events", "id": "1"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": false, "showCircles": false}],
        "addTooltip": true,
        "addLegend": true,
        "legendPosition": "right"
    },
    "aggs": [
        {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
        {"id": "2", "enabled": true, "type": "terms", "schema": "segment", "params": {"field": "level", "size": 5, "order": "desc", "orderBy": "1"}},
        {"id": "3", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-24h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT2H", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}}
    ]
}'

# Create Security Dashboard with all visualizations
echo -e "${BLUE}Creating Security Monitoring Dashboard...${NC}"

# Dashboard panels configuration
local panels_json='[
    {"type": "visualization", "id": "security-auth-events-timeline", "version": "7.17.0", "gridData": {"x": 0, "y": 0, "w": 12, "h": 8, "i": "1"}},
    {"type": "visualization", "id": "security-owasp-distribution", "version": "7.17.0", "gridData": {"x": 12, "y": 0, "w": 12, "h": 8, "i": "2"}},
    {"type": "visualization", "id": "security-ip-threat-analysis", "version": "7.17.0", "gridData": {"x": 0, "y": 8, "w": 12, "h": 8, "i": "3"}},
    {"type": "visualization", "id": "security-events-by-level", "version": "7.17.0", "gridData": {"x": 12, "y": 8, "w": 12, "h": 8, "i": "4"}}
]'

create_dashboard "dice-security-monitoring-dashboard" "DICE Security Monitoring Dashboard" "$panels_json"

# Create security alerts
echo -e "${BLUE}Creating Security Alerts...${NC}"

# Alert 1: High Authentication Failure Rate
echo -e "${CYAN}Creating High Authentication Failure Rate Alert...${NC}"
curl -X POST "http://${KIBANA_HOST}/api/alerting/rule" \
    -H 'Content-Type: application/json' \
    -H 'kbn-xsrf: true' \
    -d '{
        "name": "High Authentication Failure Rate",
        "consumer": "alerts",
        "tags": ["security", "authentication"],
        "rule_type_id": "siem.signals",
        "schedule": {"interval": "1m"},
        "actions": [],
        "params": {
            "query": "level:error AND action:authentication.failure",
            "language": "kuery",
            "filters": [],
            "saved_id": null,
            "response_actions": [],
            "timeline_id": null,
            "timeline_title": null,
            "meta": {},
            "version": 1,
            "rule_id": "high-auth-failure-rate",
            "max_signals": 100
        }
    }' && echo -e "${GREEN}✅ Alert created: High Authentication Failure Rate${NC}" || echo -e "${YELLOW}⚠️  Alert may already exist${NC}"

# Alert 2: OWASP Security Event Detected
echo -e "${CYAN}Creating OWASP Security Event Alert...${NC}"
curl -X POST "http://${KIBANA_HOST}/api/alerting/rule" \
    -H 'Content-Type: application/json' \
    -H 'kbn-xsrf: true' \
    -d '{
        "name": "OWASP Security Event Detected",
        "consumer": "alerts",
        "tags": ["security", "owasp"],
        "rule_type_id": "siem.signals",
        "schedule": {"interval": "1m"},
        "actions": [],
        "params": {
            "query": "exists:owaspCategory",
            "language": "kuery",
            "filters": [],
            "saved_id": null,
            "response_actions": [],
            "timeline_id": null,
            "timeline_title": null,
            "meta": {},
            "version": 1,
            "rule_id": "owasp-security-event",
            "max_signals": 100
        }
    }' && echo -e "${GREEN}✅ Alert created: OWASP Security Event Detected${NC}" || echo -e "${YELLOW}⚠️  Alert may already exist${NC}"

# Generate additional test data for security monitoring
echo -e "${BLUE}Generating additional security test data...${NC}"
for i in {1..5}; do
    curl -X POST "http://${ELASTICSEARCH_HOST}/dice-security-$(date +%Y.%m.%d)/_doc" \
        -H 'Content-Type: application/json' \
        -d "{
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\",
            \"level\": \"error\",
            \"service\": \"backend-api\",
            \"correlationId\": \"security-test-${i}\",
            \"sessionId\": \"security-session-${i}\",
            \"userId\": \"test-user-${i}\",
            \"component\": \"SecurityInterceptor\",
            \"action\": \"authentication.failure\",
            \"message\": \"Failed login attempt from suspicious IP\",
            \"metadata\": {
                \"ip\": \"192.168.1.${i}\",
                \"userAgent\": \"Mozilla/5.0 (Suspicious Browser)\",
                \"attemptCount\": ${i},
                \"reason\": \"invalid_credentials\"
            },
            \"tags\": [\"security\", \"authentication\", \"failure\", \"suspicious\"],
            \"securityEvent\": {
                \"type\": \"authentication_failure\",
                \"severity\": \"high\",
                \"source\": \"login_endpoint\"
            },
            \"owaspCategory\": \"A07\"
        }"
done

echo -e "${GREEN}✅ Security Monitoring Dashboard creation completed!${NC}"
echo -e "${CYAN}Access your dashboard at: http://${KIBANA_HOST}/app/dashboards#/view/dice-security-monitoring-dashboard${NC}"
echo -e "${CYAN}Dashboard includes:${NC}"
echo -e "${CYAN}- Authentication Events Timeline${NC}"
echo -e "${CYAN}- OWASP Top 10 Distribution${NC}"
echo -e "${CYAN}- IP Threat Analysis${NC}"
echo -e "${CYAN}- Security Events by Level${NC}"
echo -e "${CYAN}- Real-time security alerts${NC}"
