#!/bin/bash

echo "Performing advanced configuration cleanup..."

# Clean up PVC configurations
if [ -f "configs/pvc.yaml" ]; then
    echo "Cleaning PVC configurations..."
    # Remove volume names that are cluster-specific
    sed -i '/volumeName:/d' configs/pvc.yaml
    # Remove storage class if it doesn't exist in destination
    # sed -i '/storageClassName:/d' configs/pvc.yaml
fi

# Clean up service configurations
if [ -f "configs/services.yaml" ]; then
    echo "Cleaning service configurations..."
    # Remove cluster IP assignments
    sed -i '/clusterIP:/d' configs/services.yaml
    sed -i '/clusterIPs:/d' configs/services.yaml
fi

# Clean up route configurations
if [ -f "configs/routes.yaml" ]; then
    echo "Cleaning route configurations..."
    # Update host names for new cluster (if needed)
    sed -i 's/apps\.source-cluster\.com/apps.destination-cluster.com/g' configs/routes.yaml
fi

echo "Advanced cleanup completed!"
