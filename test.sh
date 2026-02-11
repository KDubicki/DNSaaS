#!/bin/bash

# DNSaaS Test Script
# This script tests the DNS service functionality

set -e

DNS_SERVER="${DNS_SERVER:-localhost}"
LOCAL_DOMAIN="${LOCAL_DOMAIN:-homelab.local}"

echo "=================================="
echo "DNSaaS Test Suite"
echo "=================================="
echo "DNS Server: $DNS_SERVER"
echo "Local Domain: $LOCAL_DOMAIN"
echo ""

# Function to test DNS query
test_query() {
    local query=$1
    local expected=$2
    local description=$3
    
    echo -n "Testing: $description... "
    
    if command -v dig >/dev/null 2>&1; then
        result=$(dig @"$DNS_SERVER" +short "$query" | head -1)
    elif command -v nslookup >/dev/null 2>&1; then
        result=$(nslookup "$query" "$DNS_SERVER" | grep -A1 "Name:" | tail -1 | awk '{print $2}')
    else
        echo "SKIP (no dig or nslookup found)"
        return
    fi
    
    if [ -n "$result" ]; then
        echo "✓ PASS (resolved to: $result)"
    else
        echo "✗ FAIL (no result)"
    fi
}

# Test 1: Check if service is running
echo "Test 1: Service Status"
echo "------------------------"
if docker ps | grep -q dnsaas-coredns; then
    echo "✓ Container is running"
else
    echo "✗ Container is not running"
    exit 1
fi
echo ""

# Test 2: Health check
echo "Test 2: Health Check"
echo "------------------------"
if curl -sf http://localhost:8080/health >/dev/null 2>&1; then
    echo "✓ Health check passed"
else
    echo "⚠ Health check endpoint not available (this is normal if health plugin is not configured)"
fi
echo ""

# Test 3: Local domain resolution
echo "Test 3: Local Domain Resolution"
echo "------------------------"
test_query "ns1.$LOCAL_DOMAIN" "" "Name server"
test_query "nas.$LOCAL_DOMAIN" "" "NAS server"
test_query "proxmox.$LOCAL_DOMAIN" "" "Proxmox server"
echo ""

# Test 4: External domain resolution (forwarding)
echo "Test 4: External DNS Forwarding"
echo "------------------------"
test_query "google.com" "" "Google.com"
test_query "github.com" "" "GitHub.com"
echo ""

# Test 5: Metrics endpoint
echo "Test 5: Prometheus Metrics"
echo "------------------------"
if curl -sf http://localhost:9153/metrics | head -5 >/dev/null 2>&1; then
    echo "✓ Metrics endpoint is accessible"
    echo "  Available at: http://localhost:9153/metrics"
else
    echo "⚠ Metrics endpoint not available"
fi
echo ""

# Test 6: Container logs
echo "Test 6: Recent Logs"
echo "------------------------"
echo "Last 10 log entries:"
docker-compose logs --tail=10 coredns
echo ""

echo "=================================="
echo "Test Suite Complete"
echo "=================================="
