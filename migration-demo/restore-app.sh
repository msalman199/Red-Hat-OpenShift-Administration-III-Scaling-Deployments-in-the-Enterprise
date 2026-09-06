#!/bin/bash

PROJECT_NAME="migration-demo"
echo "Starting restoration of project: ${PROJECT_NAME}"

# Ensure we're in the correct project
oc project ${PROJECT_NAME}

# Restore in dependency order
echo "Restoring secrets..."
if [ -f "configs/secrets.yaml" ]; then
    oc apply -f configs/secrets.yaml
fi

echo "Restoring config maps..."
if [ -f "configs/configmaps.yaml" ]; then
    oc apply -f configs/configmaps.yaml
fi

echo "Restoring image streams..."
if [ -f "configs/imagestreams.yaml" ]; then
    oc apply -f configs/imagestreams.yaml
fi

echo "Restoring persistent volume claims..."
if [ -f "configs/pvc.yaml" ]; then
    oc apply -f configs/pvc.yaml
fi

echo "Waiting for PVCs to be bound..."
sleep 10

echo "Restoring services..."
if [ -f "configs/services.yaml" ]; then
    oc apply -f configs/services.yaml
fi

echo "Restoring deployments..."
if [ -f "configs/deployments.yaml" ]; then
    oc apply -f configs/deployments.yaml
fi

echo "Restoring routes..."
if [ -f "configs/routes.yaml" ]; then
    oc apply -f configs/routes.yaml
fi

echo "Restoration completed!"
echo "Checking deployment status..."
oc get pods
