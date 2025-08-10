#!/bin/bash
# DICE Environment Setup Script (Unified)
# Consolidates environment setup for development, DevContainer, and production

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# =============================================================================
# CONFIGURATION
# =============================================================================

# Default values
DEFAULT_ENV_TYPE="development"
DEFAULT_CHECK_PORTS="true"
DEFAULT_CHECK_HOSTS="true"
DEFAULT_CREATE_DIRS="true"

# =============================================================================
# USAGE FUNCTIONS
# =============================================================================

show_usage() {
    cat << EOF
DICE Environment Setup (Unified)

Usage: $0 [OPTIONS]

Options:
  -t, --type TYPE         Environment type: 'development', 'devcontainer', 'production' (default: development)
  -f, --file FILE         Environment file path (auto-generated if not specified)
  --skip-ports           Skip port availability check
  --skip-hosts           Skip hosts file check
  --skip-dirs            Skip directory creation
  --force                Overwrite existing environment file
  -h, --help             Show this help message

Environment Types:
  development            Standard development environment (unified .env)
  devcontainer           DevContainer environment (unified .env)
  production             Production environment (.env.production)

Examples:
  $0                                    # Development environment
  $0 --type devcontainer                # DevContainer environment
  $0 --type development --skip-ports    # Skip port checks
  $0 --file .env.custom                 # Custom environment file

EOF
}

# =============================================================================
# ENVIRONMENT TYPE FUNCTIONS
# =============================================================================

# Get default environment file path based on type
get_default_env_file() {
    local env_type="$1"
    
    # All environment types now use the unified .env file
    # Environment-specific configuration is handled via sections within the file
    case "$env_type" in
        "development"|"devcontainer")
            echo ".env"
            ;;
        "production")
            echo ".env.production"  # Production still uses separate file for security
            ;;
        *)
            print_error "Unknown environment type: $env_type"
            return 1
            ;;
    esac
}

# Create environment-specific configuration
create_env_config() {
    local env_file="$1"
    local env_type="$2"
    
    print_step "Creating $env_type environment configuration..."
    
    # Generate secrets
    local postgres_password
    local jwt_secret
    local backend_api_key
    local internal_jwt_secret
    
    postgres_password=$(generate_password)
    jwt_secret=$(generate_jwt_secret)
    backend_api_key="dice_backend_api_$(generate_secret 16)"
    internal_jwt_secret="dice_internal_jwt_$(generate_secret 16)"
    
    # Get current user info for DevContainer
    local current_uid current_gid
    if [[ "$env_type" == "devcontainer" ]]; then
        current_uid=$(id -u)
        current_gid=$(id -g)
    fi
    
    # Create environment file
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
BACKEND_API_KEY=$backend_api_key
INTERNAL_JWT_SECRET=$internal_jwt_secret

# Development Settings
NODE_ENV=$env_type
LOG_LEVEL=${LOG_LEVEL:-debug}
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

EOF

    # Add DevContainer-specific configuration
    if [[ "$env_type" == "devcontainer" ]]; then
        cat >> "$env_file" << EOF
# DevContainer Configuration
DOCKER_USER=$current_uid
DOCKER_GROUP=$current_gid
COMPOSE_PROFILES=devcontainer

EOF
    fi
    
    # Add development-specific configuration
    if [[ "$env_type" == "development" ]]; then
        cat >> "$env_file" << EOF
# Development-Specific Settings
HOT_RELOAD=true
DEBUG_MODE=true

EOF
    fi
    
    # Add production-specific configuration
    if [[ "$env_type" == "production" ]]; then
        cat >> "$env_file" << EOF
# Production Settings
NODE_ENV=production
LOG_LEVEL=info
DEBUG_MODE=false
HOT_RELOAD=false

EOF
    fi
    
    # Add common optional service configuration
    cat >> "$env_file" << EOF
# Optional Service Configuration
TRAEFIK_API_DASHBOARD=${TRAEFIK_API_DASHBOARD:-true}
TRAEFIK_LOG_LEVEL=${TRAEFIK_LOG_LEVEL:-INFO}
PROMETHEUS_ENABLED=${PROMETHEUS_ENABLED:-false}
GRAFANA_ENABLED=${GRAFANA_ENABLED:-false}
VAULT_ENABLED=${VAULT_ENABLED:-false}
SECURITY_SCANNING=${SECURITY_SCANNING:-false}
EOF
    
    print_check "Environment file created: $env_file"
    print_warning "Keep this file secure - it contains sensitive secrets"
    print_info "Environment type: $env_type"
    
    return 0
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Check if environment file should be created
should_create_env_file() {
    local env_file="$1"
    local force="$2"
    
    if [[ -f "$env_file" ]] && [[ "$force" != "true" ]]; then
        print_warning "Environment file already exists: $env_file"
        print_info "Use --force to overwrite, or choose a different file path"
        return 1
    fi
    
    return 0
}

# Validate environment type
validate_env_type() {
    local env_type="$1"
    local valid_types=("development" "devcontainer" "production")
    
    for valid_type in "${valid_types[@]}"; do
        if [[ "$env_type" == "$valid_type" ]]; then
            return 0
        fi
    done
    
    print_error "Invalid environment type: $env_type"
    print_info "Valid types: ${valid_types[*]}"
    return 1
}

# =============================================================================
# SETUP FUNCTIONS
# =============================================================================

# Perform full environment setup
perform_full_setup() {
    local env_type="$1"
    local check_ports="$2"
    local check_hosts="$3"
    local create_dirs="$4"
    
    print_step "Performing full environment setup for: $env_type"
    
    # Validate requirements
    validate_requirements || return 1
    
    # Create directories if requested
    if [[ "$create_dirs" == "true" ]]; then
        create_dice_directories
    fi
    
    # Set permissions
    set_dice_permissions
    
    # Validate Docker if not production
    if [[ "$env_type" != "production" ]]; then
        validate_docker_installation || print_warning "Docker validation failed - continuing anyway"
        check_dice_compose_files || print_warning "Compose file validation failed - continuing anyway"
    fi
    
    # Check port availability if requested
    if [[ "$check_ports" == "true" ]] && [[ "$env_type" != "production" ]]; then
        check_dice_ports || print_warning "Some ports are in use - may cause conflicts"
    fi
    
    # Check hosts entries if requested
    if [[ "$check_hosts" == "true" ]] && [[ "$env_type" == "development" ]]; then
        add_hosts_entries || print_warning "Some hosts entries are missing - may affect local development"
    fi
    
    print_check "Full environment setup completed"
}

# =============================================================================
# INFORMATION FUNCTIONS
# =============================================================================

# Show setup summary
show_setup_summary() {
    local env_file="$1"
    local env_type="$2"
    
    print_step "Setup Summary:"
    cat << EOF
  📁 Environment File: $env_file
  🏷️  Environment Type: $env_type
  🔐 Secrets Generated: POSTGRES_PASSWORD, JWT_SECRET, API_KEYS
  📋 Configuration: Database, Redis, Temporal, LocalStack ready
  
EOF
    
    case "$env_type" in
        "development")
            cat << EOF
  🚀 Next Steps:
    1. Review environment file: $env_file
    2. Add missing /etc/hosts entries if any
    3. Start services: ./infrastructure/scripts/docker-orchestrator.sh full-stack
    4. Verify setup: ./infrastructure/scripts/health-check.sh
EOF
            ;;
        "devcontainer")
            cat << EOF
  🚀 Next Steps:
    1. Open project in VS Code
    2. Install Dev Containers extension
    3. Use 'Dev Containers: Reopen in Container' command
    4. Wait for environment to build and start
EOF
            ;;
        "production")
            cat << EOF
  🚀 Next Steps:
    1. Review and secure environment file: $env_file
    2. Configure production-specific settings
    3. Set up proper secret management
    4. Deploy using production Docker Compose files
EOF
            ;;
    esac
}

# Show environment information
show_env_info() {
    local env_file="$1"
    
    if [[ -f "$env_file" ]]; then
        print_step "Environment File Information:"
        print_info "File: $env_file"
        print_info "Size: $(du -h "$env_file" | cut -f1)"
        print_info "Created: $(stat -f '%Sm' "$env_file" 2>/dev/null || stat -c '%y' "$env_file" 2>/dev/null || echo 'Unknown')"
        
        print_step "Environment Variables:"
        local var_count
        var_count=$(grep -c '^[A-Z]' "$env_file" 2>/dev/null || echo "0")
        print_info "Variables defined: $var_count"
        
        print_step "Categories:"
        local categories=("DATABASE" "REDIS" "JWT" "LOCALSTACK" "TRAEFIK")
        for category in "${categories[@]}"; do
            local count
            count=$(grep -c "^${category}" "$env_file" 2>/dev/null || echo "0")
            if [[ "$count" -gt 0 ]]; then
                print_info "$category: $count variables"
            fi
        done
    else
        print_warning "Environment file does not exist: $env_file"
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Parse command line arguments
parse_arguments() {
    ENV_TYPE="$DEFAULT_ENV_TYPE"
    ENV_FILE=""
    CHECK_PORTS="$DEFAULT_CHECK_PORTS"
    CHECK_HOSTS="$DEFAULT_CHECK_HOSTS"
    CREATE_DIRS="$DEFAULT_CREATE_DIRS"
    FORCE_CREATE="false"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type)
                ENV_TYPE="$2"
                shift 2
                ;;
            -f|--file)
                ENV_FILE="$2"
                shift 2
                ;;
            --skip-ports)
                CHECK_PORTS="false"
                shift
                ;;
            --skip-hosts)
                CHECK_HOSTS="false"
                shift
                ;;
            --skip-dirs)
                CREATE_DIRS="false"
                shift
                ;;
            --force)
                FORCE_CREATE="true"
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
    
    # Validate environment type
    validate_env_type "$ENV_TYPE" || exit 1
    
    # Set default environment file if not specified
    if [[ -z "$ENV_FILE" ]]; then
        ENV_FILE=$(get_default_env_file "$ENV_TYPE")
    fi
}

# Main execution function
main() {
    show_banner "Environment Setup" "Unified environment configuration for DICE project"
    
    # Parse arguments
    parse_arguments "$@"
    
    # Ensure we're in project root
    ensure_project_root
    
    print_info "Environment Type: $ENV_TYPE"
    print_info "Environment File: $ENV_FILE"
    print_info "Check Ports: $CHECK_PORTS"
    print_info "Check Hosts: $CHECK_HOSTS"
    print_info "Create Directories: $CREATE_DIRS"
    echo ""
    
    # Special handling for unified .env approach
    if [[ "$ENV_FILE" == ".env" ]] && [[ -f ".env" ]] && [[ "$FORCE_CREATE" != "true" ]]; then
        print_check "Unified .env file already exists - respecting existing configuration"
        print_step "Showing existing environment information:"
        show_env_info "$ENV_FILE"
        echo ""
        print_info "Unified environment approach: development and devcontainer use the same .env file"
        print_info "Use --force to regenerate with new secrets (not recommended for active development)"
        exit 0
    fi
    
    # Check if we should create the environment file
    if ! should_create_env_file "$ENV_FILE" "$FORCE_CREATE"; then
        print_step "Showing existing environment information instead:"
        show_env_info "$ENV_FILE"
        echo ""
        print_info "Use --force to overwrite or specify a different file with --file"
        exit 0
    fi
    
    # Create directory for environment file if needed
    local env_dir
    env_dir=$(dirname "$ENV_FILE")
    if [[ "$env_dir" != "." ]] && [[ ! -d "$env_dir" ]]; then
        mkdir -p "$env_dir"
        print_check "Created directory: $env_dir"
    fi
    
    # Create environment configuration
    create_env_config "$ENV_FILE" "$ENV_TYPE"
    
    # Perform full setup
    perform_full_setup "$ENV_TYPE" "$CHECK_PORTS" "$CHECK_HOSTS" "$CREATE_DIRS"
    
    echo ""
    show_setup_summary "$ENV_FILE" "$ENV_TYPE"
    
    show_completion "Environment Setup"
    
    # Show important security reminders
    print_warning "Security Reminders:"
    print_warning "- Never commit $ENV_FILE to version control"
    print_warning "- Keep generated secrets secure"
    print_warning "- Review configuration before production use"
}

# Run main function
main "$@"