#!/bin/bash

PROJECT_NAME="migration-demo"
echo "Testing migrated application in project: ${PROJECT_NAME}"

# Set project context
oc project ${PROJECT_NAME}

echo "=== Pod Status Check ==="
oc get pods

echo -e "\n=== Service Status Check ==="
oc get services

echo -e "\n=== Route Status Check ==="
oc get routes

echo -e "\n=== PVC Status Check ==="
oc get pvc

echo -e "\n=== Testing Application Connectivity ==="
APP_ROUTE=$(oc get route webapp -o jsonpath='{.spec.host}' 2>/dev/null)

if [ -n "$APP_ROUTE" ]; then
    echo "Testing application at: http://${APP_ROUTE}"
    
    # Test HTTP response
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${APP_ROUTE})
    echo "HTTP Status: ${HTTP_STATUS}"
    
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "✓ Application is responding correctly"
    else
        echo "✗ Application is not responding correctly"
    fi
else
    echo "✗ No route found for application"
fi

echo -e "\n=== Database Connectivity Test ==="
POSTGRES_POD=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$POSTGRES_POD" ]; then
    echo "Testing database connectivity..."
    DB_TEST=$(oc exec ${POSTGRES_POD} -- psql -U webapp -d webappdb -c "SELECT 1;" 2>/dev/null | grep -c "1 row")
    
    if [ "$DB_TEST" = "1" ]; then
        echo "✓ Database is accessible and responding"
    else
        echo "✗ Database connectivity issues"
    fi
else
    echo "✗ PostgreSQL pod not found"
fi

echo -e "\n=== Migration Verification Summary ==="
TOTAL_PODS=$(oc get pods --no-headers | wc -l)
RUNNING_PODS=$(oc get pods --no-headers | grep Running | wc -l)

echo "Total Pods: ${TOTAL_PODS}"
echo "Running Pods: ${RUNNING_PODS}"

if [ "$TOTAL_PODS" = "$RUNNING_PODS" ] && [ "$TOTAL_PODS" -gt "0" ]; then
    echo "✓ All pods are running successfully"
    echo "✓ Migration appears to be successful!"
else
    echo "✗ Some pods are not running correctly"
    echo "✗ Migration may need troubleshooting"
fi
