#!/bin/bash
# DICE Infrastructure Scripts - Common Library
# Shared functions and utilities for all infrastructure scripts

set -e

# =============================================================================
# COLOR & MESSAGING FUNCTIONS
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output with consistent formatting
print_status() {
    echo -e "${BLUE}[DICE]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}🔧${NC} $1"
}

print_check() {
    echo -e "${GREEN}✅${NC} $1"
}

print_info() {
    echo -e "${BLUE}📋${NC} $1"
}

# =============================================================================
# ENVIRONMENT & SECRET FUNCTIONS
# =============================================================================

# Generate cryptographically secure secrets
generate_secret() {
    local length="${1:-32}"
    openssl rand -hex "$length"
}

# Generate secure password (16 hex chars = 128 bits)
generate_password() {
    generate_secret 16
}

# Generate JWT secret (32 hex chars = 256 bits)
generate_jwt_secret() {
    generate_secret 32
}

# Create backup of file with .bak extension
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak"
        return 0
    fi
    return 1
}

# Update environment variable in file
update_env_var() {
    local file="$1"
    local var_name="$2"
    local var_value="$3"
    
    if [[ -f "$file" ]]; then
        backup_file "$file"
        sed -i.tmp "s/${var_name}=.*/${var_name}=${var_value}/" "$file"
        rm "${file}.tmp" 2>/dev/null || true
    fi
}

# Create standard environment configuration
create_standard_env() {
    local env_file="$1"
    local env_type="${2:-development}"
    
    # Generate secrets
    local postgres_password
    local jwt_secret
    postgres_password=$(generate_password)
    jwt_secret=$(generate_jwt_secret)
    
    print_step "Creating $env_type environment file: $env_file"
    
    cat > "$env_file" << EOF
# DICE $env_type Environment Configuration
# Generated: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
# WARNING: Never commit this file to version control

# Database Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=dice_db
POSTGRES_USER=dice_user
POSTGRES_PASSWORD=$postgres_password
DATABASE_URL=postgresql://dice_user:\$POSTGRES_PASSWORD@postgres:5432/dice_db

# Cache Configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_URL=redis://redis:6379

# Authentication & Security
JWT_SECRET=$jwt_secret
BACKEND_API_KEY=dice_backend_api_$(generate_secret 16)
INTERNAL_JWT_SECRET=dice_internal_jwt_$(generate_secret 16)

# Development Settings
NODE_ENV=$env_type
LOG_LEVEL=debug
ASTRO_TELEMETRY_DISABLED=1

# Service URLs (Internal Docker Network)
BACKEND_URL=http://backend:3001
PWA_URL=http://pwa:3000

# Temporal Configuration
TEMPORAL_ADDRESS=temporal:7233

# LocalStack Configuration (AWS Simulation)
LOCALSTACK_ENDPOINT=http://localhost.localstack.cloud:4566
LOCALSTACK_ACCESS_KEY_ID=test
LOCALSTACK_SECRET_ACCESS_KEY=test
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_DEFAULT_REGION=eu-west-3

# Optional Service Configuration
TRAEFIK_API_DASHBOARD=true
TRAEFIK_LOG_LEVEL=INFO
PROMETHEUS_ENABLED=false
GRAFANA_ENABLED=false
EOF
    
    print_check "Environment file created with generated secrets"
    print_warning "Keep this file secure - it contains sensitive secrets"
    
    return 0
}

# =============================================================================
# DIRECTORY & PERMISSION FUNCTIONS
# =============================================================================

# Create standard DICE directory structure
create_dice_directories() {
    print_step "Creating DICE directory structure..."
    
    # Infrastructure directories
    mkdir -p infrastructure/data/{postgres,redis,localstack,uploads,backups,traefik}
    mkdir -p infrastructure/config
    mkdir -p infrastructure/temporal
    mkdir -p infrastructure/scripts/seed-data
    
    # Workspace directories
    mkdir -p workspace/backend/{src,node_modules,.devcontainer}
    mkdir -p workspace/pwa/{src,public,node_modules,.devcontainer}
    mkdir -p workspace/shared/{types,utils,.devcontainer}
    
    # DevContainer directories
    mkdir -p .devcontainer
    
    print_check "Directory structure created"
}

# Set standard permissions for DICE project
set_dice_permissions() {
    print_step "Setting DICE permissions..."
    
    # Make all scripts executable
    find infrastructure/scripts -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    # Set data directory permissions
    chmod -R 755 infrastructure/data/ 2>/dev/null || true
    
    # Set config directory permissions
    chmod -R 755 infrastructure/config/ 2>/dev/null || true
    
    print_check "Permissions set"
}

# =============================================================================
# DOCKER VALIDATION FUNCTIONS
# =============================================================================

# Check if Docker is installed and running
validate_docker_installation() {
    print_step "Validating Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        print_info "Please install Docker Desktop or Rancher Desktop"
        return 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running"
        print_info "Please start Docker Desktop or Rancher Desktop"
        return 1
    fi
    
    # Check Docker Compose availability
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available"
        print_info "Please update Docker to latest version"
        return 1
    fi
    
    print_check "Docker installation valid"
    return 0
}

# Validate Docker Compose files
validate_compose_files() {
    local files=("$@")
    print_step "Validating Docker Compose files..."
    
    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Compose file not found: $file"
            return 1
        fi
        
        if ! docker compose -f "$file" config >/dev/null 2>&1; then
            print_error "Invalid compose file: $file"
            return 1
        fi
    done
    
    print_check "All compose files are valid"
    return 0
}

# Check if required compose files exist
check_dice_compose_files() {
    local files=(
        "workspace/backend/docker-compose.yml"
        "workspace/pwa/docker-compose.yml"
        "infrastructure/docker/docker-compose.orchestrator.yml"
    )
    
    validate_compose_files "${files[@]}"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Check if port is available
is_port_available() {
    local port="$1"
    if command -v lsof >/dev/null 2>&1; then
        ! lsof -Pi ":$port" -sTCP:LISTEN -t >/dev/null 2>&1
    else
        # Fallback method using netstat
        ! netstat -ln 2>/dev/null | grep -q ":$port "
    fi
}

# Check multiple ports availability
check_port_availability() {
    local ports=("$@")
    print_step "Checking port availability..."
    
    local unavailable_ports=()
    
    for port in "${ports[@]}"; do
        if ! is_port_available "$port"; then
            unavailable_ports+=("$port")
            print_warning "Port $port is already in use"
        fi
    done
    
    if [[ ${#unavailable_ports[@]} -eq 0 ]]; then
        print_check "All ports are available"
        return 0
    else
        print_error "Ports in use: ${unavailable_ports[*]}"
        print_info "Please stop services using these ports before continuing"
        return 1
    fi
}

# Check DICE standard ports
check_dice_ports() {
    local dice_ports=(80 443 3000 3001 3002 5432 6379 7233 8080 8088 9090)
    check_port_availability "${dice_ports[@]}"
}

# Add hosts entries for local development
add_hosts_entries() {
    local hosts_file="/etc/hosts"
    local entries=(
        "127.0.0.1 pwa.dice.local"
        "127.0.0.1 api.dice.local"
        "127.0.0.1 cms.dice.local"
        "127.0.0.1 traefik.dice.local"
        "127.0.0.1 monitoring.dice.local"
        "127.0.0.1 temporal.dice.local"
    )
    
    print_step "Checking /etc/hosts entries..."
    
    local missing_entries=()
    
    for entry in "${entries[@]}"; do
        if ! grep -q "$entry" "$hosts_file" 2>/dev/null; then
            missing_entries+=("$entry")
        fi
    done
    
    if [[ ${#missing_entries[@]} -gt 0 ]]; then
        print_warning "Missing /etc/hosts entries:"
        for entry in "${missing_entries[@]}"; do
            echo "  $entry"
        done
        print_info "Add manually or run: echo 'ENTRY' | sudo tee -a $hosts_file"
        return 1
    else
        print_check "All hosts entries are present"
        return 0
    fi
}

# Get current user information
get_user_info() {
    export CURRENT_UID=$(id -u)
    export CURRENT_GID=$(id -g)
    print_info "Current user: UID=${CURRENT_UID}, GID=${CURRENT_GID}"
}

# Wait for service to be healthy
wait_for_service() {
    local service_name="$1"
    local health_url="$2"
    local timeout="${3:-60}"
    local interval="${4:-2}"
    
    print_step "Waiting for $service_name to be healthy..."
    
    local count=0
    local max_attempts=$((timeout / interval))
    
    while [ $count -lt $max_attempts ]; do
        if curl -f "$health_url" >/dev/null 2>&1; then
            print_check "$service_name is healthy"
            return 0
        fi
        sleep $interval
        count=$((count + 1))
        
        # Show progress every 10 attempts
        if (( count % 10 == 0 )); then
            print_info "Still waiting for $service_name... (${count}/${max_attempts})"
        fi
    done
    
    print_error "$service_name failed to become healthy within ${timeout} seconds"
    return 1
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Get project root directory
get_project_root() {
    cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
}

# Ensure we're in project root
ensure_project_root() {
    local root
    root=$(get_project_root)
    cd "$root"
}

# Show script banner
show_banner() {
    local script_name="$1"
    local description="$2"
    
    echo ""
    echo "🎯 DICE Infrastructure - $script_name"
    echo "📋 $description"
    echo "$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo "=============================================="
    echo ""
}

# Show completion message
show_completion() {
    local script_name="$1"
    
    echo ""
    echo "=============================================="
    print_success "$script_name completed successfully!"
    echo "⏰ Completed at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo ""
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Validate script requirements
validate_requirements() {
    print_step "Validating requirements..."
    
    # Check required commands
    local required_commands=("curl" "docker" "openssl")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        print_error "Missing required commands: ${missing_commands[*]}"
        return 1
    fi
    
    print_check "All requirements satisfied"
    return 0
}

# Source this library in other scripts with:
# source "$(dirname "${BASH_SOURCE[0]}")/common.sh"