#!/bin/bash

# Test script for production server endpoints
# Usage: ./test_production.sh

echo "🔍 Testing production server endpoints..."
echo "=========================================="

BASE_URL="https://atomaiapp.com/api"

echo "1. Testing health endpoint..."
echo "URL: $BASE_URL/health"
curl -s -w "\nStatus: %{http_code}\n" "$BASE_URL/health"
echo ""

echo "2. Testing auth endpoint (should return 401 for invalid token)..."
echo "URL: $BASE_URL/auth/google/exchange"
curl -s -w "\nStatus: %{http_code}\n" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"id_token": "test"}' \
  "$BASE_URL/auth/google/exchange"
echo ""

echo "3. Testing root endpoint..."
echo "URL: $BASE_URL/"
curl -s -w "\nStatus: %{http_code}\n" "$BASE_URL/"
echo ""

echo "4. Testing non-existent endpoint (should return 404)..."
echo "URL: $BASE_URL/nonexistent"
curl -s -w "\nStatus: %{http_code}\n" "$BASE_URL/nonexistent"
echo ""

echo "=========================================="
echo "Test complete!" 