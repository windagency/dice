#!/bin/sh
# DICE Unified Service Manager
# Consolidates all service orchestration into a single, maintainable solution

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/common.sh"

# =============================================================================
# CONFIGURATION
# =============================================================================

# Service configurations (using POSIX-compliant approach)
# Format: service_name|compose_file|description|ports
SERVICE_CONFIGS="
backend|workspace/backend/docker-compose.yml|Backend API + Database + Temporal + LocalStack|3001,5432,6379,7233,8088,4566
pwa|workspace/pwa/docker-compose.yml|PWA Frontend + Storybook|3000,6006
elk|infrastructure/docker/logging-stack.yml|ELK Stack (Elasticsearch + Kibana + Fluent Bit)|9200,5601,2020
cleaner|infrastructure/docker/logging-stack.yml|Log Cleaner Service|
orchestrator|infrastructure/docker/docker-compose.orchestrator.yml|Full Stack Orchestration|80,443,8080
"

# Profile configurations
PROFILE_CONFIGS="
proxy|Traefik Reverse Proxy|80,443,8080
monitoring|Prometheus + Grafana|9090,3001
logging|ELK Logging Stack|9200,5601,2020
"

# Health check endpoints
HEALTH_ENDPOINTS="
backend|http://localhost:3001/health
pwa|http://localhost:3000
storybook|http://localhost:6006
temporal|http://localhost:8088
kibana|http://localhost:5601/api/status
elk|http://localhost:9200/_cluster/health
orchestrator|
localstack|http://localhost.localstack.cloud:4566/_localstack/health
"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Get service config by name
get_service_config() {
    local service_name="$1"
    echo "$SERVICE_CONFIGS" | while IFS='|' read -r name compose_file description ports; do
        if [ "$name" = "$service_name" ]; then
            echo "$compose_file|$description|$ports"
            return 0
        fi
    done
}

# Get profile config by name
get_profile_config() {
    local profile_name="$1"
    echo "$PROFILE_CONFIGS" | while IFS='|' read -r name description ports; do
        if [ "$name" = "$profile_name" ]; then
            echo "$description|$ports"
            return 0
        fi
    done
}

# Get health endpoint by service name
get_health_endpoint() {
    local service_name="$1"
    echo "$HEALTH_ENDPOINTS" | while IFS='|' read -r name endpoint; do
        if [ "$name" = "$service_name" ]; then
            echo "$endpoint"
            return 0
        fi
    done
}

# =============================================================================
# PROGRESS TRACKING FUNCTIONS
# =============================================================================

# Progress tracking variables
PROGRESS_STEPS=""
CURRENT_STEP=0
TOTAL_STEPS=0

# Initialize progress tracking
init_progress() {
    local total="$1"
    TOTAL_STEPS=$total
    CURRENT_STEP=0
    PROGRESS_STEPS=""
}

# Add progress step
add_progress_step() {
    local step="$1"
    local description="$2"
    local estimated_time="$3"
    PROGRESS_STEPS="${PROGRESS_STEPS}${step}|${description}|${estimated_time}\n"
}

# Update progress and show current step
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local step_info=$(echo "$PROGRESS_STEPS" | sed -n "${CURRENT_STEP}p")
    local step description estimated_time
    IFS='|' read -r step description estimated_time << EOF
$step_info
EOF
    
    echo ""
    echo "=============================================="
    echo "🔄 [${CURRENT_STEP}/${TOTAL_STEPS}] $description"
    if [ -n "$estimated_time" ]; then
        echo "⏱️  Estimated time: $estimated_time"
    fi
    echo "=============================================="
    echo ""
}

# Show progress summary
show_progress_summary() {
    echo ""
    echo "=============================================="
    echo "📊 Progress Summary:"
    echo "✅ Completed: $CURRENT_STEP/$TOTAL_STEPS steps"
    echo "⏳ Remaining: $((TOTAL_STEPS - CURRENT_STEP)) steps"
    echo "=============================================="
}

# Show progress bar
show_progress_bar() {
    local current="$1"
    local total="$2"
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d%%" "$percentage"
    
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# Monitor container startup
monitor_container_startup() {
    local service="$1"
    local compose_file="$2"
    local max_wait=60
    local wait_time=0
    
    echo "⏳ Waiting for $service containers to be ready..."
    
    while [ $wait_time -lt $max_wait ]; do
        local healthy_containers=$(docker compose -f "$compose_file" ps -q --filter "status=running" | wc -l)
        local total_containers=$(docker compose -f "$compose_file" ps -q | wc -l)
        
        if [ "$healthy_containers" -eq "$total_containers" ] && [ "$total_containers" -gt 0 ]; then
            echo "✅ $service containers are ready!"
            return 0
        fi
        
        echo "⏳ $service: $healthy_containers/$total_containers containers ready..."
        sleep 2
        wait_time=$((wait_time + 2))
    done
    
    echo "⚠️  $service containers took longer than expected to start"
    return 1
}

# Report service failure with detailed information
report_service_failure() {
    local service="$1"
    local compose_file="$2"
    
    echo "=============================================="
    echo "❌ $service service failed to start"
    echo "=============================================="
    echo "🔍 Troubleshooting information:"
    echo "   📁 Compose file: $compose_file"
    echo "   📋 Container status:"
    docker compose -f "$compose_file" ps
    echo "   📝 Recent logs:"
    docker compose -f "$compose_file" logs --tail=10
    echo ""
    echo "💡 Common solutions:"
    echo "   - Check if ports are available"
    echo "   - Ensure Docker has enough resources"
    echo "   - Try: make service-clean && make start-$service"
    echo "   - Check the logs for more detailed error messages"
    echo "     docker compose -f $compose_file logs --tail=10"
}

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
    
    local config
    config=$(get_service_config "$service")
    if [ -z "$config" ]; then
        print_error "Unknown service: $service"
        return 1
    fi
    
    IFS='|' read -r compose_file description ports <<< "$config"
    
    echo "🔧 Starting $service service: $description"
    echo "📁 Compose file: $compose_file"
    echo "🌐 Ports: $ports"
    
    if [ -n "$profiles" ]; then
        echo "⚙️  Profiles: $profiles"
    fi
    
    # Check if compose file exists
    if [ ! -f "$compose_file" ]; then
        print_error "Compose file not found: $compose_file"
        return 1
    fi
    
    # Show service-specific components
    case "$service" in
        "backend")
            echo "🔧 Backend Service Components:"
            echo "   📦 Backend API (NestJS)"
            echo "   🗄️  PostgreSQL Database"
            echo "   ⚡ Redis Cache"
            echo "   🔄 Temporal Workflow Engine"
            echo "   🖥️  Temporal UI"
            echo "   🔑 LocalStack AWS Services"
            echo ""
            echo "⏳ Starting components in dependency order..."
            ;;
        "pwa")
            echo "🎨 PWA Service Components:"
            echo "   📱 PWA Frontend (Astro + React)"
            echo "   📚 Storybook Component Library"
            echo ""
            echo "⏳ Starting components..."
            ;;
        "elk")
            echo "📊 ELK Service Components:"
            echo "   🔍 Elasticsearch (Log Storage)"
            echo "   📈 Kibana (Log Dashboard)"
            echo "   📝 Fluent Bit (Log Collection)"
            echo ""
            echo "⏳ Starting components (this may take 30-45 seconds)..."
            ;;
        "orchestrator")
            echo "🎛️  Orchestrator Service Components:"
            echo "   🌐 Traefik Reverse Proxy"
            echo "   🔒 SSL/TLS Termination"
            echo "   📊 API Dashboard"
            if [[ "$profiles" == *"logging"* ]]; then
                echo "   📊 ELK Logging Stack"
            fi
            if [[ "$profiles" == *"monitoring"* ]]; then
                echo "   📈 Prometheus + Grafana"
            fi
            echo ""
            echo "⏳ Starting components..."
            ;;
    esac
    
    # Start service with progress
    echo "🚀 Starting containers..."
    local start_time=$(date +%s)
    
    # Standard service startup
    if [ -n "$profiles" ]; then
        if docker compose -f "$compose_file" --profile "$profiles" up -d; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            print_success "✅ $service service started successfully in ${duration}s"
            return 0
        else
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            print_error "❌ Failed to start $service service (${duration}s)"
            report_service_failure "$service" "$compose_file"
            return 1
        fi
    else
        if docker compose -f "$compose_file" up -d; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            print_success "✅ $service service started successfully in ${duration}s"
            return 0
        else
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            print_error "❌ Failed to start $service service (${duration}s)"
            report_service_failure "$service" "$compose_file"
            return 1
        fi
    fi
}

# Stop a specific service
stop_service() {
    local service="$1"
    local profiles="$2" # Add profiles argument
    
    local config=$(get_service_config "$service")
    if [[ -z "$config" ]]; then
        print_error "Unknown service: $service"
        return 1
    fi
    
    IFS='|' read -r compose_file description ports <<< "$config"
    
    print_step "🛑 Stopping $service service: $description"
    
    if [ -n "$profiles" ]; then
        docker compose -f "$compose_file" --profile "$profiles" down
    else
        docker compose -f "$compose_file" down
    fi
    
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
    
    local config=$(get_service_config "$service")
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
    
    local config=$(get_service_config "$service")
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
    
    local endpoint=$(get_health_endpoint "$service")
    
    # Special handling for orchestrator service
    if [[ "$service" == "orchestrator" ]]; then
        print_status "🏥 Health checking $service service..."
        
        # Check if Traefik container is running
        if docker ps --format "table {{.Names}}" | grep -q "dice_orchestrator_traefik"; then
            print_success "✅ $service service is healthy (container running)"
            return 0
        else
            print_error "❌ $service service health check failed (container not running)"
            return 1
        fi
    fi
    
    # Enhanced LocalStack health check
    if [[ "$service" == "localstack" ]]; then
        print_status "🏥 Health checking $service service (enhanced)..."
        enhanced_localstack_health_check
        return $?
    fi
    
    # Enhanced backend health check
    if [[ "$service" == "backend" ]]; then
        print_status "🏥 Health checking $service service (enhanced)..."
        enhanced_backend_health_check
        return $?
    fi
    
    # Enhanced PWA health check
    if [[ "$service" == "pwa" ]]; then
        print_status "🏥 Health checking $service service (enhanced)..."
        enhanced_pwa_health_check
        return $?
    fi
    
    # Enhanced ELK health check
    if [[ "$service" == "elk" ]]; then
        print_status "🏥 Health checking $service service (enhanced)..."
        enhanced_elk_health_check
        return $?
    fi
    
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

# Wait for service to be ready
wait_for_service() {
    local service="$1"
    local max_attempts=60
    local attempt=1
    local delay=3
    
    print_status "⏳ Waiting for $service to be ready..."
    
    while [[ $attempt -le $max_attempts ]]; do
        case "$service" in
            "backend")
                if curl -s -f "http://localhost:3001/health" >/dev/null 2>&1; then
                    print_success "✅ Backend service is ready"
                    return 0
                fi
                ;;
            "pwa")
                if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
                    print_success "✅ PWA service is ready"
                    return 0
                fi
                ;;
            "storybook")
                if curl -s -f "http://localhost:6006" >/dev/null 2>&1; then
                    print_success "✅ Storybook service is ready"
                    return 0
                fi
                ;;
            "postgres")
                if docker exec dice_backend_postgres pg_isready -U dice_user -d dice_db >/dev/null 2>&1; then
                    print_success "✅ PostgreSQL service is ready"
                    return 0
                fi
                ;;
            "redis")
                if docker exec dice_backend_redis redis-cli ping >/dev/null 2>&1; then
                    print_success "✅ Redis service is ready"
                    return 0
                fi
                ;;
            "temporal")
                if curl -s -f "http://localhost:8088" >/dev/null 2>&1; then
                    print_success "✅ Temporal service is ready"
                    return 0
                fi
                ;;
            "localstack")
                if curl -s -f "http://localhost.localstack.cloud:4566/_localstack/health" >/dev/null 2>&1; then
                    print_success "✅ LocalStack service is ready"
                    return 0
                fi
                ;;
        esac
        
        if [[ $attempt -eq $max_attempts ]]; then
            print_error "❌ $service service failed to start within timeout"
            return 1
        fi
        
        # Only show warning every 5 attempts to reduce noise
        if [[ $((attempt % 5)) -eq 0 ]] || [[ $attempt -le 3 ]]; then
            print_warning "⚠️  $service not ready yet (attempt $attempt/$max_attempts)"
        fi
        sleep $delay
        ((attempt++))
    done
}

# Enhanced backend health check function
enhanced_backend_health_check() {
    local failures=0
    local total_checks=0
    local max_retries=5
    local retry_delay=10
    
    print_status "🔍 Checking Backend API..."
    ((total_checks++))
    local api_response="000"
    local retry_count=0
    
    # Retry logic for API health check
    while [[ $retry_count -lt $max_retries ]]; do
        api_response=$(curl -s -w "%{http_code}" "http://localhost:3001/health" -o /dev/null --connect-timeout 15 --max-time 45)
        if [[ "$api_response" == "200" ]]; then
            print_success "✅ Backend API is healthy"
            break
        else
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                print_warning "⚠️  Backend API health check failed (HTTP $api_response), retrying in ${retry_delay}s... (attempt $retry_count/$max_retries)"
                sleep $retry_delay
            else
                print_error "❌ Backend API health check failed (HTTP $api_response) after $max_retries attempts"
                ((failures++))
            fi
        fi
    done
    
    print_status "🔍 Checking Temporal Workflow Engine..."
    ((total_checks++))
    local temporal_response="000"
    retry_count=0
    
    # Retry logic for Temporal health check
    while [[ $retry_count -lt $max_retries ]]; do
        temporal_response=$(curl -s -w "%{http_code}" "http://localhost:8088" -o /dev/null --connect-timeout 15 --max-time 45)
        if [[ "$temporal_response" == "200" ]]; then
            print_success "✅ Temporal Workflow Engine is healthy"
            break
        else
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                print_warning "⚠️  Temporal Workflow Engine health check failed (HTTP $temporal_response), retrying in ${retry_delay}s... (attempt $retry_count/$max_retries)"
                sleep $retry_delay
            else
                print_error "❌ Temporal Workflow Engine health check failed (HTTP $temporal_response) after $max_retries attempts"
                ((failures++))
            fi
        fi
    done
    
    print_status "🔍 Checking PostgreSQL Database..."
    ((total_checks++))
    retry_count=0
    
    # Retry logic for PostgreSQL health check
    while [[ $retry_count -lt $max_retries ]]; do
        if docker exec dice_backend_postgres pg_isready -U dice_user -d dice_db >/dev/null 2>&1; then
            print_success "✅ PostgreSQL Database is healthy"
            break
        else
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                print_warning "⚠️  PostgreSQL Database health check failed, retrying in ${retry_delay}s... (attempt $retry_count/$max_retries)"
                sleep $retry_delay
            else
                print_error "❌ PostgreSQL Database health check failed after $max_retries attempts"
                ((failures++))
            fi
        fi
    done
    
    print_status "🔍 Checking Redis Cache..."
    ((total_checks++))
    retry_count=0
    
    # Retry logic for Redis health check
    while [[ $retry_count -lt $max_retries ]]; do
        if docker exec dice_backend_redis redis-cli ping >/dev/null 2>&1; then
            print_success "✅ Redis Cache is healthy"
            break
        else
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                print_warning "⚠️  Redis Cache health check failed, retrying in ${retry_delay}s... (attempt $retry_count/$max_retries)"
                sleep $retry_delay
            else
                print_error "❌ Redis Cache health check failed after $max_retries attempts"
                ((failures++))
            fi
        fi
    done
    
    # Summary
    if [[ $failures -eq 0 ]]; then
        print_success "✅ Backend service is healthy (all $total_checks components)"
        return 0
    else
        print_error "❌ Backend service has health issues ($failures/$total_checks components failed)"
        return 1
    fi
}

# Enhanced PWA health check function
enhanced_pwa_health_check() {
    local failures=0
    local total_checks=0
    local max_retries=5
    local retry_delay=10
    
    print_status "🔍 Checking PWA Frontend..."
    ((total_checks++))
    local pwa_response="000"
    local retry_count=0
    
    # Retry logic for PWA health check
    while [[ $retry_count -lt $max_retries ]]; do
        pwa_response=$(curl -s -w "%{http_code}" "http://localhost:3000" -o /dev/null --connect-timeout 15 --max-time 45)
        if [[ "$pwa_response" == "200" ]]; then
            print_success "✅ PWA Frontend is healthy"
            break
        else
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                print_warning "⚠️  PWA Frontend health check failed (HTTP $pwa_response), retrying in ${retry_delay}s... (attempt $retry_count/$max_retries)"
                sleep $retry_delay
            else
                print_error "❌ PWA Frontend health check failed (HTTP $pwa_response) after $max_retries attempts"
                ((failures++))
            fi
        fi
    done
    
    print_status "🔍 Checking Storybook Component Library..."
    ((total_checks++))
    local storybook_response="000"
    retry_count=0
    
    # Retry logic for Storybook health check
    while [[ $retry_count -lt $max_retries ]]; do
        storybook_response=$(curl -s -w "%{http_code}" "http://localhost:6006" -o /dev/null --connect-timeout 15 --max-time 45)
        if [[ "$storybook_response" == "200" ]]; then
            print_success "✅ Storybook Component Library is healthy"
            break
        else
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                print_warning "⚠️  Storybook Component Library health check failed (HTTP $storybook_response), retrying in ${retry_delay}s... (attempt $retry_count/$max_retries)"
                sleep $retry_delay
            else
                print_error "❌ Storybook Component Library health check failed (HTTP $storybook_response) after $max_retries attempts"
                ((failures++))
            fi
        fi
    done
    
    # Summary
    if [[ $failures -eq 0 ]]; then
        print_success "✅ PWA service is healthy (all $total_checks components)"
        return 0
    else
        print_error "❌ PWA service has health issues ($failures/$total_checks components failed)"
        return 1
    fi
}

# Enhanced ELK health check function
enhanced_elk_health_check() {
    local failures=0
    local total_checks=0
    
    print_status "🔍 Checking Elasticsearch..."
    ((total_checks++))
    local elasticsearch_response
    elasticsearch_response=$(curl -s -w "%{http_code}" "http://localhost:9200/_cluster/health" -o /dev/null)
    if [[ "$elasticsearch_response" == "200" ]]; then
        print_success "✅ Elasticsearch is healthy"
    else
        print_error "❌ Elasticsearch health check failed (HTTP $elasticsearch_response)"
        ((failures++))
    fi
    
    print_status "🔍 Checking Kibana..."
    ((total_checks++))
    local kibana_response
    kibana_response=$(curl -s -w "%{http_code}" "http://localhost:5601/api/status" -o /dev/null)
    if [[ "$kibana_response" == "200" ]]; then
        print_success "✅ Kibana is healthy"
    else
        print_error "❌ Kibana health check failed (HTTP $kibana_response)"
        ((failures++))
    fi
    
    print_status "🔍 Checking Fluent Bit..."
    ((total_checks++))
    local fluent_bit_response
    fluent_bit_response=$(curl -s -w "%{http_code}" "http://localhost:2020/api/v1/health" -o /dev/null)
    if [[ "$fluent_bit_response" == "200" ]]; then
        print_success "✅ Fluent Bit is healthy"
    else
        print_error "❌ Fluent Bit health check failed (HTTP $fluent_bit_response)"
        ((failures++))
    fi
    
    # Summary
    if [[ $failures -eq 0 ]]; then
        print_success "✅ ELK service is healthy (all $total_checks components)"
        return 0
    else
        print_error "❌ ELK service has health issues ($failures/$total_checks components failed)"
        return 1
    fi
}

# Enhanced LocalStack health check function
enhanced_localstack_health_check() {
    local failures=0
    local total_checks=0
    local max_retries=5
    local retry_delay=10
    
    print_status "🔍 Checking LocalStack Core..."
    ((total_checks++))
    local core_response="000"
    local retry_count=0
    
    # Retry logic for LocalStack core health check
    while [[ $retry_count -lt $max_retries ]]; do
        core_response=$(curl -s -w "%{http_code}" "http://localhost.localstack.cloud:4566/_localstack/health" -o /dev/null --connect-timeout 15 --max-time 45)
        if [[ "$core_response" == "200" ]]; then
            print_success "✅ LocalStack Core is healthy"
            break
        else
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                print_warning "⚠️  LocalStack Core health check failed (HTTP $core_response), retrying in ${retry_delay}s... (attempt $retry_count/$max_retries)"
                sleep $retry_delay
            else
                print_error "❌ LocalStack Core health check failed (HTTP $core_response) after $max_retries attempts"
                ((failures++))
            fi
        fi
    done
    
    print_status "🔍 Checking LocalStack Services..."
    ((total_checks++))
    local services_response="000"
    retry_count=0
    
    # Retry logic for LocalStack services health check
    while [[ $retry_count -lt $max_retries ]]; do
        services_response=$(curl -s -w "%{http_code}" "http://localhost.localstack.cloud:4566/_localstack/services" -o /dev/null --connect-timeout 15 --max-time 45)
        if [[ "$services_response" == "200" ]]; then
            print_success "✅ LocalStack Services are healthy"
            break
        else
            ((retry_count++))
            if [[ $retry_count -lt $max_retries ]]; then
                print_warning "⚠️  LocalStack Services health check failed (HTTP $services_response), retrying in ${retry_delay}s... (attempt $retry_count/$max_retries)"
                sleep $retry_delay
            else
                print_error "❌ LocalStack Services health check failed (HTTP $services_response) after $max_retries attempts"
                ((failures++))
            fi
        fi
    done
    
    # Summary
    if [[ $failures -eq 0 ]]; then
        print_success "✅ LocalStack service is healthy (all $total_checks components)"
        return 0
    else
        print_error "❌ LocalStack service has health issues ($failures/$total_checks components failed)"
        return 1
    fi
}

# =============================================================================
# BULK OPERATIONS
# =============================================================================

# Start all services
start_all_services() {
    local profiles="$1" # This variable will carry any profiles passed from the command line

    # Initialize progress tracking
    local total_steps=4
    init_progress $total_steps
    add_progress_step "orchestrator" "Starting Full Stack Orchestration (Traefik)" "5-10s"
    add_progress_step "backend" "Starting Backend API + Database + Temporal + LocalStack" "25-35s"
    add_progress_step "pwa" "Starting PWA Frontend + Storybook" "5-10s"
    add_progress_step "elk" "Starting ELK Stack (Elasticsearch + Kibana + Fluent Bit)" "30-45s"
    
    print_step "🚀 Starting all DICE services"
    echo "📋 Total steps: $TOTAL_STEPS"
    echo "⏱️  Estimated total time: 65-90 seconds (including LocalStack)"
    echo ""
    
    local failures=0
    local start_time=$(date +%s)
    
    # Step 1: Orchestrator
    update_progress
    local orchestrator_profiles="proxy"
    if [ -n "$profiles" ]; then
        orchestrator_profiles="${orchestrator_profiles},${profiles}"
    fi
    if ! start_service "orchestrator" "$orchestrator_profiles"; then
        failures=$((failures + 1))
    fi

    # Step 2: Backend (includes LocalStack)
    update_progress
    if ! start_service "backend"; then
        failures=$((failures + 1))
    fi
    
    # Step 3: PWA
    update_progress
    if ! start_service "pwa"; then
        failures=$((failures + 1))
    fi
    
    # Step 4: ELK
    update_progress
    if ! start_service "elk" "logging"; then
        failures=$((failures + 1))
    fi
    
    # Calculate total time
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    
    echo ""
    show_progress_summary
    echo "⏱️  Actual total time: ${total_time}s"
    
    if [ $failures -eq 0 ]; then
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
    
    # Stop backend services
    print_status "Stopping services in workspace/backend/docker-compose.yml..."
    if [ -f "workspace/backend/docker-compose.yml" ]; then
        if ! docker compose -f "workspace/backend/docker-compose.yml" down; then
            print_error "❌ Failed to stop services in workspace/backend/docker-compose.yml"
            ((failures++))
        fi
    else
        print_warning "⚠️  Compose file not found: workspace/backend/docker-compose.yml (skipping)"
    fi
    
    # Stop PWA services
    print_status "Stopping services in workspace/pwa/docker-compose.yml..."
    if [ -f "workspace/pwa/docker-compose.yml" ]; then
        if ! docker compose -f "workspace/pwa/docker-compose.yml" down; then
            print_error "❌ Failed to stop services in workspace/pwa/docker-compose.yml"
            ((failures++))
        fi
    else
        print_warning "⚠️  Compose file not found: workspace/pwa/docker-compose.yml (skipping)"
    fi
    
    # Stop ELK services with logging profile
    print_status "Stopping services in infrastructure/docker/logging-stack.yml..."
    if [ -f "infrastructure/docker/logging-stack.yml" ]; then
        if ! docker compose -f "infrastructure/docker/logging-stack.yml" --profile logging down; then
            print_error "❌ Failed to stop services in infrastructure/docker/logging-stack.yml"
            ((failures++))
        fi
    else
        print_warning "⚠️  Compose file not found: infrastructure/docker/logging-stack.yml (skipping)"
    fi
    
    # Stop orchestrator services with proxy profile
    print_status "Stopping services in infrastructure/docker/docker-compose.orchestrator.yml..."
    if [ -f "infrastructure/docker/docker-compose.orchestrator.yml" ]; then
        if ! docker compose -f "infrastructure/docker/docker-compose.orchestrator.yml" --profile proxy down; then
            print_error "❌ Failed to stop services in infrastructure/docker/docker-compose.orchestrator.yml"
            ((failures++))
        fi
    else
        print_warning "⚠️  Compose file not found: infrastructure/docker/docker-compose.orchestrator.yml (skipping)"
    fi
    
    if [[ $failures -eq 0 ]]; then
        print_success "✅ All services stopped successfully"
    else
        print_warning "⚠️  $failures Docker Compose file(s) failed to stop completely"
    fi
    
    return $failures
}

# Get status of all services
get_all_service_status() {
    print_step "📊 DICE Services Status Overview"
    
    local total_services=0
    local running_services=0
    
    for service in "backend" "pwa" "elk" "orchestrator"; do
        ((total_services++))
        
        local config=$(get_service_config "$service")
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
    
    # Wait for services to be ready before health checks
    print_status "⏳ Waiting for services to be ready..."
    
    # Wait for backend dependencies first
    if ! wait_for_service "postgres"; then
        print_error "❌ PostgreSQL failed to start"
        ((failures++))
    fi
    
    if ! wait_for_service "redis"; then
        print_error "❌ Redis failed to start"
        ((failures++))
    fi
    
    # Wait for main services
    if ! wait_for_service "backend"; then
        print_error "❌ Backend failed to start"
        ((failures++))
    fi
    
    if ! wait_for_service "pwa"; then
        print_error "❌ PWA failed to start"
        ((failures++))
    fi
    
    if ! wait_for_service "storybook"; then
        print_error "❌ Storybook failed to start"
        ((failures++))
    fi
    
    if ! wait_for_service "temporal"; then
        print_error "❌ Temporal failed to start"
        ((failures++))
    fi
    
    # Wait for LocalStack if it's running
    if docker ps --format "table {{.Names}}" | grep -q "dice_localstack_orchestrated"; then
        if ! wait_for_service "localstack"; then
            print_error "❌ LocalStack failed to start"
            ((failures++))
        fi
    fi
    
    # Now perform detailed health checks
    print_status "🔍 Performing detailed health checks..."
    
    for service in "backend" "pwa" "elk" "orchestrator" "localstack"; do
        # Skip LocalStack if not running
        if [[ "$service" == "localstack" ]] && ! docker ps --format "table {{.Names}}" | grep -q "dice_localstack_orchestrated"; then
            continue
        fi
        
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
        
        print_status "Removing containers and volumes..."
        # Backend services
        docker compose -f workspace/backend/docker-compose.yml down -v
        # PWA services
        docker compose -f workspace/pwa/docker-compose.yml down -v
        # ELK services with logging profile
        docker compose -f infrastructure/docker/logging-stack.yml --profile logging down -v
        # Orchestrator services with proxy profile
        docker compose -f infrastructure/docker/docker-compose.orchestrator.yml --profile proxy down -v
        
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
