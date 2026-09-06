#!/bin/bash

echo "=== Node Information ==="
kubectl get nodes --show-labels

echo -e "\n=== Pod Distribution by Node ==="
kubectl get pods -o wide --all-namespaces | grep -v kube-system

echo -e "\n=== Affinity Rule Validation ==="
echo "Checking web-app-ha anti-affinity (should be on different nodes):"
kubectl get pods -l app=web-app -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName

echo -e "\nChecking database and application pod affinity (should be on same node):"
kubectl get pods -l 'app in (database,application)' -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName

echo -e "\n=== Resource Usage by Node ==="
kubectl top nodes 2>/dev/null || echo "Metrics server not available"

echo -e "\n=== Recent Scheduling Events ==="
kubectl get events --sort-by=.metadata.creationTimestamp | tail -10
