#!/bin/bash
ROUTE_URL=$(oc get route restored-app-route -n restored-app-namespace -o jsonpath='{.spec.host}')

echo "Testing application functionality..."

# Test health endpoint
echo "1. Health check:"
curl -k -s https://$ROUTE_URL/health | jq .

# Test data retrieval
echo "2. Data retrieval test:"
curl -k -s https://$ROUTE_URL/api/data | head -5

# Test write operation
echo "3. Write operation test:"
curl -k -X POST -H "Content-Type: application/json" -d '{"test":"restore-verification"}' https://$ROUTE_URL/api/data

# Verify write was successful
echo "4. Verify write operation:"
curl -k -s https://$ROUTE_URL/api/data | grep "restore-verification"

echo "Application functionality test completed."
