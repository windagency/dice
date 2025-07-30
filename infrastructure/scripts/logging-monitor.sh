#!/bin/bash

# DICE Unified Logging Monitor Script
# Real-time log monitoring and analysis for the ELK stack
# Usage: ./logging-monitor.sh [options]

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
ELASTICSEARCH_HOST="localhost:9200"
KIBANA_HOST="localhost:5601"
FLUENT_BIT_HOST="localhost:2020"

# Function to show usage
show_usage() {
    echo "DICE Unified Logging Monitor"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -s, --service SERVICE     Monitor specific service container logs"
    echo "  -f, --follow             Follow logs in real-time"
    echo "  -t, --tail LINES         Number of recent log lines (default: 50)"
    echo "  --dashboard              Open Kibana dashboard (delegates to logging-setup.sh)"
    echo "  --health                 Check ELK stack health (delegates to logging-setup.sh)"
    echo "  -h, --help               Show help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Show available services"
    echo "  $0 --service backend-api             # Show recent backend container logs"
    echo "  $0 --service backend-api --follow    # Follow backend logs in real-time"
    echo "  $0 --service postgres --tail 100    # Last 100 postgres log lines"
    echo "  $0 --dashboard                       # Open Kibana dashboard"
    echo "  $0 --health                          # Check ELK stack health"
    echo ""
    echo "For advanced log analysis:"
    echo "  ./logging-setup.sh dashboard         # Kibana with configured patterns"
    echo "  ./logging-setup.sh export 24h        # Export logs"
    echo "  ./logging-test.sh                    # Test logging pipeline"
}

# Function to check if ELK stack is running
check_elk_health() {
    local elasticsearch_ok=false
    local kibana_ok=false
    local fluent_bit_ok=false
    
    # Check Elasticsearch
    if curl -s http://$ELASTICSEARCH_HOST/_cluster/health >/dev/null 2>&1; then
        elasticsearch_ok=true
        print_success "✓ Elasticsearch is running"
    else
        print_error "✗ Elasticsearch is not accessible at http://$ELASTICSEARCH_HOST"
    fi
    
    # Check Kibana
    if curl -s http://$KIBANA_HOST/api/status >/dev/null 2>&1; then
        kibana_ok=true
        print_success "✓ Kibana is running"
    else
        print_error "✗ Kibana is not accessible at http://$KIBANA_HOST"
    fi
    
    # Check Fluent Bit
    if curl -s http://$FLUENT_BIT_HOST/api/v1/health >/dev/null 2>&1; then
        fluent_bit_ok=true
        print_success "✓ Fluent Bit is running"
    else
        print_error "✗ Fluent Bit is not accessible at http://$FLUENT_BIT_HOST"
    fi
    
    if [[ "$elasticsearch_ok" == true && "$kibana_ok" == true && "$fluent_bit_ok" == true ]]; then
        return 0
    else
        print_error "ELK stack is not fully operational"
        print_status "Start the logging stack with: ./infrastructure/scripts/logging-setup.sh start"
        return 1
    fi
}

# Function to open monitoring dashboards
open_dashboards() {
    print_status "Opening monitoring dashboards..."
    
    local kibana_url="http://$KIBANA_HOST"
    local elasticsearch_url="http://$ELASTICSEARCH_HOST"
    local fluent_bit_url="http://$FLUENT_BIT_HOST"
    
    print_success "Dashboard URLs:"
    echo "  • Kibana Dashboard: $kibana_url"
    echo "  • Elasticsearch API: $elasticsearch_url"
    echo "  • Fluent Bit Metrics: $fluent_bit_url"
    echo ""
    
    # Try to open Kibana in browser
    if command -v open >/dev/null 2>&1; then
        open "$kibana_url"
        print_success "Opened Kibana dashboard in browser"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$kibana_url"
        print_success "Opened Kibana dashboard in browser"
    else
        print_status "Please open $kibana_url in your browser"
    fi
}

# Function to show recent logs from containers
show_container_logs() {
    local service="$1"
    local tail_lines="$2"
    local follow="$3"
    
    print_status "Showing container logs for service: $service"
    
    local container_name=""
    case "$service" in
        "backend-api"|"backend")
            container_name="backend_dev"
            ;;
        "postgres"|"postgresql")
            container_name="backend_postgres"
            ;;
        "redis")
            container_name="backend_redis"
            ;;
        "temporal")
            container_name="backend_temporal"
            ;;
        "pwa"|"frontend")
            container_name="pwa_dev"
            ;;
        *)
            print_error "Unknown service: $service"
            return 1
            ;;
    esac
    
    # Check if container exists
    if ! docker ps -q -f name="$container_name" | grep -q .; then
        print_error "Container $container_name is not running"
        return 1
    fi
    
    local docker_cmd="docker logs"
    if [[ "$follow" == true ]]; then
        docker_cmd="$docker_cmd -f"
    fi
    docker_cmd="$docker_cmd --tail $tail_lines $container_name"
    
    print_status "Executing: $docker_cmd"
    eval "$docker_cmd"
}

# Simplified main function for basic functionality
main() {
    local service=""
    local follow=false
    local tail_lines="50"
    local show_dashboard=false
    local check_health=false
    
    # Parse basic arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--service)
                service="$2"
                shift 2
                ;;
            -f|--follow)
                follow=true
                shift
                ;;
            -t|--tail)
                tail_lines="$2"
                shift 2
                ;;
            --dashboard)
                show_dashboard=true
                shift
                ;;
            --health)
                check_health=true
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
    
    # Check if we should just show health (delegate to logging-setup.sh)
    if [[ "$check_health" == true ]]; then
        print_status "Delegating to logging-setup.sh for ELK health check..."
        ./infrastructure/scripts/logging-setup.sh health
        exit $?
    fi
    
    # Check if we should open dashboards (delegate to logging-setup.sh)
    if [[ "$show_dashboard" == true ]]; then
        print_status "Delegating to logging-setup.sh for dashboard opening..."
        ./infrastructure/scripts/logging-setup.sh dashboard
        exit $?
    fi
    
    # If no service specified, show available options
    if [[ -z "$service" ]]; then
        print_status "Available services for monitoring:"
        echo "  • backend-api    - Backend API logs"
        echo "  • postgres       - PostgreSQL database logs"
        echo "  • redis          - Redis cache logs"
        echo "  • temporal       - Temporal workflow logs"
        echo "  • pwa            - PWA frontend logs"
        echo ""
        print_status "Use: $0 --service <service_name> to monitor specific service"
        print_status "Use: $0 --dashboard to open Kibana dashboard"
        print_status "Use: $0 --health to check ELK stack health"
        echo ""
        print_status "For advanced log analysis:"
        echo "  • Kibana Dashboard: ./infrastructure/scripts/logging-setup.sh dashboard"
        echo "  • Export Logs: ./infrastructure/scripts/logging-setup.sh export 24h"
        echo "  • Pipeline Test: ./infrastructure/scripts/logging-test.sh"
        exit 0
    fi
    
    # Show container logs for the specified service
    show_container_logs "$service" "$tail_lines" "$follow"
}

# Trap Ctrl+C for graceful shutdown
trap 'echo -e "\n${YELLOW}Monitoring stopped${NC}"; exit 0' INT

# Run main function with all arguments
main "$@"
