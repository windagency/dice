#!/bin/bash
# DICE LocalStack Development Data Setup (Consolidated)
# Unified script supporting both host and containerized AWS CLI execution

# Load common functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# =============================================================================
# CONFIGURATION
# =============================================================================

# Default configuration
DEFAULT_METHOD="container"
DEFAULT_REGION="eu-west-3"
LOCALSTACK_ENDPOINT="http://localhost:4566"
LOCALSTACK_HEALTH_ENDPOINT="http://localhost:4566/_localstack/health"

# LocalStack credentials (standard development values - safe for local development)
export AWS_ACCESS_KEY_ID="${LOCALSTACK_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${LOCALSTACK_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-$DEFAULT_REGION}"

# =============================================================================
# USAGE FUNCTIONS
# =============================================================================

show_usage() {
    cat << EOF
DICE LocalStack Development Data Setup

Usage: $0 [OPTIONS]

Options:
  -m, --method METHOD     Execution method: 'host' or 'container' (default: container)
  -r, --region REGION     AWS region (default: eu-west-3)
  -e, --endpoint URL      LocalStack endpoint (default: http://localhost:4566)
  -h, --help             Show this help message

Execution Methods:
  host                   Use host AWS CLI (requires aws-cli installed)
  container              Use containerized AWS CLI (recommended)

Examples:
  $0                                    # Use container method (default)
  $0 --method host                      # Use host AWS CLI
  $0 --method container --region us-east-1  # Custom region with container

Requirements:
  - LocalStack running on port 4566
  - Docker (for container method)
  - AWS CLI (for host method)

EOF
}

# =============================================================================
# AWS CLI EXECUTION FUNCTIONS
# =============================================================================

# Execute AWS CLI command based on selected method
aws_exec() {
    case "$EXECUTION_METHOD" in
        "host")
            aws --endpoint-url="$LOCALSTACK_ENDPOINT" "$@"
            ;;
        "container")
            docker compose run --rm awscli awslocal "$@"
            ;;
        *)
            print_error "Invalid execution method: $EXECUTION_METHOD"
            return 1
            ;;
    esac
}

# Execute shell command for file operations (container method)
shell_exec() {
    case "$EXECUTION_METHOD" in
        "host")
            eval "$@"
            ;;
        "container")
            docker compose run --rm awscli sh -c "$*"
            ;;
    esac
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Check if LocalStack is running
check_localstack_status() {
    print_step "Checking LocalStack status..."
    
    case "$EXECUTION_METHOD" in
        "host")
            if ! curl -s "$LOCALSTACK_HEALTH_ENDPOINT" > /dev/null; then
                print_error "LocalStack is not running"
                print_info "Please start it first: docker compose up localstack -d"
                return 1
            fi
            ;;
        "container")
            if ! docker compose exec localstack curl -s localhost:4566/_localstack/health > /dev/null 2>&1; then
                print_error "LocalStack is not running"
                print_info "Please start it first: docker compose up localstack -d"
                return 1
            fi
            ;;
    esac
    
    print_check "LocalStack is running and healthy"
    return 0
}

# Validate execution method requirements
validate_method_requirements() {
    case "$EXECUTION_METHOD" in
        "host")
            if ! command -v aws >/dev/null 2>&1; then
                print_error "AWS CLI is not installed"
                print_info "Install AWS CLI or use --method container"
                return 1
            fi
            print_check "Host AWS CLI available"
            ;;
        "container")
            if ! command -v docker >/dev/null 2>&1; then
                print_error "Docker is not available"
                print_info "Install Docker or use --method host"
                return 1
            fi
            print_check "Docker available for containerized execution"
            ;;
    esac
    return 0
}

# =============================================================================
# DATA SETUP FUNCTIONS
# =============================================================================

# Create S3 buckets
create_s3_buckets() {
    print_step "Creating S3 buckets..."
    
    local buckets=(
        "dice-character-portraits"
        "dice-campaign-maps"
        "dice-rule-documents"
        "dice-user-uploads"
    )
    
    for bucket in "${buckets[@]}"; do
        if aws_exec s3 mb "s3://$bucket" 2>/dev/null; then
            print_check "Created bucket: $bucket"
        else
            print_info "Bucket may already exist: $bucket"
        fi
    done
}

# Create DynamoDB tables
create_dynamodb_tables() {
    print_step "Creating DynamoDB tables..."
    
    # Characters table
    print_info "Creating DiceCharacters table..."
    if aws_exec dynamodb create-table \
        --table-name DiceCharacters \
        --attribute-definitions \
            AttributeName=UserId,AttributeType=S \
            AttributeName=CharacterId,AttributeType=S \
        --key-schema \
            AttributeName=UserId,KeyType=HASH \
            AttributeName=CharacterId,KeyType=RANGE \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 > /dev/null 2>&1; then
        print_check "Created DiceCharacters table"
    else
        print_info "DiceCharacters table may already exist"
    fi
    
    # Campaigns table
    print_info "Creating DiceCampaigns table..."
    if aws_exec dynamodb create-table \
        --table-name DiceCampaigns \
        --attribute-definitions \
            AttributeName=CampaignId,AttributeType=S \
        --key-schema \
            AttributeName=CampaignId,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 > /dev/null 2>&1; then
        print_check "Created DiceCampaigns table"
    else
        print_info "DiceCampaigns table may already exist"
    fi
    
    # Users table
    print_info "Creating DiceUsers table..."
    if aws_exec dynamodb create-table \
        --table-name DiceUsers \
        --attribute-definitions \
            AttributeName=UserId,AttributeType=S \
        --key-schema \
            AttributeName=UserId,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 > /dev/null 2>&1; then
        print_check "Created DiceUsers table"
    else
        print_info "DiceUsers table may already exist"
    fi
}

# Add sample data
add_sample_data() {
    print_step "Adding sample data..."
    
    # Sample users
    print_info "Adding sample users..."
    
    aws_exec dynamodb put-item \
        --table-name DiceUsers \
        --item '{
            "UserId": {"S": "user-dm-001"},
            "Username": {"S": "dungeon_master"},
            "Email": {"S": "dm@dice.local"},
            "Role": {"S": "DM"},
            "CreatedAt": {"S": "2025-07-28T22:00:00Z"}
        }' > /dev/null 2>&1 || print_info "Sample user data may already exist"
    
    aws_exec dynamodb put-item \
        --table-name DiceUsers \
        --item '{
            "UserId": {"S": "user-player-001"},
            "Username": {"S": "aragorn_player"},
            "Email": {"S": "player1@dice.local"},
            "Role": {"S": "Player"},
            "CreatedAt": {"S": "2025-07-28T22:00:00Z"}
        }' > /dev/null 2>&1 || print_info "Sample user data may already exist"
    
    # Sample characters
    print_info "Adding sample characters..."
    
    aws_exec dynamodb put-item \
        --table-name DiceCharacters \
        --item '{
            "UserId": {"S": "user-player-001"},
            "CharacterId": {"S": "char-gandalf"},
            "Name": {"S": "Gandalf the Grey"},
            "Class": {"S": "Wizard"},
            "Level": {"N": "10"},
            "Race": {"S": "Maia"},
            "HitPoints": {"N": "84"},
            "ArmorClass": {"N": "15"},
            "Stats": {
                "M": {
                    "Strength": {"N": "12"},
                    "Dexterity": {"N": "14"},
                    "Constitution": {"N": "16"},
                    "Intelligence": {"N": "20"},
                    "Wisdom": {"N": "18"},
                    "Charisma": {"N": "16"}
                }
            },
            "Equipment": {"L": [
                {"S": "Staff of Power"},
                {"S": "Glamdring"},
                {"S": "Narya (Ring of Fire)"}
            ]},
            "CreatedAt": {"S": "2025-07-28T22:00:00Z"}
        }' > /dev/null 2>&1 || print_info "Sample character data may already exist"
    
    aws_exec dynamodb put-item \
        --table-name DiceCharacters \
        --item '{
            "UserId": {"S": "user-player-001"},
            "CharacterId": {"S": "char-aragorn"},
            "Name": {"S": "Aragorn"},
            "Class": {"S": "Ranger"},
            "Level": {"N": "15"},
            "Race": {"S": "Human"},
            "HitPoints": {"N": "142"},
            "ArmorClass": {"N": "18"},
            "Stats": {
                "M": {
                    "Strength": {"N": "18"},
                    "Dexterity": {"N": "16"},
                    "Constitution": {"N": "16"},
                    "Intelligence": {"N": "14"},
                    "Wisdom": {"N": "15"},
                    "Charisma": {"N": "18"}
                }
            },
            "Equipment": {"L": [
                {"S": "Andúril"},
                {"S": "Bow of the Galadhrim"},
                {"S": "Elessar"}
            ]},
            "CreatedAt": {"S": "2025-07-28T22:00:00Z"}
        }' > /dev/null 2>&1 || print_info "Sample character data may already exist"
    
    # Sample campaigns
    print_info "Adding sample campaigns..."
    
    aws_exec dynamodb put-item \
        --table-name DiceCampaigns \
        --item '{
            "CampaignId": {"S": "campaign-lotr"},
            "Name": {"S": "The Lord of the Rings"},
            "Description": {"S": "Epic quest to destroy the One Ring"},
            "DungeonMaster": {"S": "user-dm-001"},
            "Players": {"L": [
                {"S": "user-player-001"}
            ]},
            "Status": {"S": "Active"},
            "SessionCount": {"N": "12"},
            "CreatedAt": {"S": "2025-07-28T20:00:00Z"},
            "LastPlayed": {"S": "2025-07-28T22:00:00Z"}
        }' > /dev/null 2>&1 || print_info "Sample campaign data may already exist"
    
    print_check "Sample data added"
}

# Upload sample assets
upload_sample_assets() {
    print_step "Uploading sample assets..."
    
    # Asset data and S3 paths
    local assets=(
        "Gandalf character portrait placeholder:s3://dice-character-portraits/gandalf.jpg"
        "Aragorn character portrait placeholder:s3://dice-character-portraits/aragorn.jpg"
        "Middle Earth campaign map placeholder:s3://dice-campaign-maps/middle-earth.jpg"
        "D&D 5e Player Handbook placeholder:s3://dice-rule-documents/players-handbook.pdf"
    )
    
    for asset in "${assets[@]}"; do
        local content="${asset%%:*}"
        local s3_path="${asset##*:}"
        local filename="${s3_path##*/}"
        
        case "$EXECUTION_METHOD" in
            "host")
                echo "$content" | aws_exec s3 cp - "$s3_path"
                ;;
            "container")
                shell_exec "echo '$content' | awslocal s3 cp - '$s3_path'"
                ;;
        esac
        
        print_check "Uploaded: $filename"
    done
}

# =============================================================================
# VERIFICATION FUNCTIONS
# =============================================================================

# Show verification commands
show_verification_commands() {
    print_step "Verification commands:"
    
    case "$EXECUTION_METHOD" in
        "host")
            cat << EOF
  S3 Buckets:
    aws --endpoint-url=$LOCALSTACK_ENDPOINT s3 ls
  
  DynamoDB Tables:
    aws --endpoint-url=$LOCALSTACK_ENDPOINT dynamodb list-tables
  
  Character Data:
    aws --endpoint-url=$LOCALSTACK_ENDPOINT dynamodb scan --table-name DiceCharacters
EOF
            ;;
        "container")
            cat << EOF
  S3 Buckets:
    docker compose run --rm awscli awslocal s3 ls
  
  DynamoDB Tables:
    docker compose run --rm awscli awslocal dynamodb list-tables
  
  Character Data:
    docker compose run --rm awscli awslocal dynamodb scan --table-name DiceCharacters
EOF
            ;;
    esac
    
    print_info "LocalStack Health: $LOCALSTACK_HEALTH_ENDPOINT"
}

# Display setup summary
show_setup_summary() {
    print_step "Setup Summary:"
    cat << EOF
  🪣 S3 Buckets: 4 created
  🗄️  DynamoDB Tables: 3 created
  👤 Sample Users: 2 added
  🧙 Sample Characters: 2 added
  🎯 Sample Campaigns: 1 added
  📁 Sample Assets: 4 uploaded
  
  📋 Execution Method: $EXECUTION_METHOD
  🌐 LocalStack Endpoint: $LOCALSTACK_ENDPOINT
  🗺️  AWS Region: $AWS_DEFAULT_REGION
EOF
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Parse command line arguments
parse_arguments() {
    EXECUTION_METHOD="$DEFAULT_METHOD"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--method)
                EXECUTION_METHOD="$2"
                shift 2
                ;;
            -r|--region)
                AWS_DEFAULT_REGION="$2"
                export AWS_DEFAULT_REGION
                shift 2
                ;;
            -e|--endpoint)
                LOCALSTACK_ENDPOINT="$2"
                shift 2
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
    
    # Validate method
    if [[ "$EXECUTION_METHOD" != "host" && "$EXECUTION_METHOD" != "container" ]]; then
        print_error "Invalid method: $EXECUTION_METHOD"
        print_info "Valid methods: host, container"
        exit 1
    fi
}

# Main execution function
main() {
    show_banner "LocalStack Development Data Setup" "Setting up DICE sample data in LocalStack"
    
    # Parse arguments
    parse_arguments "$@"
    
    # Validate requirements
    validate_requirements || exit 1
    validate_method_requirements || exit 1
    
    # Ensure we're in project root
    ensure_project_root
    
    # Check LocalStack status
    check_localstack_status || exit 1
    
    print_info "Using execution method: $EXECUTION_METHOD"
    print_info "LocalStack endpoint: $LOCALSTACK_ENDPOINT"
    print_info "AWS region: $AWS_DEFAULT_REGION"
    echo ""
    
    # Execute setup steps
    create_s3_buckets
    create_dynamodb_tables
    add_sample_data
    upload_sample_assets
    
    echo ""
    show_setup_summary
    echo ""
    show_verification_commands
    
    show_completion "LocalStack Development Data Setup"
    
    if [[ "$EXECUTION_METHOD" == "container" ]]; then
        print_info "💡 Pro Tip: Use 'docker compose run --rm awscli awslocal <command>' for AWS operations!"
    fi
}

# Run main function
main "$@"