#!/bin/bash

PROJECT_NAME="migration-demo"
BACKUP_DIR="~/app-backup/${PROJECT_NAME}"

echo "Starting backup of project: ${PROJECT_NAME}"

# Create backup directory
mkdir -p ${BACKUP_DIR}/{configs,data}

# Set project context
oc project ${PROJECT_NAME}

# Export all resources
echo "Exporting configurations..."
oc get deployments -o yaml > ${BACKUP_DIR}/configs/deployments.yaml
oc get services -o yaml > ${BACKUP_DIR}/configs/services.yaml
oc get routes -o yaml > ${BACKUP_DIR}/configs/routes.yaml
oc get pvc -o yaml > ${BACKUP_DIR}/configs/pvc.yaml
oc get configmaps -o yaml --field-selector metadata.name!=kube-root-ca.crt > ${BACKUP_DIR}/configs/configmaps.yaml
oc get secrets -o yaml --field-selector type!=kubernetes.io/service-account-token > ${BACKUP_DIR}/configs/secrets.yaml
oc get imagestreams -o yaml > ${BACKUP_DIR}/configs/imagestreams.yaml

# Create resource inventory
echo "Creating resource inventory..."
cat > ${BACKUP_DIR}/resource-inventory.txt << EOL
Backup created on: $(date)
Project: ${PROJECT_NAME}
Cluster: $(oc whoami --show-server)

Resources backed up:
- Deployments: $(oc get deployments --no-headers | wc -l)
- Services: $(oc get services --no-headers | wc -l)
- Routes: $(oc get routes --no-headers | wc -l)
- PVCs: $(oc get pvc --no-headers | wc -l)
- ConfigMaps: $(oc get configmaps --no-headers --field-selector metadata.name!=kube-root-ca.crt | wc -l)
- Secrets: $(oc get secrets --no-headers --field-selector type!=kubernetes.io/service-account-token | wc -l)
- ImageStreams: $(oc get imagestreams --no-headers | wc -l)
EOL

echo "Backup completed successfully!"
echo "Backup location: ${BACKUP_DIR}"
