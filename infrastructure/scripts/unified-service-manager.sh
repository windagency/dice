#!/bin/bash
# DICE Unified Service Manager
# Consolidates all service orchestration into a single, maintainable solution

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# =============================================================================
# CONFIGURATION
# =============================================================================

# Service configurations
declare -A SERVICE_CONFIGS=(
    ["backend"]="workspace/backend/docker-compose.yml|Backend API + Database + Temporal|3001,5432,6379,7233,8088"
    ["pwa"]="workspace/pwa/docker-compose.yml|PWA Frontend + Storybook|3000,6006"
    ["elk"]="infrastructure/docker/logging-stack.yml|ELK Stack (Elasticsearch + Kibana + Fluent Bit)|9200,5601,2020"
    ["orchestrator"]="infrastructure/docker/docker-compose.orchestrator.yml|Full Stack Orchestration|80,443,8080"
)

# Profile configurations
declare -A PROFILE_CONFIGS=(
    ["proxy"]="Traefik Reverse Proxy|80,443,8080"
    ["monitoring"]="Prometheus + Grafana|9090,3001"
    ["aws"]="LocalStack AWS Services|4566"
    ["logging"]="ELK Logging Stack|9200,5601,2020"
)

# Health check endpoints
declare -A HEALTH_ENDPOINTS=(
    ["backend"]="http://localhost:3001/health"
    ["pwa"]="http://localhost:3000"
    ["storybook"]="http://localhost:6006"
    ["temporal"]="http://localhost:8088"
    ["elasticsearch"]="http://localhost:9200/_cluster/health"
    ["kibana"]="http://localhost:5601/api/status"
    ["traefik"]="http://localhost:8080/api/rawdata"
)

# =============================================================================
# USAGE FUNCTIONS
# =============================================================================

show_usage() {
    cat << EOF
DICE Unified Service Manager

Usage: $0 [COMMAND] [OPTIONS]

Commands:
  start [SERVICE]         Start specific service or all services
  stop [SERVICE]          Stop specific service or all services
  restart [SERVICE]       Restart specific service or all services
  status [SERVICE]        Show status of specific service or all services
  logs [SERVICE]          Show logs for specific service
  health [SERVICE]        Health check for specific service or all services
  clean                   Clean all containers and volumes
  backup                  Create backup of all data
  restore [BACKUP]        Restore from backup

Services:
  backend                 Backend API + Database + Temporal
  pwa                     PWA Frontend + Storybook
  elk                     ELK Stack (Elasticsearch + Kibana + Fluent Bit)
  orchestrator            Full Stack Orchestration
  all                     All services

Profiles (use with orchestrator):
  --proxy                 Enable Traefik reverse proxy
  --monitoring            Enable Prometheus + Grafana
  --aws                   Enable LocalStack AWS services
  --logging               Enable ELK logging stack

Examples:
  $0 start backend                    # Start backend only
  $0 start pwa                       # Start PWA only
  $0 start orchestrator --proxy      # Start full stack with proxy
  $0 status all                      # Check all services
  $0 health backend                  # Health check backend
  $0 logs pwa                        # Show PWA logs
  $0 clean                           # Clean everything

EOF
}

# =============================================================================
# SERVICE MANAGEMENT FUNCTIONS
# =============================================================================

# Start a specific service
start_service() {
    local service="$1"
    local profiles="$2"
    
    local config="${SERVICE_CONFIGS[$service]}"
    if [[ -z "$config" ]]; then
        print_error "Unknown service: $service"
        return 1
    fi
    
    IFS='|' read -r compose_file description ports <<< "$config"
    
    print_step "🚀 Starting $service service: $description"
    
    # Check if compose file exists
    if [[ ! -f "$compose_file" ]]; then
        print_error "Compose file not found: $compose_file"
        return 1
    fi
    
    # Start service
    if [[ -n "$profiles" ]]; then
        print_info "Starting with profiles: $profiles"
        docker compose -f "$compose_file" --profile "$profiles" --env-file .env up -d
    else
        docker compose -f "$compose_file" --env-file .env up -d
    fi
    
    if [[ $? -eq 0 ]]; then
        print_success "✅ $service service started"
        print_info "🌐 Ports: $ports"
        return 0
    else
        print_error "❌ Failed to start $service service"
        return 1
    fi
}

# Stop a specific service
stop_service() {
    local service="$1"
    
    local config="${SERVICE_CONFIGS[$service]}"
    if [[ -z "$config" ]]; then
        print_error "Unknown service: $service"
        return 1
    fi
    
    IFS='|' read -r compose_file description ports <<< "$config"
    
    print_step "🛑 Stopping $service service: $description"
    
    docker compose -f "$compose_file" down
    
    if [[ $? -eq 0 ]]; then
        print_success "✅ $service service stopped"
        return 0
    else
        print_error "❌ Failed to stop $service service"
        return 1
    fi
}

# Restart a specific service
restart_service() {
    local service="$1"
    local profiles="$2"
    
    print_step "🔄 Restarting $service service"
    
    stop_service "$service" && start_service "$service" "$profiles"
}

# Get status of a specific service
get_service_status() {
    local service="$1"
    
    local config="${SERVICE_CONFIGS[$service]}"
    if [[ -z "$config" ]]; then
        print_error "Unknown service: $service"
        return 1
    fi
    
    IFS='|' read -r compose_file description ports <<< "$config"
    
    print_status "📊 $service service status: $description"
    
    # Check if containers are running
    local running_containers
    running_containers=$(docker compose -f "$compose_file" ps -q 2>/dev/null | wc -l)
    
    if [[ $running_containers -gt 0 ]]; then
        print_success "✅ $service service is running ($running_containers containers)"
        
        # Show container details
        docker compose -f "$compose_file" ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    else
        print_warning "⚠️  $service service is not running"
    fi
    
    return 0
}

# Show logs for a specific service
show_service_logs() {
    local service="$1"
    local follow="${2:-false}"
    
    local config="${SERVICE_CONFIGS[$service]}"
    if [[ -z "$config" ]]; then
        print_error "Unknown service: $service"
        return 1
    fi
    
    IFS='|' read -r compose_file description ports <<< "$config"
    
    print_step "📋 Showing logs for $service service: $description"
    
    if [[ "$follow" == "true" ]]; then
        docker compose -f "$compose_file" logs -f
    else
        docker compose -f "$compose_file" logs --tail=50
    fi
}

# Health check for a specific service
health_check_service() {
    local service="$1"
    
    local endpoint="${HEALTH_ENDPOINTS[$service]}"
    if [[ -z "$endpoint" ]]; then
        print_warning "⚠️  No health endpoint configured for $service"
        return 0
    fi
    
    print_status "🏥 Health checking $service service..."
    
    local response
    response=$(curl -s -w "%{http_code}" "$endpoint" -o /dev/null)
    
    if [[ "$response" == "200" ]]; then
        print_success "✅ $service service is healthy"
        return 0
    else
        print_error "❌ $service service health check failed (HTTP $response)"
        return 1
    fi
}

# =============================================================================
# BULK OPERATIONS
# =============================================================================

# Start all services
start_all_services() {
    local profiles="$1"
    
    print_step "🚀 Starting all DICE services"
    
    local failures=0
    
    # Start services in dependency order
    for service in "backend" "pwa" "elk" "orchestrator"; do
        if ! start_service "$service" "$profiles"; then
            ((failures++))
        fi
    done
    
    if [[ $failures -eq 0 ]]; then
        print_success "✅ All services started successfully"
    else
        print_warning "⚠️  $failures service(s) failed to start"
    fi
    
    return $failures
}

# Stop all services
stop_all_services() {
    print_step "🛑 Stopping all DICE services"
    
    local failures=0
    
    # Stop services in reverse dependency order
    for service in "orchestrator" "elk" "pwa" "backend"; do
        if ! stop_service "$service"; then
            ((failures++))
        fi
    done
    
    if [[ $failures -eq 0 ]]; then
        print_success "✅ All services stopped successfully"
    else
        print_warning "⚠️  $failures service(s) failed to stop"
    fi
    
    return $failures
}

# Get status of all services
get_all_service_status() {
    print_step "📊 DICE Services Status Overview"
    
    local total_services=0
    local running_services=0
    
    for service in "${!SERVICE_CONFIGS[@]}"; do
        ((total_services++))
        
        local config="${SERVICE_CONFIGS[$service]}"
        IFS='|' read -r compose_file description ports <<< "$config"
        
        local running_containers
        running_containers=$(docker compose -f "$compose_file" ps -q 2>/dev/null | wc -l)
        
        if [[ $running_containers -gt 0 ]]; then
            print_success "✅ $service: $description ($running_containers containers)"
            ((running_services++))
        else
            print_warning "⚠️  $service: $description (not running)"
        fi
    done
    
    print_info "📈 Overall status: $running_services/$total_services services running"
    
    return $((total_services - running_services))
}

# Health check all services
health_check_all_services() {
    print_step "🏥 Comprehensive Health Check"
    
    local failures=0
    
    for service in "${!HEALTH_ENDPOINTS[@]}"; do
        if ! health_check_service "$service"; then
            ((failures++))
        fi
    done
    
    if [[ $failures -eq 0 ]]; then
        print_success "✅ All services are healthy"
    else
        print_warning "⚠️  $failures service(s) have health issues"
    fi
    
    return $failures
}

# =============================================================================
# UTILITY OPERATIONS
# =============================================================================

# Clean all containers and volumes
clean_all() {
    print_step "🧹 Cleaning all DICE containers and volumes"
    
    print_warning "This will remove ALL containers and volumes. Are you sure? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_status "Stopping all services..."
        stop_all_services
        
        print_status "Removing containers..."
        docker compose -f workspace/backend/docker-compose.yml down -v
        docker compose -f workspace/pwa/docker-compose.yml down -v
        docker compose -f infrastructure/docker/logging-stack.yml down -v
        docker compose -f infrastructure/docker/docker-compose.orchestrator.yml down -v
        
        print_status "Removing orphaned containers..."
        docker container prune -f
        
        print_status "Removing orphaned volumes..."
        docker volume prune -f
        
        print_success "✅ Cleanup completed"
    else
        print_info "Cleanup cancelled"
    fi
}

# Create backup
create_backup() {
    local backup_dir="./infrastructure/data/backups"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/dice_backup_$timestamp.tar.gz"
    
    print_step "💾 Creating DICE backup"
    
    mkdir -p "$backup_dir"
    
    # Create backup of data directories
    tar -czf "$backup_file" \
        infrastructure/data/postgres \
        infrastructure/data/redis \
        infrastructure/data/localstack \
        infrastructure/data/uploads \
        .env 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        print_success "✅ Backup created: $backup_file"
        print_info "📁 Backup size: $(du -h "$backup_file" | cut -f1)"
    else
        print_error "❌ Backup failed"
        return 1
    fi
}

# Restore from backup
restore_backup() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        print_error "Backup file not found: $backup_file"
        return 1
    fi
    
    print_step "📥 Restoring from backup: $backup_file"
    
    print_warning "This will overwrite current data. Are you sure? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        # Stop all services first
        stop_all_services
        
        # Extract backup
        tar -xzf "$backup_file" -C ./
        
        if [[ $? -eq 0 ]]; then
            print_success "✅ Backup restored successfully"
            print_info "🔄 Restart services to apply restored data"
        else
            print_error "❌ Backup restoration failed"
            return 1
        fi
    else
        print_info "Restore cancelled"
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Parse command
    local command="$1"
    shift
    
    # Parse options
    local service=""
    local profiles=""
    local follow_logs=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --proxy|--monitoring|--aws|--logging)
                profiles="$profiles,${1#--}"
                shift
                ;;
            -f|--follow)
                follow_logs=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                if [[ -z "$service" ]]; then
                    service="$1"
                else
                    print_error "Unknown option: $1"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Remove leading comma from profiles
    profiles="${profiles#,}"
    
    # Validate requirements
    validate_requirements || exit 1
    
    # Show banner
    show_banner "Unified Service Manager" "DICE service orchestration and management"
    
    # Execute command
    case "$command" in
        start)
            if [[ "$service" == "all" || -z "$service" ]]; then
                start_all_services "$profiles"
            else
                start_service "$service" "$profiles"
            fi
            ;;
        stop)
            if [[ "$service" == "all" || -z "$service" ]]; then
                stop_all_services
            else
                stop_service "$service"
            fi
            ;;
        restart)
            if [[ "$service" == "all" || -z "$service" ]]; then
                stop_all_services && start_all_services "$profiles"
            else
                restart_service "$service" "$profiles"
            fi
            ;;
        status)
            if [[ "$service" == "all" || -z "$service" ]]; then
                get_all_service_status
            else
                get_service_status "$service"
            fi
            ;;
        logs)
            if [[ -z "$service" ]]; then
                print_error "Service name required for logs command"
                show_usage
                exit 1
            fi
            show_service_logs "$service" "$follow_logs"
            ;;
        health)
            if [[ "$service" == "all" || -z "$service" ]]; then
                health_check_all_services
            else
                health_check_service "$service"
            fi
            ;;
        clean)
            clean_all
            ;;
        backup)
            create_backup
            ;;
        restore)
            if [[ -z "$service" ]]; then
                print_error "Backup file required for restore command"
                show_usage
                exit 1
            fi
            restore_backup "$service"
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
    
    show_completion "Unified Service Manager"
}

# Execute main function
main "$@"
