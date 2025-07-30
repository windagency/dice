#!/bin/bash

# DICE Logging Test Script
# Generates comprehensive test logs to validate the unified logging pipeline

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

show_banner "DICE Logging Pipeline Test" "Generates comprehensive test logs to validate the unified logging pipeline"

# ============================================================================
# CONFIGURATION
# ============================================================================

ELASTICSEARCH_URL="http://localhost:9200"
FLUENT_BIT_URL="http://localhost:24225"
TEST_CORRELATION_ID="test_$(date +%s)_$$"
TEST_SESSION_ID="session_test_$(date +%s)"
TEST_USER_ID="test_user_$(date +%s)"

# ============================================================================
# HEALTH CHECKS
# ============================================================================

print_status "Validating logging infrastructure..."

# Check Elasticsearch
if ! curl -f -s "$ELASTICSEARCH_URL/_cluster/health" > /dev/null; then
    print_error "Elasticsearch is not accessible. Please run './logging-setup.sh' first"
    exit 1
fi

# Check Fluent Bit HTTP endpoint
FLUENT_BIT_AVAILABLE=false
if curl -f -s "$FLUENT_BIT_URL" > /dev/null 2>&1; then
    FLUENT_BIT_AVAILABLE=true
    print_success "Fluent Bit HTTP endpoint is accessible"
else
    print_warning "Fluent Bit HTTP endpoint is not accessible (logs will be sent directly to Elasticsearch)"
fi

print_success "Logging infrastructure is ready for testing"

# ============================================================================
# TEST FUNCTIONS
# ============================================================================

# Function to send log directly to Elasticsearch
send_to_elasticsearch() {
    local index="$1"
    local log_data="$2"
    
    curl -s -X POST "$ELASTICSEARCH_URL/$index/_doc" \
         -H "Content-Type: application/json" \
         -d "$log_data" > /dev/null
}

# Function to send log via Fluent Bit
send_to_fluent_bit() {
    local log_data="$1"
    
    if [[ "$FLUENT_BIT_AVAILABLE" == "true" ]]; then
        curl -s -X POST "$FLUENT_BIT_URL" \
             -H "Content-Type: application/json" \
             -d "$log_data" > /dev/null
        return $?
    else
        return 1
    fi
}

# Function to generate correlation-aware timestamp
generate_timestamp() {
    date -u +%Y-%m-%dT%H:%M:%S.%3NZ
}

# Function to create application log
create_app_log() {
    local level="$1"
    local component="$2"
    local action="$3"
    local message="$4"
    local metadata="$5"
    
    cat << EOF
{
    "@timestamp": "$(generate_timestamp)",
    "timestamp": "$(generate_timestamp)",
    "level": "$level",
    "service": "backend-api",
    "correlationId": "$TEST_CORRELATION_ID",
    "sessionId": "$TEST_SESSION_ID",
    "userId": "$TEST_USER_ID",
    "component": "$component",
    "action": "$action",
    "message": "$message",
    "metadata": $metadata,
    "tags": ["test", "pipeline", "$level"],
    "environment": "development",
    "cluster": "dice-dev"
}
EOF
}

# Function to create security log
create_security_log() {
    local event_type="$1"
    local severity="$2"
    local outcome="$3"
    local risk_score="$4"
    local message="$5"
    
    cat << EOF
{
    "@timestamp": "$(generate_timestamp)",
    "timestamp": "$(generate_timestamp)",
    "level": "warn",
    "service": "backend-api",
    "correlationId": "$TEST_CORRELATION_ID",
    "securityEvent": {
        "type": "$event_type",
        "severity": "$severity",
        "source": "LoggingTestScript",
        "action": "test.security.event",
        "outcome": "$outcome",
        "riskScore": $risk_score,
        "mitigationApplied": ["logging_test"]
    },
    "request": {
        "method": "POST",
        "endpoint": "/test/security/$event_type",
        "ip": "127.0.0.1",
        "userAgent": "DICE-Logging-Test/1.0",
        "sanitizedPayload": {"test": true}
    },
    "owaspCategory": "TEST:2021-Logging_Validation",
    "message": "$message",
    "tags": ["test", "security", "$severity"],
    "environment": "development"
}
EOF
}

# Function to create performance log
create_performance_log() {
    local operation="$1"
    local duration="$2"
    local status_code="$3"
    
    cat << EOF
{
    "@timestamp": "$(generate_timestamp)",
    "timestamp": "$(generate_timestamp)",
    "level": "info",
    "service": "backend-api",
    "correlationId": "$TEST_CORRELATION_ID",
    "sessionId": "$TEST_SESSION_ID",
    "userId": "$TEST_USER_ID",
    "component": "PerformanceTest",
    "action": "performance.test",
    "message": "Performance test for $operation completed",
    "metadata": {
        "operation": "$operation",
        "duration": $duration,
        "statusCode": $status_code,
        "requestSize": 1024,
        "responseSize": 2048,
        "threshold": 1000,
        "slowRequest": $([[ $duration -gt 1000 ]] && echo "true" || echo "false")
    },
    "tags": ["test", "performance", "$operation"],
    "environment": "development"
}
EOF
}

# ============================================================================
# TEST EXECUTION
# ============================================================================

print_status "🧪 **Starting Comprehensive Logging Tests**"
echo "   Test Correlation ID: $TEST_CORRELATION_ID"
echo "   Test Session ID: $TEST_SESSION_ID"
echo "   Test User ID: $TEST_USER_ID"
echo

# Test 1: Application Logs - Different Levels
print_status "Test 1: Application Log Levels"

LEVELS=("debug" "info" "warn" "error")
for level in "${LEVELS[@]}"; do
    log_data=$(create_app_log "$level" "TestComponent" "level.test" "Testing $level level logging" '{"testType": "level", "level": "'$level'"}')
    
    if send_to_fluent_bit "$log_data" || send_to_elasticsearch "dice-logs-$(date +%Y.%m.%d)" "$log_data"; then
        print_success "  ✅ $level level log sent"
    else
        print_error "  ❌ Failed to send $level level log"
    fi
    sleep 1
done

# Test 2: Security Events
print_status "Test 2: Security Event Types"

SECURITY_EVENTS=(
    "AUTHENTICATION_FAILURE:HIGH:blocked:75:Failed login attempt detected"
    "AUTHORIZATION_DENIED:HIGH:blocked:70:Access denied to protected resource"
    "RATE_LIMIT_EXCEEDED:MEDIUM:blocked:50:Rate limit exceeded for user"
    "SUSPICIOUS_ACTIVITY:MEDIUM:flagged:60:Suspicious request pattern detected"
    "MALFORMED_REQUEST:LOW:blocked:30:Malformed request body detected"
)

for event in "${SECURITY_EVENTS[@]}"; do
    IFS=':' read -r event_type severity outcome risk_score message <<< "$event"
    
    log_data=$(create_security_log "$event_type" "$severity" "$outcome" "$risk_score" "$message")
    
    if send_to_fluent_bit "$log_data" || send_to_elasticsearch "dice-security-$(date +%Y.%m.%d)" "$log_data"; then
        print_success "  ✅ $event_type security event sent"
    else
        print_error "  ❌ Failed to send $event_type security event"
    fi
    sleep 1
done

# Test 3: Performance Logs
print_status "Test 3: Performance Metrics"

PERFORMANCE_TESTS=(
    "database_query:150:200"
    "api_request:500:200"
    "slow_operation:1500:200"
    "failed_request:300:500"
    "temporal_workflow:2000:200"
)

for test in "${PERFORMANCE_TESTS[@]}"; do
    IFS=':' read -r operation duration status_code <<< "$test"
    
    log_data=$(create_performance_log "$operation" "$duration" "$status_code")
    
    if send_to_fluent_bit "$log_data" || send_to_elasticsearch "dice-logs-$(date +%Y.%m.%d)" "$log_data"; then
        print_success "  ✅ $operation performance log sent (${duration}ms)"
    else
        print_error "  ❌ Failed to send $operation performance log"
    fi
    sleep 1
done

# Test 4: Correlation Tracing
print_status "Test 4: Correlation ID Tracing"

TRACE_STEPS=(
    "request_received:Incoming API request received"
    "auth_validated:User authentication validated"
    "database_queried:Database query executed"
    "workflow_started:Temporal workflow initiated"
    "response_sent:API response sent successfully"
)

for step in "${TRACE_STEPS[@]}"; do
    IFS=':' read -r action message <<< "$step"
    
    log_data=$(create_app_log "info" "CorrelationTrace" "$action" "$message" '{"traceStep": "'$action'", "testType": "correlation"}')
    
    if send_to_fluent_bit "$log_data" || send_to_elasticsearch "dice-logs-$(date +%Y.%m.%d)" "$log_data"; then
        print_success "  ✅ Trace step: $action"
    else
        print_error "  ❌ Failed to send trace step: $action"
    fi
    sleep 0.5
done

# Test 5: Error Scenarios with Stack Traces
print_status "Test 5: Error Handling"

ERROR_LOG=$(create_app_log "error" "ErrorHandler" "exception.handling" "Database connection timeout occurred" '{
    "error": {
        "name": "ConnectionTimeoutError",
        "message": "Connection to database timed out after 30 seconds",
        "stack": "ConnectionTimeoutError: Connection timeout\n    at DatabaseConnection.connect (/app/src/database.ts:45:12)\n    at UserService.findById (/app/src/user.service.ts:23:8)\n    at AuthController.validateUser (/app/src/auth.controller.ts:67:15)"
    },
    "database": {
        "host": "localhost",
        "port": 5432,
        "database": "dice_dev",
        "timeout": 30000
    },
    "testType": "error"
}')

if send_to_fluent_bit "$ERROR_LOG" || send_to_elasticsearch "dice-logs-$(date +%Y.%m.%d)" "$ERROR_LOG"; then
    print_success "  ✅ Error log with stack trace sent"
else
    print_error "  ❌ Failed to send error log"
fi

# Test 6: High Volume Burst
print_status "Test 6: High Volume Burst Test"

print_status "  Sending 50 rapid logs to test throughput..."
for i in {1..50}; do
    log_data=$(create_app_log "debug" "BurstTest" "volume.test" "Burst test log entry #$i" '{"burstIndex": '$i', "testType": "volume"}')
    
    if send_to_fluent_bit "$log_data" || send_to_elasticsearch "dice-logs-$(date +%Y.%m.%d)" "$log_data"; then
        if [[ $((i % 10)) -eq 0 ]]; then
            print_success "  ✅ Sent $i logs"
        fi
    else
        print_error "  ❌ Failed at log #$i"
        break
    fi
done

# ============================================================================
# VERIFICATION
# ============================================================================

print_status "🔍 **Verifying Test Results**"

# Wait for logs to be indexed
print_status "Waiting for logs to be indexed..."
sleep 10

# Query for test logs
VERIFICATION_QUERY='{
    "query": {
        "bool": {
            "must": [
                {"term": {"correlationId": "'$TEST_CORRELATION_ID'"}},
                {"range": {"@timestamp": {"gte": "now-5m"}}}
            ]
        }
    },
    "aggs": {
        "by_level": {
            "terms": {"field": "level", "size": 10}
        },
        "by_component": {
            "terms": {"field": "component", "size": 10}
        },
        "by_service": {
            "terms": {"field": "service", "size": 10}
        }
    },
    "size": 0
}'

print_status "Querying application logs..."
APP_RESULTS=$(curl -s -X POST "$ELASTICSEARCH_URL/dice-logs-*/_search" \
              -H "Content-Type: application/json" \
              -d "$VERIFICATION_QUERY")

if echo "$APP_RESULTS" | jq -e '.hits.total.value' > /dev/null 2>&1; then
    APP_LOG_COUNT=$(echo "$APP_RESULTS" | jq '.hits.total.value')
    print_success "✅ Found $APP_LOG_COUNT application logs with correlation ID $TEST_CORRELATION_ID"
    
    echo "   📊 **Breakdown by Level:**"
    echo "$APP_RESULTS" | jq -r '.aggregations.by_level.buckets[] | "      \(.key): \(.doc_count)"'
    
    echo "   📊 **Breakdown by Component:**"
    echo "$APP_RESULTS" | jq -r '.aggregations.by_component.buckets[] | "      \(.key): \(.doc_count)"'
else
    print_error "❌ Failed to verify application logs"
fi

print_status "Querying security logs..."
SECURITY_RESULTS=$(curl -s -X POST "$ELASTICSEARCH_URL/dice-security-*/_search" \
                   -H "Content-Type: application/json" \
                   -d "$VERIFICATION_QUERY")

if echo "$SECURITY_RESULTS" | jq -e '.hits.total.value' > /dev/null 2>&1; then
    SECURITY_LOG_COUNT=$(echo "$SECURITY_RESULTS" | jq '.hits.total.value')
    print_success "✅ Found $SECURITY_LOG_COUNT security logs with correlation ID $TEST_CORRELATION_ID"
else
    print_error "❌ Failed to verify security logs"
fi

# ============================================================================
# SUMMARY
# ============================================================================

show_completion "Logging Pipeline Test Complete"

print_success "🎯 **Test Summary:**"
echo "   • Test Correlation ID: $TEST_CORRELATION_ID"
echo "   • Application Logs Found: ${APP_LOG_COUNT:-0}"
echo "   • Security Logs Found: ${SECURITY_LOG_COUNT:-0}"
echo "   • Total Test Duration: $(date -d @$(($(date +%s) - START_TIME)) -u +%H:%M:%S 2>/dev/null || echo 'N/A')"

if [[ "${APP_LOG_COUNT:-0}" -gt 0 ]] && [[ "${SECURITY_LOG_COUNT:-0}" -gt 0 ]]; then
    print_success "✅ All logging pipeline tests passed!"
    echo
    print_status "🔍 **Next Steps:**"
    echo "   1. Open Kibana: ./logging-dashboard.sh"
    echo "   2. Search for correlationId: $TEST_CORRELATION_ID"
    echo "   3. Explore the test logs in different indices"
    echo "   4. Create visualizations and dashboards"
else
    print_warning "⚠️  Some tests may have failed. Check the logging infrastructure."
    echo
    print_status "🔧 **Troubleshooting:**"
    echo "   1. Verify ELK stack is running: docker ps"
    echo "   2. Check Elasticsearch health: curl $ELASTICSEARCH_URL/_cluster/health"
    echo "   3. Review container logs: docker logs dice_fluent_bit"
    echo "   4. Re-run setup: ./logging-setup.sh"
fi

exit 0 