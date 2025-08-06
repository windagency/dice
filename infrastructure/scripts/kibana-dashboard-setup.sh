#!/bin/bash

# DICE Kibana Dashboard Setup Script
# Automates the creation of index templates and basic dashboard configurations
# Usage: ./kibana-dashboard-setup.sh [options]

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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Function to show usage
show_usage() {
    echo "DICE Kibana Dashboard Setup"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --setup-templates     Create Elasticsearch index templates"
    echo "  --setup-patterns      Configure Kibana index patterns"
    echo "  --setup-dashboards    Create basic dashboard configurations"
    echo "  --setup-alerts        Configure basic alert rules"
    echo "  --full-setup          Complete setup (templates + patterns + dashboards + alerts)"
    echo "  --health-check        Check ELK stack health"
    echo "  --test-data           Generate test data for dashboards"
    echo "  -h, --help            Show help message"
    echo ""
    echo "Examples:"
    echo "  $0 --full-setup       # Complete dashboard setup"
    echo "  $0 --setup-templates  # Create index templates only"
    echo "  $0 --health-check     # Check ELK stack status"
    echo ""
}

# Function to check ELK stack health
check_elk_health() {
    echo -e "${BLUE}Checking ELK stack health...${NC}"
    
    # Check Elasticsearch
    if curl -s "http://${ELASTICSEARCH_HOST}/_cluster/health" > /dev/null; then
        echo -e "${GREEN}✅ Elasticsearch is running${NC}"
    else
        echo -e "${RED}❌ Elasticsearch is not accessible${NC}"
        return 1
    fi
    
    # Check Kibana
    if curl -s "http://${KIBANA_HOST}/api/status" > /dev/null; then
        echo -e "${GREEN}✅ Kibana is running${NC}"
    else
        echo -e "${RED}❌ Kibana is not accessible${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ ELK stack is healthy${NC}"
}

# Function to create index templates
setup_index_templates() {
    echo -e "${BLUE}Creating Elasticsearch index templates...${NC}"
    
    # Security events template
    echo -e "${CYAN}Creating security events template...${NC}"
    curl -X PUT "http://${ELASTICSEARCH_HOST}/_index_template/dice-security-template" \
        -H 'Content-Type: application/json' \
        -d '{
            "index_patterns": ["dice-security-*"],
            "template": {
                "mappings": {
                    "properties": {
                        "owaspCategory": {"type": "keyword"},
                        "securityEvent": {"type": "object"},
                        "ip": {"type": "ip"},
                        "userId": {"type": "keyword"},
                        "correlationId": {"type": "keyword"},
                        "sessionId": {"type": "keyword"},
                        "component": {"type": "keyword"},
                        "action": {"type": "keyword"},
                        "level": {"type": "keyword"},
                        "service": {"type": "keyword"},
                        "timestamp": {"type": "date"},
                        "message": {"type": "text"},
                        "metadata": {"type": "object"},
                        "tags": {"type": "keyword"}
                    }
                },
                "settings": {
                    "number_of_shards": 1,
                    "number_of_replicas": 1
                }
            }
        }' || echo -e "${YELLOW}⚠️  Security template creation failed (may already exist)${NC}"
    
    # Performance metrics template
    echo -e "${CYAN}Creating performance metrics template...${NC}"
    curl -X PUT "http://${ELASTICSEARCH_HOST}/_index_template/dice-performance-template" \
        -H 'Content-Type: application/json' \
        -d '{
            "index_patterns": ["dice-performance-*"],
            "template": {
                "mappings": {
                    "properties": {
                        "duration": {"type": "long"},
                        "statusCode": {"type": "integer"},
                        "endpoint": {"type": "keyword"},
                        "method": {"type": "keyword"},
                        "correlationId": {"type": "keyword"},
                        "component": {"type": "keyword"},
                        "action": {"type": "keyword"},
                        "level": {"type": "keyword"},
                        "service": {"type": "keyword"},
                        "timestamp": {"type": "date"},
                        "message": {"type": "text"},
                        "metadata": {"type": "object"},
                        "tags": {"type": "keyword"}
                    }
                },
                "settings": {
                    "number_of_shards": 1,
                    "number_of_replicas": 1
                }
            }
        }' || echo -e "${YELLOW}⚠️  Performance template creation failed (may already exist)${NC}"
    
    # Health monitoring template
    echo -e "${CYAN}Creating health monitoring template...${NC}"
    curl -X PUT "http://${ELASTICSEARCH_HOST}/_index_template/dice-health-template" \
        -H 'Content-Type: application/json' \
        -d '{
            "index_patterns": ["dice-health-*"],
            "template": {
                "mappings": {
                    "properties": {
                        "service": {"type": "keyword"},
                        "status": {"type": "keyword"},
                        "healthScore": {"type": "float"},
                        "resourceUsage": {"type": "object"},
                        "correlationId": {"type": "keyword"},
                        "component": {"type": "keyword"},
                        "action": {"type": "keyword"},
                        "level": {"type": "keyword"},
                        "timestamp": {"type": "date"},
                        "message": {"type": "text"},
                        "metadata": {"type": "object"},
                        "tags": {"type": "keyword"}
                    }
                },
                "settings": {
                    "number_of_shards": 1,
                    "number_of_replicas": 1
                }
            }
        }' || echo -e "${YELLOW}⚠️  Health template creation failed (may already exist)${NC}"
    
    # PWA user activity template
    echo -e "${CYAN}Creating PWA user activity template...${NC}"
    curl -X PUT "http://${ELASTICSEARCH_HOST}/_index_template/dice-pwa-template" \
        -H 'Content-Type: application/json' \
        -d '{
            "index_patterns": ["dice-logs-*"],
            "template": {
                "mappings": {
                    "properties": {
                        "service": {"type": "keyword"},
                        "component": {"type": "keyword"},
                        "action": {"type": "keyword"},
                        "userAgent": {"type": "text"},
                        "sessionId": {"type": "keyword"},
                        "correlationId": {"type": "keyword"},
                        "userId": {"type": "keyword"},
                        "level": {"type": "keyword"},
                        "timestamp": {"type": "date"},
                        "message": {"type": "text"},
                        "metadata": {"type": "object"},
                        "tags": {"type": "keyword"}
                    }
                },
                "settings": {
                    "number_of_shards": 1,
                    "number_of_replicas": 1
                }
            }
        }' || echo -e "${YELLOW}⚠️  PWA template creation failed (may already exist)${NC}"
    
    echo -e "${GREEN}✅ Index templates created successfully${NC}"
}

# Function to setup Kibana index patterns
setup_index_patterns() {
    echo -e "${BLUE}Setting up Kibana index patterns...${NC}"
    
    # Create index patterns via Kibana API
    echo -e "${CYAN}Creating index patterns...${NC}"
    
    # Security index pattern
    curl -X POST "http://${KIBANA_HOST}/api/saved_objects/index-pattern/dice-security" \
        -H 'Content-Type: application/json' \
        -H 'kbn-xsrf: true' \
        -d '{
            "attributes": {
                "title": "dice-security-*",
                "timeFieldName": "timestamp"
            }
        }' || echo -e "${YELLOW}⚠️  Security index pattern creation failed (may already exist)${NC}"
    
    # Performance index pattern
    curl -X POST "http://${KIBANA_HOST}/api/saved_objects/index-pattern/dice-performance" \
        -H 'Content-Type: application/json' \
        -H 'kbn-xsrf: true' \
        -d '{
            "attributes": {
                "title": "dice-performance-*",
                "timeFieldName": "timestamp"
            }
        }' || echo -e "${YELLOW}⚠️  Performance index pattern creation failed (may already exist)${NC}"
    
    # Health index pattern
    curl -X POST "http://${KIBANA_HOST}/api/saved_objects/index-pattern/dice-health" \
        -H 'Content-Type: application/json' \
        -H 'kbn-xsrf: true' \
        -d '{
            "attributes": {
                "title": "dice-health-*",
                "timeFieldName": "timestamp"
            }
        }' || echo -e "${YELLOW}⚠️  Health index pattern creation failed (may already exist)${NC}"
    
    # General logs index pattern
    curl -X POST "http://${KIBANA_HOST}/api/saved_objects/index-pattern/dice-logs" \
        -H 'Content-Type: application/json' \
        -H 'kbn-xsrf: true' \
        -d '{
            "attributes": {
                "title": "dice-logs-*",
                "timeFieldName": "timestamp"
            }
        }' || echo -e "${YELLOW}⚠️  General logs index pattern creation failed (may already exist)${NC}"
    
    echo -e "${GREEN}✅ Index patterns created successfully${NC}"
}

# Function to generate test data
generate_test_data() {
    echo -e "${BLUE}Generating test data for dashboards...${NC}"
    
    # Generate security test data
    echo -e "${CYAN}Generating security test data...${NC}"
    for i in {1..10}; do
        curl -X POST "http://${ELASTICSEARCH_HOST}/dice-security-$(date +%Y.%m.%d)/_doc" \
            -H 'Content-Type: application/json' \
            -d "{
                \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\",
                \"level\": \"warn\",
                \"service\": \"backend-api\",
                \"correlationId\": \"test-correlation-${i}\",
                \"sessionId\": \"test-session-${i}\",
                \"userId\": \"test-user-${i}\",
                \"component\": \"SecurityInterceptor\",
                \"action\": \"authentication.failure\",
                \"message\": \"Failed login attempt\",
                \"metadata\": {
                    \"ip\": \"192.168.1.${i}\",
                    \"userAgent\": \"Mozilla/5.0 (Test Browser)\",
                    \"attemptCount\": ${i},
                    \"reason\": \"invalid_credentials\"
                },
                \"tags\": [\"security\", \"authentication\", \"failure\"],
                \"securityEvent\": {
                    \"type\": \"authentication_failure\",
                    \"severity\": \"medium\",
                    \"source\": \"login_endpoint\"
                },
                \"owaspCategory\": \"A07\"
            }"
    done
    
    # Generate performance test data
    echo -e "${CYAN}Generating performance test data...${NC}"
    for i in {1..20}; do
        curl -X POST "http://${ELASTICSEARCH_HOST}/dice-performance-$(date +%Y.%m.%d)/_doc" \
            -H 'Content-Type: application/json' \
            -d "{
                \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\",
                \"level\": \"info\",
                \"service\": \"backend-api\",
                \"correlationId\": \"test-correlation-${i}\",
                \"component\": \"AuthController\",
                \"action\": \"login\",
                \"message\": \"API request completed\",
                \"metadata\": {
                    \"duration\": $((500 + i * 50)),
                    \"statusCode\": 200,
                    \"endpoint\": \"/api/auth/login\",
                    \"method\": \"POST\",
                    \"requestSize\": 1024,
                    \"responseSize\": 2048
                },
                \"tags\": [\"performance\", \"api\", \"auth\"]
            }"
    done
    
    # Generate PWA test data
    echo -e "${CYAN}Generating PWA test data...${NC}"
    for i in {1..15}; do
        curl -X POST "http://${ELASTICSEARCH_HOST}/dice-logs-$(date +%Y.%m.%d)/_doc" \
            -H 'Content-Type: application/json' \
            -d "{
                \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\",
                \"level\": \"info\",
                \"service\": \"pwa-frontend\",
                \"correlationId\": \"test-correlation-${i}\",
                \"sessionId\": \"test-session-${i}\",
                \"userId\": \"anonymous\",
                \"component\": \"UserInteraction\",
                \"action\": \"handleClick\",
                \"message\": \"User clicked on button\",
                \"metadata\": {
                    \"element\": {
                        \"tagName\": \"BUTTON\",
                        \"id\": \"login-button\",
                        \"className\": \"btn-primary\"
                    },
                    \"position\": {
                        \"x\": $((100 + i * 10)),
                        \"y\": $((200 + i * 10))
                    }
                },
                \"tags\": [\"pwa\", \"interaction\", \"click\"]
            }"
    done
    
    echo -e "${GREEN}✅ Test data generated successfully${NC}"
}

# Function to setup basic dashboard configurations
setup_dashboards() {
    echo -e "${BLUE}Setting up basic dashboard configurations...${NC}"
    echo -e "${YELLOW}⚠️  Dashboard creation requires manual configuration in Kibana UI${NC}"
    echo -e "${CYAN}Please visit http://${KIBANA_HOST} to create dashboards:${NC}"
    echo -e "${CYAN}1. Security Monitoring Dashboard${NC}"
    echo -e "${CYAN}2. API Performance Dashboard${NC}"
    echo -e "${CYAN}3. Service Health Dashboard${NC}"
    echo -e "${CYAN}4. User Activity Dashboard${NC}"
    echo -e "${CYAN}5. Operational Overview Dashboard${NC}"
    echo ""
    echo -e "${CYAN}Reference the KIBANA_DASHBOARDS_PLAN.md for detailed specifications${NC}"
}

# Function to setup basic alerts
setup_alerts() {
    echo -e "${BLUE}Setting up basic alert configurations...${NC}"
    echo -e "${YELLOW}⚠️  Alert configuration requires manual setup in Kibana${NC}"
    echo -e "${CYAN}Please configure alerts in Kibana Alerting:${NC}"
    echo -e "${CYAN}1. Authentication failure rate alerts${NC}"
    echo -e "${CYAN}2. High response time alerts${NC}"
    echo -e "${CYAN}3. Error rate threshold alerts${NC}"
    echo -e "${CYAN}4. Service health degradation alerts${NC}"
    echo ""
    echo -e "${CYAN}Reference the KIBANA_DASHBOARDS_PLAN.md for alert specifications${NC}"
}

# Function to perform full setup
full_setup() {
    echo -e "${MAGENTA}🚀 Starting complete Kibana dashboard setup...${NC}"
    
    # Check ELK health first
    check_elk_health || {
        echo -e "${RED}❌ ELK stack is not healthy. Please start the ELK stack first.${NC}"
        echo -e "${CYAN}Run: ./infrastructure/scripts/logging-setup.sh start${NC}"
        exit 1
    }
    
    # Setup index templates
    setup_index_templates
    
    # Setup index patterns
    setup_index_patterns
    
    # Generate test data
    generate_test_data
    
    # Setup dashboards and alerts
    setup_dashboards
    setup_alerts
    
    echo -e "${GREEN}✅ Complete setup finished!${NC}"
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "${CYAN}1. Visit http://${KIBANA_HOST} to access Kibana${NC}"
    echo -e "${CYAN}2. Create dashboards using the index patterns${NC}"
    echo -e "${CYAN}3. Configure alerts for monitoring${NC}"
    echo -e "${CYAN}4. Review KIBANA_DASHBOARDS_PLAN.md for detailed specifications${NC}"
}

# Main function
main() {
    local command="${1:-help}"
    
    case $command in
        --setup-templates)
            check_elk_health && setup_index_templates
            ;;
        --setup-patterns)
            check_elk_health && setup_index_patterns
            ;;
        --setup-dashboards)
            setup_dashboards
            ;;
        --setup-alerts)
            setup_alerts
            ;;
        --full-setup)
            full_setup
            ;;
        --health-check)
            check_elk_health
            ;;
        --test-data)
            check_elk_health && generate_test_data
            ;;
        help|--help|-h)
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
