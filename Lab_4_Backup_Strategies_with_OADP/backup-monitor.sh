#!/bin/bash

NAMESPACE="openshift-adp"
BACKUP_NAME="$1"

if [ -z "$BACKUP_NAME" ]; then
    echo "Usage: $0 <backup-name>"
    exit 1
fi

echo "Monitoring backup: $BACKUP_NAME"
echo "================================"

while true; do
    STATUS=$(oc get backup $BACKUP_NAME -n $NAMESPACE -o jsonpath='{.status.phase}' 2>/dev/null)
    
    if [ -z "$STATUS" ]; then
        echo "Backup not found or error occurred"
        exit 1
    fi
    
    echo "$(date): Backup status: $STATUS"
    
    case $STATUS in
        "Completed")
            echo "Backup completed successfully!"
            ITEMS=$(oc get backup $BACKUP_NAME -n $NAMESPACE -o jsonpath='{.status.itemsBackedUp}')
            echo "Items backed up: $ITEMS"
            break
            ;;
        "Failed")
            echo "Backup failed!"
            oc describe backup $BACKUP_NAME -n $NAMESPACE
            exit 1
            ;;
        "InProgress")
            echo "Backup in progress..."
            ;;
        *)
            echo "Unknown status: $STATUS"
            ;;
    esac
    
    sleep 30
done
