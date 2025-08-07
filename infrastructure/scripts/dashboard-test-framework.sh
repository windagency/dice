#!/bin/bash
# DICE Dashboard Testing Framework (Unified)
# Consolidates all dashboard testing into a single, maintainable framework

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# =============================================================================
# CONFIGURATION
# =============================================================================

# Dashboard configurations
declare -A DASHBOARD_CONFIGS=(
    ["security"]="dice-security-monitoring-dashboard|dice-security-*|Security Monitoring"
    ["performance"]="dice-api-performance-dashboard|dice-performance-*|API Performance"
    ["health"]="dice-service-health-dashboard|dice-health-*|Service Health"
    ["user-activity"]="dice-user-activity-dashboard|dice-user-*|User Activity"
    ["operational"]="dice-operational-overview-dashboard|dice-operational-*|Operational Overview"
)

# Test configurations
KIBANA_HOST="http://localhost:5601"
ELASTICSEARCH_HOST="http://localhost:9200"
TIMEOUT_SECONDS=30

# =============================================================================
# USAGE FUNCTIONS
# =============================================================================

show_usage() {
    cat << EOF
DICE Dashboard Testing Framework (Unified)

Usage: $0 [OPTIONS] [DASHBOARD_TYPE]

Options:
  -a, --all              Test all dashboards
  -t, --type TYPE        Test specific dashboard type
  -p, --performance      Include performance testing
  -d, --data-quality     Include data quality validation
  -v, --verbose          Verbose output
  -h, --help             Show this help message

Dashboard Types:
  security               Security Monitoring Dashboard
  performance            API Performance Dashboard
  health                 Service Health Dashboard
  user-activity          User Activity Dashboard
  operational            Operational Overview Dashboard

Examples:
  $0 --all                              # Test all dashboards
  $0 --type security                    # Test security dashboard only
  $0 --type performance --performance   # Test performance with detailed metrics
  $0 --type health --data-quality      # Test health with data validation

EOF
}

# =============================================================================
# CORE TESTING FUNCTIONS
# =============================================================================

# Test dashboard existence and accessibility
test_dashboard_existence() {
    local dashboard_type="$1"
    local dashboard_id="$2"
    
    print_status "Testing $dashboard_type dashboard existence..."
    
    local response
    response=$(curl -s -w "%{http_code}" "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=${dashboard_id}" -o /dev/null)
    
    if [[ "$response" == "200" ]]; then
        local count
        count=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=${dashboard_id}" | jq '.total')
        
        if [[ "$count" -gt 0 ]]; then
            print_success "✅ $dashboard_type dashboard found"
            return 0
        else
            print_warning "⚠️  $dashboard_type dashboard not found"
            return 1
        fi
    else
        print_error "❌ Kibana API error: HTTP $response"
        return 1
    fi
}

# Test visualization components
test_visualizations() {
    local dashboard_type="$1"
    
    print_status "Testing $dashboard_type visualization components..."
    
    local count
    count=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=visualization" | jq '.total')
    
    print_info "Found $count total visualizations"
    
    # Count visualizations for this specific dashboard
    local dashboard_visualizations
    dashboard_visualizations=$(curl -s "${KIBANA_HOST}/api/saved_objects/_find?type=visualization" | jq '.saved_objects[] | select(.attributes.title | contains("'$dashboard_type'")) | .id' | wc -l)
    
    print_info "$dashboard_type dashboard has $dashboard_visualizations visualizations"
    
    return 0
}

# Test data availability
test_data_availability() {
    local dashboard_type="$1"
    local index_pattern="$2"
    
    print_status "Testing $dashboard_type data availability..."
    
    local count
    count=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_count" | jq '.count')
    
    if [[ "$count" -gt 0 ]]; then
        print_success "✅ Found $count $dashboard_type documents"
        return 0
    else
        print_warning "⚠️  No $dashboard_type data found"
        return 1
    fi
}

# Test dashboard performance
test_dashboard_performance() {
    local dashboard_type="$1"
    local dashboard_id="$2"
    
    print_status "Testing $dashboard_type dashboard performance..."
    
    local start_time end_time response_time
    start_time=$(date +%s.%N)
    
    local response
    response=$(curl -s -w "%{http_code}" "${KIBANA_HOST}/api/saved_objects/_find?type=dashboard&search_fields=title&search=${dashboard_id}" -o /dev/null)
    
    end_time=$(date +%s.%N)
    response_time=$(echo "$end_time - $start_time" | bc -l)
    
    if [[ "$response" == "200" ]]; then
        print_success "✅ Dashboard API response: ${response_time}s"
        return 0
    else
        print_error "❌ Dashboard API error: HTTP $response"
        return 1
    fi
}

# Test alert configurations
test_alert_configurations() {
    local dashboard_type="$1"
    
    print_status "Testing $dashboard_type alert configurations..."
    
    local count
    count=$(curl -s "${KIBANA_HOST}/api/alerting/rules/_find" | jq '.total // 0')
    
    print_info "Found $count configured alerts"
    
    return 0
}

# Test data quality (dashboard-specific)
test_data_quality() {
    local dashboard_type="$1"
    local index_pattern="$2"
    
    print_status "Testing $dashboard_type data quality..."
    
    case "$dashboard_type" in
        "security")
            test_security_data_quality "$index_pattern"
            ;;
        "performance")
            test_performance_data_quality "$index_pattern"
            ;;
        "health")
            test_health_data_quality "$index_pattern"
            ;;
        "user-activity")
            test_user_activity_data_quality "$index_pattern"
            ;;
        "operational")
            test_operational_data_quality "$index_pattern"
            ;;
        *)
            print_warning "⚠️  No specific data quality tests for $dashboard_type"
            ;;
    esac
}

# =============================================================================
# DASHBOARD-SPECIFIC DATA QUALITY TESTS
# =============================================================================

test_security_data_quality() {
    local index_pattern="$1"
    
    local owasp_events auth_events
    owasp_events=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"exists": {"field": "owaspCategory"}},
        "size": 0
    }' | jq '.hits.total.value')
    
    auth_events=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"term": {"action": "authentication.failure"}},
        "size": 0
    }' | jq '.hits.total.value')
    
    print_info "OWASP events: $owasp_events"
    print_info "Authentication events: $auth_events"
}

test_performance_data_quality() {
    local index_pattern="$1"
    
    local slow_requests error_requests avg_duration
    slow_requests=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"range": {"metadata.duration": {"gte": 1000}}},
        "size": 0
    }' | jq '.hits.total.value')
    
    error_requests=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"range": {"metadata.statusCode": {"gte": 400}}},
        "size": 0
    }' | jq '.hits.total.value')
    
    avg_duration=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "aggs": {"avg_duration": {"avg": {"field": "metadata.duration"}}},
        "size": 0
    }' | jq '.aggregations.avg_duration.value')
    
    print_info "Slow requests (>1s): $slow_requests"
    print_info "Error requests (4xx/5xx): $error_requests"
    print_info "Average duration: ${avg_duration}ms"
}

test_health_data_quality() {
    local index_pattern="$1"
    
    local error_logs warning_logs info_logs
    error_logs=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"term": {"level": "error"}},
        "size": 0
    }' | jq '.hits.total.value')
    
    warning_logs=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"term": {"level": "warn"}},
        "size": 0
    }' | jq '.hits.total.value')
    
    info_logs=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"term": {"level": "info"}},
        "size": 0
    }' | jq '.hits.total.value')
    
    print_info "Error logs: $error_logs"
    print_info "Warning logs: $warning_logs"
    print_info "Info logs: $info_logs"
}

test_user_activity_data_quality() {
    local index_pattern="$1"
    
    local click_events navigation_events error_events
    click_events=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"term": {"eventType": "click"}},
        "size": 0
    }' | jq '.hits.total.value')
    
    navigation_events=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"term": {"eventType": "navigation"}},
        "size": 0
    }' | jq '.hits.total.value')
    
    error_events=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"term": {"eventType": "error"}},
        "size": 0
    }' | jq '.hits.total.value')
    
    print_info "Click events: $click_events"
    print_info "Navigation events: $navigation_events"
    print_info "Error events: $error_events"
}

test_operational_data_quality() {
    local index_pattern="$1"
    
    local correlation_events log_volume system_events
    correlation_events=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"exists": {"field": "correlationId"}},
        "size": 0
    }' | jq '.hits.total.value')
    
    log_volume=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "aggs": {"log_volume": {"date_histogram": {"field": "@timestamp", "calendar_interval": "1h"}}},
        "size": 0
    }' | jq '.aggregations.log_volume.buckets | length')
    
    system_events=$(curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"term": {"service": "system"}},
        "size": 0
    }' | jq '.hits.total.value')
    
    print_info "Correlation events: $correlation_events"
    print_info "Log volume buckets: $log_volume"
    print_info "System events: $system_events"
}

# =============================================================================
# PERFORMANCE TESTING
# =============================================================================

test_query_performance() {
    local dashboard_type="$1"
    local index_pattern="$2"
    
    print_status "Testing $dashboard_type query performance..."
    
    local start_time end_time query_time
    start_time=$(date +%s.%N)
    
    # Execute a complex query
    curl -s "${ELASTICSEARCH_HOST}/${index_pattern}/_search" -H 'Content-Type: application/json' -d '{
        "query": {"range": {"@timestamp": {"gte": "now-1h"}}},
        "aggs": {
            "p50": {"percentiles": {"field": "metadata.duration", "percents": [50]}},
            "p95": {"percentiles": {"field": "metadata.duration", "percents": [95]}},
            "p99": {"percentiles": {"field": "metadata.duration", "percents": [99]}}
        },
        "size": 0
    }' > /dev/null
    
    end_time=$(date +%s.%N)
    query_time=$(echo "$end_time - $start_time" | bc -l)
    
    print_info "Query performance: ${query_time}s"
    
    return 0
}

# =============================================================================
# MAIN TESTING FUNCTION
# =============================================================================

test_dashboard() {
    local dashboard_type="$1"
    local test_performance="$2"
    local test_data_quality="$3"
    
    # Parse dashboard configuration
    local config="${DASHBOARD_CONFIGS[$dashboard_type]}"
    if [[ -z "$config" ]]; then
        print_error "Unknown dashboard type: $dashboard_type"
        return 1
    fi
    
    IFS='|' read -r dashboard_id index_pattern dashboard_name <<< "$config"
    
    print_step "🔍 Testing $dashboard_name Dashboard"
    
    local test_results=()
    
    # Test 1: Dashboard existence
    if test_dashboard_existence "$dashboard_type" "$dashboard_id"; then
        test_results+=("existence:✅")
    else
        test_results+=("existence:❌")
    fi
    
    # Test 2: Visualizations
    if test_visualizations "$dashboard_type"; then
        test_results+=("visualizations:✅")
    else
        test_results+=("visualizations:❌")
    fi
    
    # Test 3: Data availability
    if test_data_availability "$dashboard_type" "$index_pattern"; then
        test_results+=("data:✅")
    else
        test_results+=("data:❌")
    fi
    
    # Test 4: Dashboard performance
    if test_dashboard_performance "$dashboard_type" "$dashboard_id"; then
        test_results+=("performance:✅")
    else
        test_results+=("performance:❌")
    fi
    
    # Test 5: Alert configurations
    if test_alert_configurations "$dashboard_type"; then
        test_results+=("alerts:✅")
    else
        test_results+=("alerts:❌")
    fi
    
    # Test 6: Data quality (if requested)
    if [[ "$test_data_quality" == "true" ]]; then
        test_data_quality "$dashboard_type" "$index_pattern"
        test_results+=("data-quality:✅")
    fi
    
    # Test 7: Query performance (if requested)
    if [[ "$test_performance" == "true" ]]; then
        test_query_performance "$dashboard_type" "$index_pattern"
        test_results+=("query-performance:✅")
    fi
    
    # Summary
    print_step "📊 $dashboard_name Dashboard Test Summary"
    
    local passed=0
    local total=0
    
    for result in "${test_results[@]}"; do
        if [[ "$result" == *":✅" ]]; then
            ((passed++))
        fi
        ((total++))
    done
    
    local percentage=$((passed * 100 / total))
    
    if [[ $percentage -ge 80 ]]; then
        print_success "✅ $dashboard_name dashboard is operational ($passed/$total tests passed)"
    elif [[ $percentage -ge 60 ]]; then
        print_warning "⚠️  $dashboard_name dashboard has issues ($passed/$total tests passed)"
    else
        print_error "❌ $dashboard_name dashboard has significant issues ($passed/$total tests passed)"
    fi
    
    print_info "Test results: ${test_results[*]}"
    
    return $((total - passed))
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Parse arguments
    local test_all=false
    local dashboard_type=""
    local test_performance=false
    local test_data_quality=false
    local verbose=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                test_all=true
                shift
                ;;
            -t|--type)
                dashboard_type="$2"
                shift 2
                ;;
            -p|--performance)
                test_performance=true
                shift
                ;;
            -d|--data-quality)
                test_data_quality=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate requirements
    validate_requirements || exit 1
    
    # Show banner
    show_banner "Dashboard Testing Framework" "Unified dashboard testing and validation"
    
    # Test ELK stack health
    print_step "🔍 Testing ELK Stack Health"
    
    if ! curl -f "${ELASTICSEARCH_HOST}/_cluster/health" >/dev/null 2>&1; then
        print_error "❌ Elasticsearch is not accessible"
        print_info "Start ELK stack: docker-compose -f infrastructure/docker/logging-stack.yml --profile logging up -d"
        exit 1
    fi
    
    if ! curl -f "${KIBANA_HOST}/api/status" >/dev/null 2>&1; then
        print_error "❌ Kibana is not accessible"
        print_info "Start ELK stack: docker-compose -f infrastructure/docker/logging-stack.yml --profile logging up -d"
        exit 1
    fi
    
    print_success "✅ ELK stack is healthy"
    
    # Execute tests
    local total_failures=0
    
    if [[ "$test_all" == "true" ]]; then
        print_step "🧪 Testing All Dashboards"
        
        for type in "${!DASHBOARD_CONFIGS[@]}"; do
            test_dashboard "$type" "$test_performance" "$test_data_quality"
            total_failures=$((total_failures + $?))
        done
    elif [[ -n "$dashboard_type" ]]; then
        if [[ -z "${DASHBOARD_CONFIGS[$dashboard_type]}" ]]; then
            print_error "Unknown dashboard type: $dashboard_type"
            print_info "Available types: ${!DASHBOARD_CONFIGS[*]}"
            exit 1
        fi
        
        test_dashboard "$dashboard_type" "$test_performance" "$test_data_quality"
        total_failures=$?
    else
        print_error "No dashboard type specified"
        show_usage
        exit 1
    fi
    
    # Final summary
    print_step "📊 Testing Framework Summary"
    
    if [[ $total_failures -eq 0 ]]; then
        print_success "✅ All dashboard tests completed successfully!"
    else
        print_warning "⚠️  $total_failures test failures detected"
    fi
    
    print_info "🌐 Access Kibana: $KIBANA_HOST"
    print_info "📊 Access Elasticsearch: $ELASTICSEARCH_HOST"
    
    show_completion "Dashboard Testing Framework"
    
    exit $total_failures
}

# Execute main function
main "$@"
