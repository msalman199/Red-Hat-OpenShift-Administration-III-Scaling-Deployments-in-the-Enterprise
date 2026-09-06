#!/bin/bash

echo "=== MIGRATION REPORT ==="
echo "Generated on: $(date)"
echo "Project: migration-demo"
echo "Destination Cluster: $(oc whoami --show-server)"
echo

echo "=== RESOURCE SUMMARY ==="
echo "Deployments: $(oc get deployments --no-headers | wc -l)"
echo "Services: $(oc get services --no-headers | wc -l)"
echo "Routes: $(oc get routes --no-headers | wc -l)"
echo "PVCs: $(oc get pvc --no-headers | wc -l)"
echo "Pods: $(oc get pods --no-headers | wc -l)"
echo "Running Pods: $(oc get pods --no-headers | grep Running | wc -l)"

echo -e "\n=== HEALTH STATUS ==="
oc get pods -o wide

echo -e "\n=== APPLICATION ACCESS ==="
APP_ROUTE=$(oc get route webapp -o jsonpath='{.spec.host}' 2>/dev/null)
if [ -n "$APP_ROUTE" ]; then
    echo "Application URL: http://${APP_ROUTE}"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${APP_ROUTE})
    echo "HTTP Status: ${HTTP_STATUS}"
else
    echo "No external route configured"
fi

echo -e "\n=== MIGRATION STATUS ==="
TOTAL_PODS=$(oc get pods --no-headers | wc -l)
RUNNING_PODS=$(oc get pods --no-headers | grep Running | wc -l)

if [ "$TOTAL_PODS" = "$RUNNING_PODS" ] && [ "$TOTAL_PODS" -gt "0" ]; then
    echo "STATUS: ✓ MIGRATION SUCCESSFUL"
else
    echo "STATUS: ✗ MIGRATION NEEDS ATTENTION"
fi

echo -e "\n=== END REPORT ==="
