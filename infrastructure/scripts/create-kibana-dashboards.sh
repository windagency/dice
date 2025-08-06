#!/bin/bash

# DICE Kibana Dashboard Creation Script
# Creates comprehensive dashboards with visualizations and alerts
# Usage: ./create-kibana-dashboards.sh [options]

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

# Function to show usage
show_usage() {
    echo "DICE Kibana Dashboard Creation"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --security-dashboard     Create Security Monitoring Dashboard"
    echo "  --performance-dashboard  Create API Performance Dashboard"
    echo "  --health-dashboard       Create Service Health Dashboard"
    echo "  --user-activity-dashboard Create User Activity Dashboard"
    echo "  --operational-dashboard  Create Operational Overview Dashboard"
    echo "  --all-dashboards         Create all dashboards"
    echo "  --test-visualizations    Test visualization creation"
    echo "  -h, --help               Show help message"
    echo ""
    echo "Examples:"
    echo "  $0 --all-dashboards      # Create all dashboards"
    echo "  $0 --security-dashboard  # Create security dashboard only"
    echo ""
}

# Function to create visualization
create_visualization() {
    local viz_name="$1"
    local viz_type="$2"
    local index_pattern="$3"
    local viz_config="$4"
    
    echo -e "${CYAN}Creating visualization: ${viz_name}${NC}"
    
    curl -X POST "http://${KIBANA_HOST}/api/saved_objects/visualization/${viz_name}" \
        -H 'Content-Type: application/json' \
        -H 'kbn-xsrf: true' \
        -d "{
            \"type\": \"visualization\",
            \"id\": \"${viz_name}\",
            \"attributes\": {
                \"title\": \"${viz_name}\",
                \"visState\": ${viz_config},
                \"uiStateJSON\": \"{}\",
                \"description\": \"\",
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
        }" || echo -e "${YELLOW}⚠️  Visualization creation failed (may already exist)${NC}"
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
        \"description\": \"DICE ${dashboard_title}\",
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
        }" || echo -e "${YELLOW}⚠️  Dashboard creation failed (may already exist)${NC}"
}

# Function to create Security Monitoring Dashboard
create_security_dashboard() {
    echo -e "${BLUE}Creating Security Monitoring Dashboard...${NC}"
    
    # Authentication Events Timeline
    create_visualization "security-auth-events-timeline" "line" "dice-security" '{
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
    
    # OWASP Top 10 Distribution
    create_visualization "security-owasp-distribution" "pie" "dice-security" '{
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
    
    # IP Threat Analysis
    create_visualization "security-ip-threat-analysis" "heatmap" "dice-security" '{
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
            "dimensions": {"x": {"accessor": 0, "format": {"id": "string", "params": {"transform": "lowercase"}}, "params": {"date": true, "interval": "PT30M", "intervalESValue": 30, "intervalESUnit": "m", "format": "HH:mm", "bounds": {"min": "2025-08-06T00:00:00.000Z", "max": "2025-08-06T23:59:59.999Z"}}, "aggType": "date_histogram"}, "y": {"accessor": 1, "format": {"id": "string", "params": {"transform": "lowercase"}}, "params": {"field": "ip", "size": 10, "order": "desc", "orderBy": "_count"}, "aggType": "terms"}}
        },
        "aggs": [
            {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
            {"id": "2", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-24h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT30M", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}},
            {"id": "3", "enabled": true, "type": "terms", "schema": "group", "params": {"field": "ip", "size": 10, "order": "desc", "orderBy": "1"}}
        ]
    }'
    
    # Create dashboard with visualizations
    local panels_json='[
        {"type": "visualization", "id": "security-auth-events-timeline", "version": "7.17.0", "gridData": {"x": 0, "y": 0, "w": 12, "h": 8, "i": "1"}},
        {"type": "visualization", "id": "security-owasp-distribution", "version": "7.17.0", "gridData": {"x": 12, "y": 0, "w": 12, "h": 8, "i": "2"}},
        {"type": "visualization", "id": "security-ip-threat-analysis", "version": "7.17.0", "gridData": {"x": 0, "y": 8, "w": 24, "h": 8, "i": "3"}}
    ]'
    
    create_dashboard "dice-security-dashboard" "Security Monitoring Dashboard" "$panels_json"
}

# Function to create API Performance Dashboard
create_performance_dashboard() {
    echo -e "${BLUE}Creating API Performance Dashboard...${NC}"
    
    # Response Time Percentiles
    create_visualization "performance-response-time-percentiles" "line" "dice-performance" '{
        "title": "Response Time Percentiles",
        "type": "line",
        "params": {
            "type": "line",
            "grid": {"categoryLines": false},
            "categoryAxes": [{"id": "CategoryAxis-1", "type": "category", "position": "bottom"}],
            "valueAxes": [{"id": "ValueAxis-1", "type": "value", "position": "left"}],
            "seriesParams": [
                {"show": true, "type": "line", "mode": "normal", "data": {"label": "P50", "id": "1"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": true, "lineWidth": 2, "interpolate": "linear", "showCircles": true},
                {"show": true, "type": "line", "mode": "normal", "data": {"label": "P95", "id": "2"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": true, "lineWidth": 2, "interpolate": "linear", "showCircles": true},
                {"show": true, "type": "line", "mode": "normal", "data": {"label": "P99", "id": "3"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": true, "lineWidth": 2, "interpolate": "linear", "showCircles": true}
            ],
            "addTooltip": true,
            "addLegend": true,
            "legendPosition": "right"
        },
        "aggs": [
            {"id": "1", "enabled": true, "type": "percentiles", "schema": "metric", "params": {"field": "metadata.duration", "percents": [50]}},
            {"id": "2", "enabled": true, "type": "percentiles", "schema": "metric", "params": {"field": "metadata.duration", "percents": [95]}},
            {"id": "3", "enabled": true, "type": "percentiles", "schema": "metric", "params": {"field": "metadata.duration", "percents": [99]}},
            {"id": "4", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-1h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT5M", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}}
        ]
    }'
    
    # Error Rate by Endpoint
    create_visualization "performance-error-rate-by-endpoint" "bar" "dice-performance" '{
        "title": "Error Rate by Endpoint",
        "type": "histogram",
        "params": {
            "type": "histogram",
            "grid": {"categoryLines": false},
            "categoryAxes": [{"id": "CategoryAxis-1", "type": "category", "position": "bottom"}],
            "valueAxes": [{"id": "ValueAxis-1", "type": "value", "position": "left"}],
            "seriesParams": [{"show": true, "type": "histogram", "mode": "stacked", "data": {"label": "Error Rate", "id": "1"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": false, "showCircles": false}],
            "addTooltip": true,
            "addLegend": true,
            "legendPosition": "right"
        },
        "aggs": [
            {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
            {"id": "2", "enabled": true, "type": "terms", "schema": "segment", "params": {"field": "metadata.endpoint", "size": 10, "order": "desc", "orderBy": "1"}},
            {"id": "3", "enabled": true, "type": "filters", "schema": "group", "params": {"filters": [{"input": {"query": "metadata.statusCode:>=400"}, "label": "Errors"}]}}
        ]
    }'
    
    # Request Volume Trends
    create_visualization "performance-request-volume-trends" "area" "dice-performance" '{
        "title": "Request Volume Trends",
        "type": "line",
        "params": {
            "type": "line",
            "grid": {"categoryLines": false},
            "categoryAxes": [{"id": "CategoryAxis-1", "type": "category", "position": "bottom"}],
            "valueAxes": [{"id": "ValueAxis-1", "type": "value", "position": "left"}],
            "seriesParams": [{"show": true, "type": "line", "mode": "normal", "data": {"label": "Request Volume", "id": "1"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": true, "lineWidth": 2, "interpolate": "linear", "showCircles": true}],
            "addTooltip": true,
            "addLegend": true,
            "legendPosition": "right"
        },
        "aggs": [
            {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
            {"id": "2", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-1h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT5M", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}}
        ]
    }'
    
    # Create dashboard with visualizations
    local panels_json='[
        {"type": "visualization", "id": "performance-response-time-percentiles", "version": "7.17.0", "gridData": {"x": 0, "y": 0, "w": 12, "h": 8, "i": "1"}},
        {"type": "visualization", "id": "performance-error-rate-by-endpoint", "version": "7.17.0", "gridData": {"x": 12, "y": 0, "w": 12, "h": 8, "i": "2"}},
        {"type": "visualization", "id": "performance-request-volume-trends", "version": "7.17.0", "gridData": {"x": 0, "y": 8, "w": 24, "h": 8, "i": "3"}}
    ]'
    
    create_dashboard "dice-performance-dashboard" "API Performance Dashboard" "$panels_json"
}

# Function to create Service Health Dashboard
create_health_dashboard() {
    echo -e "${BLUE}Creating Service Health Dashboard...${NC}"
    
    # Container Status Overview
    create_visualization "health-container-status" "table" "dice-logs" '{
        "title": "Container Status Overview",
        "type": "table",
        "params": {
            "type": "table",
            "perPage": 10,
            "showPartialRows": false,
            "showMeticsAtAllLevels": false,
            "sort": {"columnIndex": null, "direction": null},
            "showTotal": false,
            "showToolbar": true,
            "totalFunc": "sum"
        },
        "aggs": [
            {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
            {"id": "2", "enabled": true, "type": "terms", "schema": "bucket", "params": {"field": "service", "size": 10, "order": "desc", "orderBy": "1"}},
            {"id": "3", "enabled": true, "type": "terms", "schema": "bucket", "params": {"field": "level", "size": 5, "order": "desc", "orderBy": "1"}}
        ]
    }'
    
    # Log Volume by Service
    create_visualization "health-log-volume-by-service" "bar" "dice-logs" '{
        "title": "Log Volume by Service",
        "type": "histogram",
        "params": {
            "type": "histogram",
            "grid": {"categoryLines": false},
            "categoryAxes": [{"id": "CategoryAxis-1", "type": "category", "position": "bottom"}],
            "valueAxes": [{"id": "ValueAxis-1", "type": "value", "position": "left"}],
            "seriesParams": [{"show": true, "type": "histogram", "mode": "stacked", "data": {"label": "Log Volume", "id": "1"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": false, "showCircles": false}],
            "addTooltip": true,
            "addLegend": true,
            "legendPosition": "right"
        },
        "aggs": [
            {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
            {"id": "2", "enabled": true, "type": "terms", "schema": "segment", "params": {"field": "service", "size": 10, "order": "desc", "orderBy": "1"}},
            {"id": "3", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-1h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT10M", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}}
        ]
    }'
    
    # Create dashboard with visualizations
    local panels_json='[
        {"type": "visualization", "id": "health-container-status", "version": "7.17.0", "gridData": {"x": 0, "y": 0, "w": 12, "h": 8, "i": "1"}},
        {"type": "visualization", "id": "health-log-volume-by-service", "version": "7.17.0", "gridData": {"x": 12, "y": 0, "w": 12, "h": 8, "i": "2"}}
    ]'
    
    create_dashboard "dice-health-dashboard" "Service Health Dashboard" "$panels_json"
}

# Function to create User Activity Dashboard
create_user_activity_dashboard() {
    echo -e "${BLUE}Creating User Activity Dashboard...${NC}"
    
    # User Interaction Heatmap
    create_visualization "user-activity-interaction-heatmap" "heatmap" "dice-logs" '{
        "title": "User Interaction Heatmap",
        "type": "heatmap",
        "params": {
            "type": "heatmap",
            "addTooltip": true,
            "enableHover": false,
            "legendPosition": "right",
            "legendMaxLines": 1,
            "times": [],
            "addLegend": true,
            "dimensions": {"x": {"accessor": 0, "format": {"id": "string", "params": {"transform": "lowercase"}}, "params": {"date": true, "interval": "PT1H", "intervalESValue": 1, "intervalESUnit": "h", "format": "HH:mm", "bounds": {"min": "2025-08-06T00:00:00.000Z", "max": "2025-08-06T23:59:59.999Z"}}, "aggType": "date_histogram"}, "y": {"accessor": 1, "format": {"id": "string", "params": {"transform": "lowercase"}}, "params": {"field": "component", "size": 10, "order": "desc", "orderBy": "_count"}, "aggType": "terms"}}
        },
        "aggs": [
            {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
            {"id": "2", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-24h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT1H", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}},
            {"id": "3", "enabled": true, "type": "terms", "schema": "group", "params": {"field": "component", "size": 10, "order": "desc", "orderBy": "1"}}
        ]
    }'
    
    # Error Tracking by Browser
    create_visualization "user-activity-error-tracking" "pie" "dice-logs" '{
        "title": "Error Tracking by Browser",
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
            {"id": "2", "enabled": true, "type": "terms", "schema": "segment", "params": {"field": "level", "size": 5, "order": "desc", "orderBy": "1"}}
        ]
    }'
    
    # Create dashboard with visualizations
    local panels_json='[
        {"type": "visualization", "id": "user-activity-interaction-heatmap", "version": "7.17.0", "gridData": {"x": 0, "y": 0, "w": 12, "h": 8, "i": "1"}},
        {"type": "visualization", "id": "user-activity-error-tracking", "version": "7.17.0", "gridData": {"x": 12, "y": 0, "w": 12, "h": 8, "i": "2"}}
    ]'
    
    create_dashboard "dice-user-activity-dashboard" "User Activity Dashboard" "$panels_json"
}

# Function to create Operational Overview Dashboard
create_operational_dashboard() {
    echo -e "${BLUE}Creating Operational Overview Dashboard...${NC}"
    
    # Cross-Service Correlation
    create_visualization "operational-cross-service-correlation" "line" "dice-logs" '{
        "title": "Cross-Service Correlation",
        "type": "line",
        "params": {
            "type": "line",
            "grid": {"categoryLines": false},
            "categoryAxes": [{"id": "CategoryAxis-1", "type": "category", "position": "bottom"}],
            "valueAxes": [{"id": "ValueAxis-1", "type": "value", "position": "left"}],
            "seriesParams": [{"show": true, "type": "line", "mode": "normal", "data": {"label": "Requests", "id": "1"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": true, "lineWidth": 2, "interpolate": "linear", "showCircles": true}],
            "addTooltip": true,
            "addLegend": true,
            "legendPosition": "right"
        },
        "aggs": [
            {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
            {"id": "2", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-1h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT5M", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}},
            {"id": "3", "enabled": true, "type": "terms", "schema": "group", "params": {"field": "service", "size": 5, "order": "desc", "orderBy": "1"}}
        ]
    }'
    
    # Log Volume Analysis
    create_visualization "operational-log-volume-analysis" "area" "dice-logs" '{
        "title": "Log Volume Analysis",
        "type": "line",
        "params": {
            "type": "line",
            "grid": {"categoryLines": false},
            "categoryAxes": [{"id": "CategoryAxis-1", "type": "category", "position": "bottom"}],
            "valueAxes": [{"id": "ValueAxis-1", "type": "value", "position": "left"}],
            "seriesParams": [{"show": true, "type": "line", "mode": "normal", "data": {"label": "Log Volume", "id": "1"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": true, "lineWidth": 2, "interpolate": "linear", "showCircles": true}],
            "addTooltip": true,
            "addLegend": true,
            "legendPosition": "right"
        },
        "aggs": [
            {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
            {"id": "2", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-1h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT5M", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}}
        ]
    }'
    
    # Create dashboard with visualizations
    local panels_json='[
        {"type": "visualization", "id": "operational-cross-service-correlation", "version": "7.17.0", "gridData": {"x": 0, "y": 0, "w": 12, "h": 8, "i": "1"}},
        {"type": "visualization", "id": "operational-log-volume-analysis", "version": "7.17.0", "gridData": {"x": 12, "y": 0, "w": 12, "h": 8, "i": "2"}}
    ]'
    
    create_dashboard "dice-operational-dashboard" "Operational Overview Dashboard" "$panels_json"
}

# Function to create all dashboards
create_all_dashboards() {
    echo -e "${MAGENTA}🚀 Creating all DICE Kibana dashboards...${NC}"
    
    create_security_dashboard
    create_performance_dashboard
    create_health_dashboard
    create_user_activity_dashboard
    create_operational_dashboard
    
    echo -e "${GREEN}✅ All dashboards created successfully!${NC}"
    echo -e "${CYAN}Access your dashboards at: http://${KIBANA_HOST}/app/dashboards${NC}"
}

# Function to test visualizations
test_visualizations() {
    echo -e "${BLUE}Testing visualization creation...${NC}"
    
    # Test a simple visualization
    create_visualization "test-viz" "line" "dice-logs" '{
        "title": "Test Visualization",
        "type": "line",
        "params": {
            "type": "line",
            "grid": {"categoryLines": false},
            "categoryAxes": [{"id": "CategoryAxis-1", "type": "category", "position": "bottom"}],
            "valueAxes": [{"id": "ValueAxis-1", "type": "value", "position": "left"}],
            "seriesParams": [{"show": true, "type": "line", "mode": "normal", "data": {"label": "Count", "id": "1"}, "valueAxis": "ValueAxis-1", "drawLinesBetweenPoints": true, "lineWidth": 2, "interpolate": "linear", "showCircles": true}],
            "addTooltip": true,
            "addLegend": true,
            "legendPosition": "right"
        },
        "aggs": [
            {"id": "1", "enabled": true, "type": "count", "schema": "metric", "params": {}},
            {"id": "2", "enabled": true, "type": "date_histogram", "schema": "segment", "params": {"field": "timestamp", "timeRange": {"from": "now-1h", "to": "now"}, "useNormalizedEsInterval": true, "scaleMetricValues": false, "interval": "PT5M", "drop_partials": false, "min_doc_count": 1, "extended_bounds": {}}}
        ]
    }'
    
    echo -e "${GREEN}✅ Test visualization created successfully!${NC}"
}

# Main function
main() {
    local command="${1:-help}"
    
    case $command in
        --security-dashboard)
            create_security_dashboard
            ;;
        --performance-dashboard)
            create_performance_dashboard
            ;;
        --health-dashboard)
            create_health_dashboard
            ;;
        --user-activity-dashboard)
            create_user_activity_dashboard
            ;;
        --operational-dashboard)
            create_operational_dashboard
            ;;
        --all-dashboards)
            create_all_dashboards
            ;;
        --test-visualizations)
            test_visualizations
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
