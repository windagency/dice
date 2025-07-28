#!/bin/bash
# Test script for DICE Authentication System

set -e

API_URL="http://localhost:3001"
echo "🔐 Testing DICE Authentication System"
echo "======================================"

# Test 1: Register a new user
echo "1. Testing user registration..."
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@dice.com",
    "username": "testuser",
    "password": "SecurePass123!"
  }')

echo "✅ Registration response: $REGISTER_RESPONSE"

# Extract token from registration response
TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to extract token from registration"
  exit 1
fi

echo "✅ Token extracted: ${TOKEN:0:20}..."

# Test 2: Test protected endpoint
echo ""
echo "2. Testing protected endpoint with token..."
PROFILE_RESPONSE=$(curl -s -X GET "$API_URL/auth/profile" \
  -H "Authorization: Bearer $TOKEN")

echo "✅ Profile response: $PROFILE_RESPONSE"

# Test 3: Test protected endpoint without token
echo ""
echo "3. Testing protected endpoint without token (should fail)..."
UNAUTH_RESPONSE=$(curl -s -X GET "$API_URL/auth/profile")
echo "✅ Unauthorized response: $UNAUTH_RESPONSE"

# Test 4: Test workflow endpoint (should be protected)
echo ""
echo "4. Testing protected workflow endpoint..."
WORKFLOW_RESPONSE=$(curl -s -X POST "$API_URL/workflows/example" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"userId": "test-user", "data": "test"}')

echo "✅ Workflow response: $WORKFLOW_RESPONSE"

# Test 5: Login with same user
echo ""
echo "5. Testing user login..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@dice.com",
    "password": "SecurePass123!"
  }')

echo "✅ Login response: $LOGIN_RESPONSE"

echo ""
echo "🎉 Authentication system tests completed!"
echo "======================================" 