#!/bin/bash

# DICE Unified Logging Setup Script
# Deploys and manages the ELK stack for centralized logging
# Usage: ./logging-setup.sh [command] [options]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
LOGGING_COMPOSE_FILE="${PROJECT_ROOT}/infrastructure/docker/logging-stack.yml"
LOG_DIR="${PROJECT_ROOT}/infrastructure/data/elk/logs"

# Source common functions
if [[ -f "${SCRIPT_DIR}/common.sh" ]]; then
    source "${SCRIPT_DIR}/common.sh"
else
    echo -e "${RED}Error: common.sh not found${NC}"
    exit 1
fi

# Function to show usage
show_usage() {
    echo "DICE Unified Logging Setup"
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  setup               Setup ELK stack infrastructure"
    echo "  start               Start ELK stack services"
    echo "  stop                Stop ELK stack services"
    echo "  restart             Restart ELK stack services"
    echo "  status              Show ELK stack service status"
    echo "  logs [service]      Show logs for specific service"
    echo "  dashboard           Open Kibana dashboard with index pattern setup"
    echo "  health              Check ELK stack health"
    echo "  cleanup             Clean up old logs and data"
    echo "  validate            Validate logging configuration"
    echo "  test                Send test logs to verify pipeline"
    echo "  configure           Configure Kibana index patterns and settings"
    echo "  export [duration]   Export recent logs (default: 1h)"
    echo ""
    echo "Options:"
    echo "  --profile PROFILE   Use specific profile (logging, monitoring)"
    echo "  --force             Force operation without confirmation"
    echo "  --verbose           Enable verbose output"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup                    # Setup ELK infrastructure"
    echo "  $0 start --profile logging  # Start logging services only"
    echo "  $0 logs elasticsearch       # Show Elasticsearch logs"
    echo "  $0 dashboard                # Open Kibana dashboard"
    echo "  $0 configure                # Setup Kibana index patterns"
    echo "  $0 export 24h               # Export last 24 hours logs"
}

# Function to setup ELK infrastructure
setup_elk_infrastructure() {
    print_status "Setting up DICE ELK logging infrastructure"
    
    # Create required directories
    print_status "Creating logging directories"
    mkdir -p "${LOG_DIR}"
    mkdir -p "${PROJECT_ROOT}/infrastructure/data/elk"
    mkdir -p "${PROJECT_ROOT}/infrastructure/logging"
    
    # Set proper permissions
    print_status "Setting directory permissions"
    chmod 755 "${LOG_DIR}"
    chmod 755 "${PROJECT_ROOT}/infrastructure/data/elk"
    
    # Validate configuration files
    print_status "Validating configuration files"
    local config_files=(
        "${PROJECT_ROOT}/infrastructure/data/elk/elasticsearch.yml"
        "${PROJECT_ROOT}/infrastructure/data/elk/kibana.yml"
        "${PROJECT_ROOT}/infrastructure/logging/fluent-bit.conf"
        "${PROJECT_ROOT}/infrastructure/logging/parsers.conf"
    )
    
    for file in "${config_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Missing configuration file: $file"
            exit 1
        fi
        print_success "✓ Found $file"
    done
    
    # Check Docker Compose file
    if [[ ! -f "$LOGGING_COMPOSE_FILE" ]]; then
        print_error "Missing Docker Compose file: $LOGGING_COMPOSE_FILE"
        exit 1
    fi
    
    # Validate Docker Compose configuration
    print_status "Validating Docker Compose configuration"
    if ! docker compose -f "$LOGGING_COMPOSE_FILE" config >/dev/null 2>&1; then
        print_error "Invalid Docker Compose configuration"
        docker compose -f "$LOGGING_COMPOSE_FILE" config
        exit 1
    fi
    
    # Pull required images
    print_status "Pulling Docker images"
    docker compose -f "$LOGGING_COMPOSE_FILE" --profile logging pull
    
    print_success "ELK infrastructure setup completed"
}

# Function to start ELK services
start_elk_services() {
    local profile="${1:-logging}"
    
    print_status "Starting ELK stack services with profile: $profile"
    
    # Check if services are already running
    if docker compose -f "$LOGGING_COMPOSE_FILE" ps --services | grep -q .; then
        print_status "Some services are already running. Checking status..."
    fi
    
    # Start services
    docker compose -f "$LOGGING_COMPOSE_FILE" --profile "$profile" up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    
    # Wait for Elasticsearch
    print_status "Waiting for Elasticsearch..."
    if ! wait_for_service "http://localhost:9200/_cluster/health" 120; then
        print_error "Elasticsearch failed to start properly"
        docker compose -f "$LOGGING_COMPOSE_FILE" logs elasticsearch
        exit 1
    fi
    print_success "✓ Elasticsearch is ready"
    
    # Wait for Kibana
    print_status "Waiting for Kibana..."
    if ! wait_for_service "http://localhost:5601/api/status" 120; then
        print_error "Kibana failed to start properly"
        docker compose -f "$LOGGING_COMPOSE_FILE" logs kibana
        exit 1
    fi
    print_success "✓ Kibana is ready"
    
    # Wait for Fluent Bit
    print_status "Waiting for Fluent Bit..."
    if ! wait_for_service "http://localhost:2020/api/v1/health" 60; then
        print_error "Fluent Bit failed to start properly"
        docker compose -f "$LOGGING_COMPOSE_FILE" logs fluent-bit
        exit 1
    fi
    print_success "✓ Fluent Bit is ready"
    
    print_success "All ELK services are running and healthy"
    print_status "Kibana dashboard: http://localhost:5601"
    print_status "Elasticsearch API: http://localhost:9200"
    print_status "Fluent Bit metrics: http://localhost:2020"
}

# Function to stop ELK services
stop_elk_services() {
    print_status "Stopping ELK stack services"
    docker compose -f "$LOGGING_COMPOSE_FILE" down
    print_success "ELK services stopped"
}

# Function to restart ELK services
restart_elk_services() {
    local profile="${1:-logging}"
    print_status "Restarting ELK stack services"
    stop_elk_services
    sleep 5
    start_elk_services "$profile"
}

# Function to show service status
show_elk_status() {
    print_status "ELK Stack Service Status"
    echo ""
    
    # Check if compose file exists
    if [[ ! -f "$LOGGING_COMPOSE_FILE" ]]; then
        print_error "Docker Compose file not found: $LOGGING_COMPOSE_FILE"
        return 1
    fi
    
    # Show running services
    echo -e "${BLUE}Running Services:${NC}"
    docker compose -f "$LOGGING_COMPOSE_FILE" ps
    echo ""
    
    # Check individual service health
    echo -e "${BLUE}Service Health Checks:${NC}"
    
    # Elasticsearch
    if curl -s http://localhost:9200/_cluster/health >/dev/null 2>&1; then
        echo -e "  Elasticsearch: ${GREEN}✓ Healthy${NC}"
        echo "    - $(curl -s http://localhost:9200/_cluster/health | jq -r '.status') cluster status"
    else
        echo -e "  Elasticsearch: ${RED}✗ Unhealthy${NC}"
    fi
    
    # Kibana
    if curl -s http://localhost:5601/api/status >/dev/null 2>&1; then
        echo -e "  Kibana: ${GREEN}✓ Healthy${NC}"
    else
        echo -e "  Kibana: ${RED}✗ Unhealthy${NC}"
    fi
    
    # Fluent Bit
    if curl -s http://localhost:2020/api/v1/health >/dev/null 2>&1; then
        echo -e "  Fluent Bit: ${GREEN}✓ Healthy${NC}"
    else
        echo -e "  Fluent Bit: ${RED}✗ Unhealthy${NC}"
    fi
    
    echo ""
}

# Function to show service logs
show_elk_logs() {
    local service="${1:-}"
    
    if [[ -z "$service" ]]; then
        print_status "Available services for logs:"
        docker compose -f "$LOGGING_COMPOSE_FILE" ps --services
        return 0
    fi
    
    print_status "Showing logs for service: $service"
    docker compose -f "$LOGGING_COMPOSE_FILE" logs -f "$service"
}

# Function to configure Kibana index patterns
configure_kibana() {
    local kibana_url="http://localhost:5601"
    
    print_status "Configuring Kibana index patterns..."
    
    # Wait for Kibana to be fully ready
    print_status "Waiting for Kibana to be ready..."
    if ! wait_for_service "$kibana_url/api/status" 60; then
        print_error "Kibana is not ready"
        return 1
    fi
    
    sleep 5  # Additional wait for full readiness
    
    # Function to create index pattern
    create_index_pattern() {
        local pattern_name="$1"
        local index_pattern="$2"
        local time_field="$3"
        
        print_status "Creating index pattern: $pattern_name"
        
        # Check if index pattern already exists
        if curl -s "$kibana_url/api/saved_objects/index-pattern/$pattern_name" | grep -q "\"id\":\"$pattern_name\"" 2>/dev/null; then
            print_success "✓ Index pattern '$pattern_name' already exists"
            return 0
        fi
        
        # Create the index pattern
        local payload="{\"attributes\":{\"title\":\"$index_pattern\",\"timeFieldName\":\"$time_field\"}}"
        
        if curl -X POST "$kibana_url/api/saved_objects/index-pattern/$pattern_name" \
           -H "Content-Type: application/json" \
           -H "kbn-xsrf: true" \
           -d "$payload" -s >/dev/null 2>&1; then
            print_success "✓ Created index pattern '$pattern_name'"
        else
            print_warn "⚠ Failed to create index pattern '$pattern_name'"
        fi
    }
    
    # Create index patterns for DICE logs
    create_index_pattern "dice-logs" "dice-logs-*" "@timestamp"
    create_index_pattern "dice-security" "dice-security-*" "@timestamp"
    
    # Set default index pattern
    print_status "Setting default index pattern..."
    curl -X POST "$kibana_url/api/kibana/settings/defaultIndex" \
         -H "Content-Type: application/json" \
         -H "kbn-xsrf: true" \
         -d '{"value": "dice-logs"}' -s >/dev/null 2>&1 || print_warn "⚠ Failed to set default index pattern"
    
    print_success "Kibana configuration completed"
}

# Function to export recent logs
export_recent_logs() {
    local duration="${1:-1h}"
    local export_file="/tmp/dice-logs-export-$(date +%Y%m%d-%H%M%S).json"
    
    print_status "Exporting logs from the last $duration..."
    
    local export_query="{
        \"query\": {
            \"range\": {
                \"@timestamp\": {
                    \"gte\": \"now-$duration\"
                }
            }
        },
        \"sort\": [{\"@timestamp\": {\"order\": \"desc\"}}],
        \"size\": 1000
    }"
    
    if curl -s -X POST "http://localhost:9200/dice-logs-*/_search" \
       -H "Content-Type: application/json" \
       -d "$export_query" > "$export_file"; then
        print_success "Logs exported to: $export_file"
        local log_count=$(jq '.hits.hits | length' "$export_file" 2>/dev/null || echo "0")
        echo "   📋 Exported $log_count log entries from the last $duration"
    else
        print_error "Failed to export logs"
        return 1
    fi
}

# Function to open Kibana dashboard
open_kibana_dashboard() {
    local kibana_url="http://localhost:5601"
    
    # Check if Kibana is running
    if ! curl -s "$kibana_url/api/status" >/dev/null 2>&1; then
        print_error "Kibana is not accessible at $kibana_url"
        print_status "Please start the ELK stack first: $0 start"
        return 1
    fi
    
    # Configure Kibana if needed
    configure_kibana
    
    print_success "Opening Kibana dashboard: $kibana_url"
    print_status "📋 Quick Start Guide:"
    echo "   1. Go to 'Discover' to explore logs"
    echo "   2. Use 'dice-logs-*' for application logs"
    echo "   3. Use 'dice-security-*' for security events"
    echo "   4. Create visualizations in 'Visualize'"
    echo "   5. Build dashboards in 'Dashboard'"
    
    # Try to open in default browser
    if command -v open >/dev/null 2>&1; then
        open "$kibana_url"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$kibana_url"
    else
        print_status "Please open the following URL in your browser:"
        echo "$kibana_url"
    fi
}

# Function to check ELK health
check_elk_health() {
    print_status "Performing comprehensive ELK health check"
    local all_healthy=true
    
    # Check Elasticsearch cluster health
    print_status "Checking Elasticsearch cluster health..."
    if curl -s http://localhost:9200/_cluster/health >/dev/null 2>&1; then
        local es_health=$(curl -s http://localhost:9200/_cluster/health | jq -r '.status')
        if [[ "$es_health" == "green" || "$es_health" == "yellow" ]]; then
            print_success "✓ Elasticsearch cluster status: $es_health"
        else
            print_error "✗ Elasticsearch cluster status: $es_health"
            all_healthy=false
        fi
    else
        print_error "✗ Elasticsearch is not responding"
        all_healthy=false
    fi
    
    # Check Kibana health
    print_status "Checking Kibana health..."
    if curl -s http://localhost:5601/api/status >/dev/null 2>&1; then
        print_success "✓ Kibana is responding"
    else
        print_error "✗ Kibana is not responding"
        all_healthy=false
    fi
    
    # Check Fluent Bit health
    print_status "Checking Fluent Bit health..."
    if curl -s http://localhost:2020/api/v1/health >/dev/null 2>&1; then
        print_success "✓ Fluent Bit is healthy"
    else
        print_error "✗ Fluent Bit is not responding"
        all_healthy=false
    fi
    
    # Check log directory permissions
    print_status "Checking log directory permissions..."
    if [[ -w "$LOG_DIR" ]]; then
        print_success "✓ Log directory is writable"
    else
        print_error "✗ Log directory is not writable: $LOG_DIR"
        all_healthy=false
    fi
    
    if [[ "$all_healthy" == true ]]; then
        print_success "All ELK services are healthy"
        return 0
    else
        print_error "Some ELK services have issues"
        return 1
    fi
}

# Function to cleanup old logs
cleanup_old_logs() {
    print_status "Cleaning up old logs and data"
    
    # Clean up log files older than 30 days
    print_status "Removing log files older than 30 days..."
    find "$LOG_DIR" -name "*.log" -type f -mtime +30 -delete 2>/dev/null || true
    find "$LOG_DIR" -name "*.log.*" -type f -mtime +30 -delete 2>/dev/null || true
    
    # Clean up Elasticsearch indices older than 30 days
    print_status "Cleaning up old Elasticsearch indices..."
    if curl -s http://localhost:9200/_cat/indices >/dev/null 2>&1; then
        # This is a placeholder - in production, you'd use curator or ILM
        print_status "Manual index cleanup required - check Elasticsearch indices"
    fi
    
    print_success "Cleanup completed"
}

# Function to validate logging configuration
validate_logging_config() {
    print_status "Validating logging configuration"
    
    # Check all required files exist
    local required_files=(
        "$LOGGING_COMPOSE_FILE"
        "${PROJECT_ROOT}/infrastructure/data/elk/elasticsearch.yml"
        "${PROJECT_ROOT}/infrastructure/data/elk/kibana.yml"
        "${PROJECT_ROOT}/infrastructure/logging/fluent-bit.conf"
        "${PROJECT_ROOT}/infrastructure/logging/parsers.conf"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            print_success "✓ Found $file"
        else
            print_error "✗ Missing $file"
            return 1
        fi
    done
    
    # Validate Docker Compose syntax
    print_status "Validating Docker Compose syntax..."
    if docker compose -f "$LOGGING_COMPOSE_FILE" config >/dev/null 2>&1; then
        print_success "✓ Docker Compose configuration is valid"
    else
        print_error "✗ Docker Compose configuration is invalid"
        return 1
    fi
    
    print_success "All configurations are valid"
}

# Function to send test logs
send_test_logs() {
    print_status "Sending test logs to verify pipeline"
    
    # Check if Fluent Bit is available
    if ! curl -s http://localhost:24225 >/dev/null 2>&1; then
        print_error "Fluent Bit HTTP input is not available"
        print_status "Please start the ELK stack first: $0 start"
        return 1
    fi
    
    # Send test log entries
    local test_logs=(
        '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'","level":"info","service":"test","message":"Test log entry 1","correlationId":"test-001"}'
        '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'","level":"warn","service":"test","message":"Test warning entry","correlationId":"test-002"}'
        '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'","level":"error","service":"test","message":"Test error entry","correlationId":"test-003"}'
    )
    
    for log_entry in "${test_logs[@]}"; do
        echo "$log_entry" | curl -X POST http://localhost:24225/dice.test -H "Content-Type: application/json" -d @-
        print_success "✓ Sent test log"
    done
    
    print_success "Test logs sent successfully"
    print_status "Check Kibana dashboard to verify logs are appearing: http://localhost:5601"
}

# Main function
main() {
    local command="${1:-help}"
    local profile="logging"
    local force=false
    local verbose=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile)
                profile="$2"
                shift 2
                ;;
            --force)
                force=true
                shift
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                if [[ "$1" != "$command" ]]; then
                    # Additional arguments for commands
                    break
                fi
                shift
                ;;
        esac
    done
    
    # Execute command
    case $command in
        setup)
            setup_elk_infrastructure
            ;;
        start)
            start_elk_services "$profile"
            ;;
        stop)
            stop_elk_services
            ;;
        restart)
            restart_elk_services "$profile"
            ;;
        status)
            show_elk_status
            ;;
        logs)
            show_elk_logs "$2"
            ;;
        dashboard)
            open_kibana_dashboard
            ;;
        configure)
            configure_kibana
            ;;
        export)
            export_recent_logs "$2"
            ;;
        health)
            check_elk_health
            ;;
        cleanup)
            cleanup_old_logs
            ;;
        validate)
            validate_logging_config
            ;;
        test)
            send_test_logs
            ;;
        help|--help)
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