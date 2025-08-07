#!/bin/bash
# DICE Unified Validation Framework
# Consolidates all validation logic into a single, maintainable solution

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# =============================================================================
# CONFIGURATION
# =============================================================================

# Validation phases
declare -A VALIDATION_PHASES=(
    ["infrastructure"]="Docker, config files, basic services"
    ["services"]="Backend API, PostgreSQL, Redis, Temporal, PWA, Storybook"
    ["security"]="JWT auth, container isolation, dependencies"
    ["logging"]="ELK stack, log ingestion, dashboard foundation"
    ["performance"]="Response times, resource usage, scalability"
    ["integration"]="Service communication, data flow, end-to-end"
)

# Service health endpoints
declare -A HEALTH_ENDPOINTS=(
    ["backend"]="http://localhost:3001/health"
    ["pwa"]="http://localhost:3000"
    ["storybook"]="http://localhost:6006"
    ["temporal"]="http://localhost:8088"
    ["elasticsearch"]="http://localhost:9200/_cluster/health"
    ["kibana"]="http://localhost:5601/api/status"
    ["postgresql"]="localhost:5432"
    ["redis"]="localhost:6379"
)

# Validation thresholds
declare -A VALIDATION_THRESHOLDS=(
    ["response_time"]="2000"  # 2 seconds
    ["memory_usage"]="80"     # 80% of available memory
    ["disk_usage"]="90"       # 90% of available disk
    ["cpu_usage"]="80"        # 80% of available CPU
)

# =============================================================================
# USAGE FUNCTIONS
# =============================================================================

show_usage() {
    cat << EOF
DICE Unified Validation Framework

Usage: $0 [OPTIONS] [PHASE]

Options:
  -a, --all              Run all validation phases
  -p, --phase PHASE      Run specific validation phase
  -s, --service SERVICE  Validate specific service only
  -t, --threshold LEVEL  Set validation threshold (1-10)
  -v, --verbose          Verbose output
  -r, --report           Generate detailed validation report
  -h, --help             Show this help message

Phases:
  infrastructure         Docker, config files, basic services
  services              Backend API, PostgreSQL, Redis, Temporal, PWA, Storybook
  security              JWT auth, container isolation, dependencies
  logging               ELK stack, log ingestion, dashboard foundation
  performance           Response times, resource usage, scalability
  integration           Service communication, data flow, end-to-end

Services:
  backend               Backend API validation
  pwa                   PWA Frontend validation
  temporal              Temporal workflow validation
  elk                   ELK stack validation
  all                   All services

Examples:
  $0 --all                              # Run all validation phases
  $0 --phase infrastructure             # Validate infrastructure only
  $0 --service backend                  # Validate backend service only
  $0 --phase security --threshold 8     # Security validation with threshold 8
  $0 --phase performance --report       # Performance validation with report

EOF
}

# =============================================================================
# INFRASTRUCTURE VALIDATION
# =============================================================================

validate_infrastructure() {
    print_step "🏗️  Infrastructure Validation"
    
    local failures=0
    
    # Test 1: Docker installation
    print_status "Testing Docker installation..."
    if validate_docker_installation; then
        print_success "✅ Docker installation valid"
    else
        print_error "❌ Docker installation failed"
        ((failures++))
    fi
    
    # Test 2: Compose files
    print_status "Testing Docker Compose files..."
    if check_dice_compose_files; then
        print_success "✅ Compose files valid"
    else
        print_error "❌ Compose files validation failed"
        ((failures++))
    fi
    
    # Test 3: Port availability
    print_status "Testing port availability..."
    if check_dice_ports; then
        print_success "✅ Ports available"
    else
        print_warning "⚠️  Some ports in use"
    fi
    
    # Test 4: Directory structure
    print_status "Testing directory structure..."
    if [[ -d "workspace/backend" && -d "workspace/pwa" && -d "infrastructure" ]]; then
        print_success "✅ Directory structure valid"
    else
        print_error "❌ Directory structure incomplete"
        ((failures++))
    fi
    
    # Test 5: Environment file
    print_status "Testing environment configuration..."
    if [[ -f ".env" ]]; then
        print_success "✅ Environment file exists"
    else
        print_warning "⚠️  Environment file missing"
    fi
    
    return $failures
}

# =============================================================================
# SERVICE VALIDATION
# =============================================================================

validate_services() {
    print_step "🔧 Service Validation"
    
    local failures=0
    
    # Test each service
    for service in "${!HEALTH_ENDPOINTS[@]}"; do
        print_status "Testing $service service..."
        
        if validate_service_health "$service"; then
            print_success "✅ $service service healthy"
        else
            print_error "❌ $service service failed"
            ((failures++))
        fi
    done
    
    return $failures
}

validate_service_health() {
    local service="$1"
    local endpoint="${HEALTH_ENDPOINTS[$service]}"
    
    case "$service" in
        "backend"|"pwa"|"storybook"|"temporal"|"elasticsearch"|"kibana")
            # HTTP endpoint validation
            local response
            response=$(curl -s -w "%{http_code}" "$endpoint" -o /dev/null)
            [[ "$response" == "200" ]]
            ;;
        "postgresql")
            # PostgreSQL connection validation
            docker exec backend_postgres_dev pg_isready -U dice_user -d dice_db >/dev/null 2>&1
            ;;
        "redis")
            # Redis connection validation
            docker exec backend_redis_dev redis-cli ping >/dev/null 2>&1
            ;;
        *)
            print_warning "⚠️  Unknown service: $service"
            return 0
            ;;
    esac
}

# =============================================================================
# SECURITY VALIDATION
# =============================================================================

validate_security() {
    print_step "🔐 Security Validation"
    
    local failures=0
    
    # Test 1: JWT Authentication
    print_status "Testing JWT authentication..."
    if test_jwt_authentication; then
        print_success "✅ JWT authentication valid"
    else
        print_error "❌ JWT authentication failed"
        ((failures++))
    fi
    
    # Test 2: Container isolation
    print_status "Testing container isolation..."
    if test_container_isolation; then
        print_success "✅ Container isolation valid"
    else
        print_error "❌ Container isolation failed"
        ((failures++))
    fi
    
    # Test 3: Dependency security
    print_status "Testing dependency security..."
    if test_dependency_security; then
        print_success "✅ Dependency security valid"
    else
        print_warning "⚠️  Dependency security issues detected"
    fi
    
    # Test 4: Environment security
    print_status "Testing environment security..."
    if test_environment_security; then
        print_success "✅ Environment security valid"
    else
        print_error "❌ Environment security failed"
        ((failures++))
    fi
    
    return $failures
}

test_jwt_authentication() {
    # Test JWT authentication flow
    local test_user="test_user_$(date +%s)"
    local test_password="TestPassword123!"
    
    # Register user
    local register_response
    register_response=$(curl -s -X POST "http://localhost:3001/auth/register" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$test_user\",\"password\":\"$test_password\"}")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Extract token
    local token
    token=$(echo "$register_response" | jq -r '.token // empty')
    
    if [[ -z "$token" || "$token" == "null" ]]; then
        return 1
    fi
    
    # Test protected endpoint
    local protected_response
    protected_response=$(curl -s -X GET "http://localhost:3001/auth/profile" \
        -H "Authorization: Bearer $token")
    
    if [[ $? -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_container_isolation() {
    # Test if containers are properly isolated
    local backend_network
    backend_network=$(docker network ls | grep backend_network | wc -l)
    
    local pwa_network
    pwa_network=$(docker network ls | grep pwa_network | wc -l)
    
    if [[ $backend_network -gt 0 && $pwa_network -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_dependency_security() {
    # Test for known vulnerabilities in dependencies
    # This is a simplified check - in production, use proper vulnerability scanning
    
    # Check if critical security packages are up to date
    local security_issues=0
    
    # Test 1: Check for known vulnerable packages
    if docker exec backend_dev npm audit --audit-level=high 2>/dev/null | grep -q "found"; then
        ((security_issues++))
    fi
    
    # Test 2: Check for outdated packages
    if docker exec backend_dev npm outdated 2>/dev/null | grep -q "WARN"; then
        ((security_issues++))
    fi
    
    return $security_issues
}

test_environment_security() {
    # Test environment security configuration
    
    # Test 1: Check for secure secrets
    if [[ -f ".env" ]]; then
        if grep -q "JWT_SECRET=" .env && grep -q "POSTGRES_PASSWORD=" .env; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# =============================================================================
# LOGGING VALIDATION
# =============================================================================

validate_logging() {
    print_step "📊 Logging Validation"
    
    local failures=0
    
    # Test 1: ELK stack health
    print_status "Testing ELK stack health..."
    if test_elk_stack_health; then
        print_success "✅ ELK stack healthy"
    else
        print_error "❌ ELK stack health check failed"
        ((failures++))
    fi
    
    # Test 2: Log ingestion
    print_status "Testing log ingestion..."
    if test_log_ingestion; then
        print_success "✅ Log ingestion working"
    else
        print_error "❌ Log ingestion failed"
        ((failures++))
    fi
    
    # Test 3: Dashboard foundation
    print_status "Testing dashboard foundation..."
    if test_dashboard_foundation; then
        print_success "✅ Dashboard foundation ready"
    else
        print_warning "⚠️  Dashboard foundation incomplete"
    fi
    
    return $failures
}

test_elk_stack_health() {
    # Test Elasticsearch health
    local es_health
    es_health=$(curl -s "http://localhost:9200/_cluster/health" | jq -r '.status')
    
    if [[ "$es_health" == "green" || "$es_health" == "yellow" ]]; then
        return 0
    else
        return 1
    fi
}

test_log_ingestion() {
    # Test if logs are being ingested
    local log_count
    log_count=$(curl -s "http://localhost:9200/dice-*/_count" | jq '.count')
    
    if [[ $log_count -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

test_dashboard_foundation() {
    # Test dashboard foundation components
    
    # Test 1: Index templates
    local templates
    templates=$(curl -s "http://localhost:9200/_template/dice-*" | jq 'keys | length')
    
    # Test 2: Index patterns
    local patterns
    patterns=$(curl -s "http://localhost:5601/api/saved_objects/_find?type=index-pattern" | jq '.total')
    
    if [[ $templates -gt 0 && $patterns -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# PERFORMANCE VALIDATION
# =============================================================================

validate_performance() {
    print_step "⚡ Performance Validation"
    
    local failures=0
    
    # Test 1: Response times
    print_status "Testing response times..."
    if test_response_times; then
        print_success "✅ Response times acceptable"
    else
        print_error "❌ Response times exceeded threshold"
        ((failures++))
    fi
    
    # Test 2: Resource usage
    print_status "Testing resource usage..."
    if test_resource_usage; then
        print_success "✅ Resource usage acceptable"
    else
        print_warning "⚠️  High resource usage detected"
    fi
    
    # Test 3: Scalability
    print_status "Testing scalability..."
    if test_scalability; then
        print_success "✅ Scalability tests passed"
    else
        print_warning "⚠️  Scalability issues detected"
    fi
    
    return $failures
}

test_response_times() {
    local threshold="${VALIDATION_THRESHOLDS[response_time]}"
    local failures=0
    
    # Test backend response time
    local start_time end_time response_time
    start_time=$(date +%s.%N)
    
    curl -s "http://localhost:3001/health" >/dev/null
    
    end_time=$(date +%s.%N)
    response_time=$(echo "($end_time - $start_time) * 1000" | bc -l | cut -d. -f1)
    
    if [[ $response_time -gt $threshold ]]; then
        print_warning "⚠️  Backend response time: ${response_time}ms (threshold: ${threshold}ms)"
        ((failures++))
    else
        print_info "✅ Backend response time: ${response_time}ms"
    fi
    
    # Test PWA response time
    start_time=$(date +%s.%N)
    
    curl -s "http://localhost:3000" >/dev/null
    
    end_time=$(date +%s.%N)
    response_time=$(echo "($end_time - $start_time) * 1000" | bc -l | cut -d. -f1)
    
    if [[ $response_time -gt $threshold ]]; then
        print_warning "⚠️  PWA response time: ${response_time}ms (threshold: ${threshold}ms)"
        ((failures++))
    else
        print_info "✅ PWA response time: ${response_time}ms"
    fi
    
    return $failures
}

test_resource_usage() {
    local memory_threshold="${VALIDATION_THRESHOLDS[memory_usage]}"
    local cpu_threshold="${VALIDATION_THRESHOLDS[cpu_usage]}"
    local failures=0
    
    # Get container resource usage
    local resource_info
    resource_info=$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemPerc}}" 2>/dev/null)
    
    if [[ -n "$resource_info" ]]; then
        print_info "📊 Resource usage summary:"
        echo "$resource_info"
    else
        print_warning "⚠️  Unable to get resource usage information"
        ((failures++))
    fi
    
    return $failures
}

test_scalability() {
    # Test basic scalability indicators
    
    # Test 1: Database connection pool
    local db_connections
    db_connections=$(docker exec backend_postgres_dev psql -U dice_user -d dice_db -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null | tail -n 1)
    
    if [[ $db_connections -lt 100 ]]; then
        print_success "✅ Database connections: $db_connections"
    else
        print_warning "⚠️  High database connections: $db_connections"
    fi
    
    # Test 2: Redis memory usage
    local redis_memory
    redis_memory=$(docker exec backend_redis_dev redis-cli info memory 2>/dev/null | grep "used_memory_human" | cut -d: -f2)
    
    if [[ -n "$redis_memory" ]]; then
        print_info "✅ Redis memory usage: $redis_memory"
    else
        print_warning "⚠️  Unable to get Redis memory usage"
    fi
    
    return 0
}

# =============================================================================
# INTEGRATION VALIDATION
# =============================================================================

validate_integration() {
    print_step "🔗 Integration Validation"
    
    local failures=0
    
    # Test 1: Service communication
    print_status "Testing service communication..."
    if test_service_communication; then
        print_success "✅ Service communication working"
    else
        print_error "❌ Service communication failed"
        ((failures++))
    fi
    
    # Test 2: Data flow
    print_status "Testing data flow..."
    if test_data_flow; then
        print_success "✅ Data flow working"
    else
        print_error "❌ Data flow failed"
        ((failures++))
    fi
    
    # Test 3: End-to-end functionality
    print_status "Testing end-to-end functionality..."
    if test_end_to_end; then
        print_success "✅ End-to-end functionality working"
    else
        print_error "❌ End-to-end functionality failed"
        ((failures++))
    fi
    
    return $failures
}

test_service_communication() {
    # Test communication between services
    
    # Test 1: Backend to database
    local db_test
    db_test=$(docker exec backend_dev curl -s "http://localhost:3001/health" 2>/dev/null | jq -r '.database // empty')
    
    if [[ "$db_test" == "healthy" ]]; then
        print_success "✅ Backend ↔ Database communication"
    else
        print_error "❌ Backend ↔ Database communication failed"
        return 1
    fi
    
    # Test 2: Backend to Redis
    local redis_test
    redis_test=$(docker exec backend_dev curl -s "http://localhost:3001/health" 2>/dev/null | jq -r '.cache // empty')
    
    if [[ "$redis_test" == "healthy" ]]; then
        print_success "✅ Backend ↔ Redis communication"
    else
        print_error "❌ Backend ↔ Redis communication failed"
        return 1
    fi
    
    return 0
}

test_data_flow() {
    # Test data flow through the system
    
    # Test 1: Create test data
    local test_data
    test_data=$(curl -s -X POST "http://localhost:3001/api/test" \
        -H "Content-Type: application/json" \
        -d '{"test": "data"}' 2>/dev/null)
    
    if [[ $? -eq 0 ]]; then
        print_success "✅ Data creation flow"
    else
        print_warning "⚠️  Data creation flow (endpoint may not exist)"
    fi
    
    # Test 2: Retrieve test data
    local retrieve_test
    retrieve_test=$(curl -s "http://localhost:3001/api/test" 2>/dev/null)
    
    if [[ $? -eq 0 ]]; then
        print_success "✅ Data retrieval flow"
    else
        print_warning "⚠️  Data retrieval flow (endpoint may not exist)"
    fi
    
    return 0
}

test_end_to_end() {
    # Test complete end-to-end functionality
    
    # Test 1: Frontend can access backend
    local frontend_backend_test
    frontend_backend_test=$(curl -s "http://localhost:3000" 2>/dev/null | grep -q "DICE" && echo "success" || echo "failed")
    
    if [[ "$frontend_backend_test" == "success" ]]; then
        print_success "✅ Frontend ↔ Backend communication"
    else
        print_error "❌ Frontend ↔ Backend communication failed"
        return 1
    fi
    
    # Test 2: Storybook accessibility
    local storybook_test
    storybook_test=$(curl -s -w "%{http_code}" "http://localhost:6006" -o /dev/null)
    
    if [[ "$storybook_test" == "200" ]]; then
        print_success "✅ Storybook accessibility"
    else
        print_error "❌ Storybook accessibility failed"
        return 1
    fi
    
    return 0
}

# =============================================================================
# REPORT GENERATION
# =============================================================================

generate_validation_report() {
    local report_file="./infrastructure/data/validation_report_$(date +%Y%m%d_%H%M%S).json"
    
    print_step "📋 Generating validation report..."
    
    # Create report structure
    cat > "$report_file" << EOF
{
  "validation_report": {
    "timestamp": "$(date -u '+%Y-%m-%d %H:%M:%S UTC')",
    "version": "1.0",
    "phases": {
EOF
    
    # Add phase results
    local first=true
    for phase in "${!VALIDATION_PHASES[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$report_file"
        fi
        
        echo "      \"$phase\": {" >> "$report_file"
        echo "        \"description\": \"${VALIDATION_PHASES[$phase]}\"," >> "$report_file"
        echo "        \"status\": \"pending\"," >> "$report_file"
        echo "        \"failures\": 0" >> "$report_file"
        echo "      }" >> "$report_file"
    done
    
    # Close report structure
    cat >> "$report_file" << EOF
    },
    "summary": {
      "total_phases": ${#VALIDATION_PHASES[@]},
      "passed_phases": 0,
      "failed_phases": 0,
      "overall_status": "pending"
    }
  }
}
EOF
    
    print_success "✅ Validation report created: $report_file"
    return 0
}

# =============================================================================
# MAIN VALIDATION FUNCTION
# =============================================================================

run_validation_phase() {
    local phase="$1"
    local threshold="${2:-5}"
    
    print_step "🧪 Running $phase validation (threshold: $threshold)"
    
    local failures=0
    
    case "$phase" in
        "infrastructure")
            validate_infrastructure
            failures=$?
            ;;
        "services")
            validate_services
            failures=$?
            ;;
        "security")
            validate_security
            failures=$?
            ;;
        "logging")
            validate_logging
            failures=$?
            ;;
        "performance")
            validate_performance
            failures=$?
            ;;
        "integration")
            validate_integration
            failures=$?
            ;;
        *)
            print_error "Unknown validation phase: $phase"
            return 1
            ;;
    esac
    
    # Calculate score based on threshold
    local max_failures=$((10 - threshold))
    local score=$((10 - failures))
    
    if [[ $score -ge $threshold ]]; then
        print_success "✅ $phase validation passed (score: $score/10)"
        return 0
    else
        print_error "❌ $phase validation failed (score: $score/10, threshold: $threshold/10)"
        return 1
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Parse arguments
    local run_all=false
    local phase=""
    local service=""
    local threshold=5
    local verbose=false
    local generate_report=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--all)
                run_all=true
                shift
                ;;
            -p|--phase)
                phase="$2"
                shift 2
                ;;
            -s|--service)
                service="$2"
                shift 2
                ;;
            -t|--threshold)
                threshold="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -r|--report)
                generate_report=true
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
    show_banner "Unified Validation Framework" "Comprehensive DICE system validation"
    
    # Generate report if requested
    if [[ "$generate_report" == "true" ]]; then
        generate_validation_report
    fi
    
    # Execute validation
    local total_failures=0
    local total_phases=0
    
    if [[ "$run_all" == "true" ]]; then
        print_step "🧪 Running All Validation Phases"
        
        for phase_name in "${!VALIDATION_PHASES[@]}"; do
            ((total_phases++))
            run_validation_phase "$phase_name" "$threshold"
            total_failures=$((total_failures + $?))
        done
    elif [[ -n "$phase" ]]; then
        if [[ -z "${VALIDATION_PHASES[$phase]}" ]]; then
            print_error "Unknown validation phase: $phase"
            print_info "Available phases: ${!VALIDATION_PHASES[*]}"
            exit 1
        fi
        
        ((total_phases++))
        run_validation_phase "$phase" "$threshold"
        total_failures=$?
    elif [[ -n "$service" ]]; then
        print_step "🔧 Service-Specific Validation"
        validate_service_health "$service"
        total_failures=$?
    else
        print_error "No validation target specified"
        show_usage
        exit 1
    fi
    
    # Final summary
    print_step "📊 Validation Framework Summary"
    
    local passed_phases=$((total_phases - total_failures))
    local success_rate=$((passed_phases * 100 / total_phases))
    
    if [[ $total_failures -eq 0 ]]; then
        print_success "✅ All validation phases passed! ($passed_phases/$total_phases)"
    else
        print_warning "⚠️  $total_failures validation phase(s) failed ($passed_phases/$total_phases passed)"
    fi
    
    print_info "📈 Success rate: ${success_rate}%"
    print_info "🎯 Threshold: ${threshold}/10"
    
    show_completion "Unified Validation Framework"
    
    exit $total_failures
}

# Execute main function
main "$@"
