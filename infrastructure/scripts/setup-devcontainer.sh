#!/bin/bash
# DevContainer Setup Script (Simplified)
# This script prepares the development environment for DevContainer usage

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# DevContainer-specific setup
setup_devcontainer() {
    show_banner "DevContainer Setup" "Preparing DICE development environment for DevContainer usage"
    
    # Ensure we're in project root
    ensure_project_root
    
    # Get current user information
    get_user_info
    
    # DevContainer uses unified .env file - ensure it exists
    print_step "DevContainer environment check..."
    if [[ -f ".env" ]]; then
        print_check "Unified .env file exists - DevContainer will use this configuration"
    else
        print_step "Creating unified .env for DevContainer and development use..."
        ./infrastructure/scripts/setup-environment.sh --type development --skip-hosts --skip-ports
    fi

    
    # Validate Docker installation and compose files
    print_step "Validating Docker and Compose files..."
    validate_docker_installation || print_warning "Docker validation failed - continuing anyway"
    check_dice_compose_files || print_warning "Compose file validation failed - continuing anyway"
    
    print_step "DevContainer setup completed!"
    
    # Show next steps
    print_step "Next Steps:"
    cat << EOF
  1. Open this project in VS Code
  2. Install the Dev Containers extension if not already installed
  3. Use 'Dev Containers: Reopen in Container' command
  4. Wait for the environment to build and start

🔗 Once started, these services will be available:
  • Backend API: http://localhost:3001
  • PWA Frontend: http://localhost:3000
  • Storybook: http://localhost:6006
  • Temporal UI: http://localhost:8088
  • Traefik Dashboard: http://localhost:8080
EOF
    
    show_completion "DevContainer Setup"
}

# Main execution
main() {
    setup_devcontainer
}

# Run main function
main "$@" 