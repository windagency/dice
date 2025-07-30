#!/bin/bash
# DICE Docker Orchestrator Script (Simplified)
# Manages the distributed Docker Compose architecture

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Show usage
show_usage() {
    echo "DICE Docker Orchestrator"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  backend-only          Start backend workspace only"
    echo "  pwa-only             Start PWA workspace only"
    echo "  full-stack           Start full integrated stack"
    echo "  stop                 Stop all DICE services"
    echo "  clean                Clean all DICE containers and volumes"
    echo "  status               Show status of all services"
    echo "  logs [SERVICE]       Show logs for service"
    echo ""
    echo "Profiles (use with full-stack):"
    echo "  --proxy              Enable Traefik reverse proxy"
    echo "  --monitoring         Enable Prometheus + Grafana"
    echo "  --aws                Enable LocalStack AWS services"
    echo "  --logging            Enable ELK logging stack"
    echo ""
    echo "Examples:"
    echo "  $0 backend-only                    # Backend development"
    echo "  $0 pwa-only                        # Frontend development"
    echo "  $0 full-stack                      # Full integrated stack"
    echo "  $0 full-stack --proxy --monitoring # Full stack with extras"
    echo "  $0 logs backend                    # Show backend logs"
}

# Compose file paths
BACKEND_COMPOSE="workspace/backend/docker-compose.yml"
PWA_COMPOSE="workspace/pwa/docker-compose.yml"
ORCHESTRATOR_COMPOSE="infrastructure/docker/docker-compose.orchestrator.yml"

# Backend only
start_backend_only() {
    print_status "Starting backend workspace only..."
    cd workspace/backend
    docker compose --env-file ../../.env up -d
    cd ../..
    print_success "Backend workspace started"
    
    echo ""
    echo "Backend services available:"
    echo "  • Backend API: http://localhost:3001"
    echo "  • Temporal UI: http://localhost:8088"
    echo "  • PostgreSQL: localhost:5432"
    echo "  • Redis: localhost:6379"
}

# PWA only
start_pwa_only() {
    print_status "Starting PWA workspace only..."
    cd workspace/pwa
    docker compose --env-file ../../.env up -d
    cd ../..
    print_success "PWA workspace started"
    
    echo ""
    echo "PWA services available:"
    echo "  • PWA Frontend: http://localhost:3000"
    echo "  • Storybook: http://localhost:6006"
}

# Full stack
start_full_stack() {
    local profiles=""
    
    # Parse profile options
    for arg in "$@"; do
        case $arg in
            --proxy)
                profiles="$profiles,proxy"
                ;;
            --monitoring)
                profiles="$profiles,monitoring"
                ;;
            --aws)
                profiles="$profiles,aws"
                ;;
            --logging)
                profiles="$profiles,logging"
                ;;
        esac
    done
    
    # Remove leading comma
    profiles="${profiles#,}"
    
    print_status "Starting full integrated stack..."
    
    # Step 1: Start backend workspace
    print_status "Starting backend workspace..."
    cd workspace/backend
    docker compose --env-file ../../.env up -d
    cd ../..
    
    # Step 2: Start PWA workspace  
    print_status "Starting PWA workspace..."
    cd workspace/pwa
    docker compose --env-file ../../.env up -d
    cd ../..
    
    # Step 3: Wait for backend to be healthy (container-internal check)
    print_step "Waiting for Backend API to be healthy..."
    local count=0
    local max_attempts=30
    
    while [ $count -lt $max_attempts ]; do
        if docker exec backend_dev curl -f http://localhost:3001/health >/dev/null 2>&1; then
            print_check "Backend API is healthy"
            break
        fi
        sleep 2
        count=$((count + 1))
        
        # Show progress every 10 attempts
        if (( count % 10 == 0 )); then
            print_info "Still waiting for Backend API... (${count}/${max_attempts})"
        fi
    done
    
    if [ $count -eq $max_attempts ]; then
        print_error "Backend API failed to become healthy within 60 seconds"
        return 1
    fi
    
    # Step 4: Connect services via orchestrator (network + optional services only)
    print_status "Connecting services and starting optional components..."
    if [[ -n "$profiles" ]]; then
        print_status "Enabling profiles: $profiles"
        docker compose --env-file .env -f "$ORCHESTRATOR_COMPOSE" --profile "$profiles" up -d
    else
        docker compose --env-file .env -f "$ORCHESTRATOR_COMPOSE" up -d
    fi
    
    print_success "Full stack started"
    
    echo ""
    echo "Integrated services available:"
    echo "  • PWA Frontend: http://localhost:3000"
    echo "  • Backend API: http://localhost:3001"
    echo "  • Storybook: http://localhost:6006"
    echo "  • Temporal UI: http://localhost:8088"
    echo "  • PostgreSQL: localhost:5432"
    echo "  • Redis: localhost:6379"
    
    if [[ "$profiles" == *"proxy"* ]]; then
        echo "  • Traefik Dashboard: http://localhost:8080"
        echo "  • PWA (via Traefik): https://dice.local"
        echo "  • API (via Traefik): https://api.dice.local"
        echo "  • Temporal (via Traefik): https://temporal.dice.local"
    fi
    
    if [[ "$profiles" == *"monitoring"* ]]; then
        echo "  • Prometheus: http://localhost:9090"
        echo "  • Grafana: http://localhost:3001 (admin/admin)"
    fi
    
    if [[ "$profiles" == *"aws"* ]]; then
        echo "  • LocalStack: http://localhost:4566"
    fi
    
    if [[ "$profiles" == *"logging"* ]]; then
        echo "  • Elasticsearch: http://localhost:9200"
        echo "  • Kibana Dashboard: http://localhost:5601"
        echo "  • Fluent Bit Metrics: http://localhost:2020"
        echo "  • Logging Monitor: ./infrastructure/scripts/logging-monitor.sh"
    fi
}

# Stop all services
stop_all() {
    print_status "Stopping all DICE services..."
    
    # Stop orchestrator services first
    docker compose --env-file .env -f "$ORCHESTRATOR_COMPOSE" down 2>/dev/null || true
    
    # Stop backend workspace
    cd workspace/backend 2>/dev/null && docker compose --env-file ../../.env down 2>/dev/null; cd ../.. 2>/dev/null || true
    
    # Stop PWA workspace
    cd workspace/pwa 2>/dev/null && docker compose --env-file ../../.env down 2>/dev/null; cd ../.. 2>/dev/null || true
    
    print_success "All services stopped"
}

# Clean everything
clean_all() {
    print_warning "This will remove all DICE containers, networks, and volumes!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning all DICE resources..."
        
        # Stop and remove with volumes
        docker compose --env-file .env -f "$ORCHESTRATOR_COMPOSE" down -v 2>/dev/null || true
        cd workspace/backend 2>/dev/null && docker compose --env-file ../../.env down -v 2>/dev/null; cd ../.. 2>/dev/null || true
        cd workspace/pwa 2>/dev/null && docker compose --env-file ../../.env down -v 2>/dev/null; cd ../.. 2>/dev/null || true
        
        # Remove any remaining DICE containers
        docker ps -a --filter "name=dice_" --filter "name=backend_" --filter "name=pwa_" -q | xargs -r docker rm -f
        
        # Remove DICE networks
        docker network ls --filter "name=dice" --filter "name=backend" --filter "name=pwa" -q | xargs -r docker network rm
        
        print_success "All DICE resources cleaned"
    else
        print_status "Clean cancelled"
    fi
}

# Show status
show_status() {
    print_status "DICE Services Status"
    echo ""
    
    # Check orchestrator services
    if docker compose --env-file .env -f "$ORCHESTRATOR_COMPOSE" ps -q >/dev/null 2>&1; then
        echo "🔗 Orchestrator Services:"
        docker compose --env-file .env -f "$ORCHESTRATOR_COMPOSE" ps
        echo ""
    fi
    
    # Check backend workspace
    echo "🖥️  Backend Workspace:"
    cd workspace/backend 2>/dev/null && docker compose --env-file ../../.env ps 2>/dev/null; cd ../.. 2>/dev/null || echo "  No services running"
    echo ""
    
    # Check PWA workspace
    echo "🎨 PWA Workspace:"
    cd workspace/pwa 2>/dev/null && docker compose --env-file ../../.env ps 2>/dev/null; cd ../.. 2>/dev/null || echo "  No services running"
}

# Show logs
show_logs() {
    local service="$1"
    
    if [[ -z "$service" ]]; then
        print_error "Please specify a service name"
        exit 1
    fi
    
    print_status "Showing logs for service: $service"
    
    # Try to find the service in different contexts
    if docker compose --env-file .env -f "$ORCHESTRATOR_COMPOSE" logs "$service" 2>/dev/null; then
        return
    elif (cd workspace/backend && docker compose --env-file ../../.env logs "$service" 2>/dev/null); then
        return
    elif (cd workspace/pwa && docker compose --env-file ../../.env logs "$service" 2>/dev/null); then
        return
    else
        print_error "Service '$service' not found"
        exit 1
    fi
}

# Main script logic
main() {
    # Ensure we're in project root
    ensure_project_root
    
    # Check compose files
    check_dice_compose_files || {
        print_error "Required compose files are missing or invalid"
        exit 1
    }
    
    case "${1:-}" in
        "backend-only")
            start_backend_only
            ;;
        "pwa-only")
            start_pwa_only
            ;;
        "full-stack")
            shift
            start_full_stack "$@"
            ;;
        "stop")
            stop_all
            ;;
        "clean")
            clean_all
            ;;
        "status")
            show_status
            ;;
        "logs")
            shift
            show_logs "$@"
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        "")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 