Lab 4: Backup Strategies with OADP
Objectives
By the end of this lab, students will be able to:

• Understand the fundamentals of OpenShift API for Data Protection (OADP) • Install and configure OADP operator on OpenShift clusters • Configure backup strategies for persistent volume claims (PVCs) and application data • Perform manual backups and validate backup integrity • Implement backup scheduling and retention policies • Restore applications and data from backup files • Troubleshoot common backup and restore issues

Prerequisites
Before starting this lab, students should have:

• Basic understanding of OpenShift/Kubernetes concepts • Familiarity with persistent volumes and persistent volume claims • Knowledge of YAML configuration files • Experience with command-line interface (CLI) tools • Understanding of container storage concepts • Access to OpenShift cluster with cluster-admin privileges

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift clusters already deployed. Simply click Start Lab to access your environment - no need to build your own VM or install OpenShift from scratch.

Your lab environment includes: • OpenShift 4.12+ cluster with 3 worker nodes • Pre-installed OpenShift CLI (oc) • Administrative access to the cluster • Sample applications for backup testing

Task 1: Install OADP on OpenShift
Subtask 1.1: Verify Cluster Access and Prerequisites
First, let's verify that you have proper access to the OpenShift cluster and check the cluster status.

Connect to your lab environment and open a terminal

Verify cluster access:

oc whoami
oc cluster-info
Check cluster nodes:
oc get nodes
Verify you have cluster-admin privileges:
oc auth can-i '*' '*'
Subtask 1.2: Create OADP Namespace and Install Operator
Create a dedicated namespace for OADP:
oc create namespace openshift-adp
Create the OperatorGroup for OADP:
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-adp-operator-group
  namespace: openshift-adp
spec:
  targetNamespaces:
  - openshift-adp
EOF
Create the Subscription to install OADP operator:
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: redhat-oadp-operator
  namespace: openshift-adp
spec:
  channel: stable-1.3
  name: redhat-oadp-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
EOF
Wait for the operator to be installed:
oc get csv -n openshift-adp
Verify the operator pods are running:
oc get pods -n openshift-adp
Subtask 1.3: Configure Storage for Backups
For this lab, we'll use a local storage solution. In production environments, you would typically use cloud storage like AWS S3, Azure Blob, or Google Cloud Storage.

Create a storage class for backup storage:
cat << EOF | oc apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: backup-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
EOF
Create a persistent volume for backup storage:
cat << EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: backup-pv
spec:
  capacity:
    storage: 50Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: backup-storage
  hostPath:
    path: /opt/backup-storage
EOF
Task 2: Configure Backup of Persistent Volume Claims and Application Data
Subtask 2.1: Deploy Sample Application with Persistent Storage
Let's deploy a sample application that uses persistent storage to demonstrate backup capabilities.

Create a namespace for the sample application:
oc new-project backup-demo
Deploy a sample database application:
cat << EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-db
  namespace: backup-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-db
  template:
    metadata:
      labels:
        app: sample-db
    spec:
      containers:
      - name: postgresql
        image: registry.redhat.io/rhel8/postgresql-13:latest
        env:
        - name: POSTGRESQL_USER
          value: "testuser"
        - name: POSTGRESQL_PASSWORD
          value: "testpass"
        - name: POSTGRESQL_DATABASE
          value: "testdb"
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgresql-data
          mountPath: /var/lib/pgsql/data
      volumes:
      - name: postgresql-data
        persistentVolumeClaim:
          claimName: postgresql-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-pvc
  namespace: backup-demo
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
EOF
Wait for the deployment to be ready:
oc get pods -n backup-demo -w
Add some test data to the database:
# Get the pod name
POD_NAME=$(oc get pods -n backup-demo -l app=sample-db -o jsonpath='{.items[0].metadata.name}')

# Connect to the database and create test data
oc exec -n backup-demo $POD_NAME -- psql -U testuser -d testdb -c "
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

INSERT INTO users (name, email) VALUES 
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com'),
('Bob Johnson', 'bob@example.com');
"
Verify the test data:
oc exec -n backup-demo $POD_NAME -- psql -U testuser -d testdb -c "SELECT * FROM users;"
Subtask 2.2: Configure OADP DataProtectionApplication
Now we'll configure OADP to use our storage backend for backups.

Create a secret for backup storage credentials (for local storage, we'll use a minimal configuration):
cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: backup-storage-credentials
  namespace: openshift-adp
type: Opaque
data:
  cloud: ""
EOF
Create the DataProtectionApplication configuration:
cat << EOF | oc apply -f -
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: backup-app
  namespace: openshift-adp
spec:
  configuration:
    velero:
      defaultPlugins:
      - openshift
      - aws
      - csi
    restic:
      enable: true
  backupLocations:
  - name: default
    velero:
      provider: aws
      default: true
      objectStorage:
        bucket: backup-bucket
        prefix: velero
      config:
        region: us-east-1
        s3ForcePathStyle: "true"
        s3Url: http://minio.openshift-adp.svc:9000
      credential:
        name: backup-storage-credentials
        key: cloud
EOF
Wait for OADP to be ready:
oc get pods -n openshift-adp
Verify the backup location is available:
oc get backupstoragelocations -n openshift-adp
Subtask 2.3: Create Backup Schedules and Policies
Create a backup schedule for regular backups:
cat << EOF | oc apply -f -
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-backup
  namespace: openshift-adp
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  template:
    includedNamespaces:
    - backup-demo
    storageLocation: default
    ttl: 720h0m0s  # 30 days retention
    includedResources:
    - persistentvolumeclaims
    - persistentvolumes
    - deployments
    - services
    - configmaps
    - secrets
EOF
Create a backup policy for application-specific backups:
cat << EOF | oc apply -f -
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: backup-policy-template
  namespace: openshift-adp
spec:
  includedNamespaces:
  - backup-demo
  storageLocation: default
  ttl: 168h0m0s  # 7 days retention
  includedResources:
  - persistentvolumeclaims
  - persistentvolumes
  - deployments
  - services
  - configmaps
  - secrets
  hooks:
    resources:
    - name: postgresql-backup-hook
      includedNamespaces:
      - backup-demo
      labelSelector:
        matchLabels:
          app: sample-db
      pre:
      - exec:
          container: postgresql
          command:
          - /bin/bash
          - -c
          - "pg_dump -U testuser testdb > /tmp/backup.sql"
      post:
      - exec:
          container: postgresql
          command:
          - /bin/bash
          - -c
          - "rm -f /tmp/backup.sql"
EOF
Task 3: Perform Manual Backup and Verify Backup Files
Subtask 3.1: Create Manual Backup
Create a manual backup of the sample application:
cat << EOF | oc apply -f -
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: manual-backup-$(date +%Y%m%d-%H%M%S)
  namespace: openshift-adp
spec:
  includedNamespaces:
  - backup-demo
  storageLocation: default
  ttl: 72h0m0s  # 3 days retention
  includedResources:
  - persistentvolumeclaims
  - persistentvolumes
  - deployments
  - services
  - configmaps
  - secrets
  hooks:
    resources:
    - name: postgresql-backup-hook
      includedNamespaces:
      - backup-demo
      labelSelector:
        matchLabels:
          app: sample-db
      pre:
      - exec:
          container: postgresql
          command:
          - /bin/bash
          - -c
          - "echo 'Starting backup process'"
EOF
Monitor the backup progress:
oc get backups -n openshift-adp
Check backup details:
BACKUP_NAME=$(oc get backups -n openshift-adp --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
oc describe backup $BACKUP_NAME -n openshift-adp
Wait for backup completion:
oc get backup $BACKUP_NAME -n openshift-adp -o jsonpath='{.status.phase}'
Subtask 3.2: Verify Backup Files and Content
List all available backups:
oc get backups -n openshift-adp -o wide
Check backup logs for any issues:
oc logs -n openshift-adp deployment/velero -f
Verify backup storage location:
oc get backupstoragelocations -n openshift-adp -o yaml
Check the backup content details:
cat << EOF | oc apply -f -
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: default
  namespace: openshift-adp
spec:
  provider: aws
  objectStorage:
    bucket: backup-bucket
    prefix: velero
  config:
    region: us-east-1
    s3ForcePathStyle: "true"
    s3Url: http://minio.openshift-adp.svc:9000
  credential:
    name: backup-storage-credentials
    key: cloud
EOF
Subtask 3.3: Test Backup Integrity with Restore
Create a test restore to verify backup integrity:
# First, let's create a new namespace for restore testing
oc new-project restore-test

# Create a restore from our backup
cat << EOF | oc apply -f -
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: test-restore-$(date +%Y%m%d-%H%M%S)
  namespace: openshift-adp
spec:
  backupName: $BACKUP_NAME
  includedNamespaces:
  - backup-demo
  namespaceMapping:
    backup-demo: restore-test
  restorePVs: true
EOF
Monitor the restore progress:
oc get restores -n openshift-adp
Verify the restored application:
oc get pods -n restore-test
oc get pvc -n restore-test
Verify restored data integrity:
# Wait for the restored pod to be ready
oc wait --for=condition=Ready pod -l app=sample-db -n restore-test --timeout=300s

# Get the restored pod name
RESTORED_POD=$(oc get pods -n restore-test -l app=sample-db -o jsonpath='{.items[0].metadata.name}')

# Check if our test data is intact
oc exec -n restore-test $RESTORED_POD -- psql -U testuser -d testdb -c "SELECT * FROM users;"
Subtask 3.4: Implement Backup Monitoring and Alerting
Create a script to monitor backup status:
cat << 'EOF' > backup-monitor.sh
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
EOF

chmod +x backup-monitor.sh
Use the monitoring script:
./backup-monitor.sh $BACKUP_NAME
Troubleshooting Common Issues
Issue 1: OADP Operator Installation Fails
Symptoms: Operator pods are not starting or CSV shows failed status

Solution:

# Check operator logs
oc logs -n openshift-adp deployment/oadp-operator-controller-manager

# Verify subscription status
oc get subscription -n openshift-adp

# Check install plan
oc get installplan -n openshift-adp
Issue 2: Backup Fails with Storage Issues
Symptoms: Backup status shows "Failed" with storage-related errors

Solution:

# Check backup storage location status
oc get backupstoragelocations -n openshift-adp

# Verify credentials
oc get secret backup-storage-credentials -n openshift-adp -o yaml

# Check Velero logs
oc logs -n openshift-adp deployment/velero
Issue 3: PVC Backup Not Working
Symptoms: Persistent volumes are not included in backups

Solution:

# Ensure CSI plugin is enabled
oc get dpa backup-app -n openshift-adp -o yaml | grep -A 10 defaultPlugins

# Check if PVCs have proper annotations
oc get pvc -n backup-demo -o yaml | grep annotations

# Verify storage class supports snapshots
oc get storageclass -o yaml
Issue 4: Restore Fails
Symptoms: Restore operation fails or restored pods don't start

Solution:

# Check restore logs
oc describe restore <restore-name> -n openshift-adp

# Verify namespace mapping
oc get restore <restore-name> -n openshift-adp -o yaml

# Check for resource conflicts
oc get all -n <target-namespace>
Advanced Configuration Options
Backup Hooks Configuration
cat << EOF | oc apply -f -
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: advanced-backup
  namespace: openshift-adp
spec:
  includedNamespaces:
  - backup-demo
  hooks:
    resources:
    - name: database-consistent-backup
      includedNamespaces:
      - backup-demo
      labelSelector:
        matchLabels:
          app: sample-db
      pre:
      - exec:
          container: postgresql
          command:
          - /bin/bash
          - -c
          - |
            echo "Starting consistent backup"
            psql -U testuser -d testdb -c "SELECT pg_start_backup('velero-backup');"
      post:
      - exec:
          container: postgresql
          command:
          - /bin/bash
          - -c
          - |
            psql -U testuser -d testdb -c "SELECT pg_stop_backup();"
            echo "Backup completed"
EOF
Backup Filtering and Selection
cat << EOF | oc apply -f -
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: selective-backup
  namespace: openshift-adp
spec:
  includedNamespaces:
  - backup-demo
  labelSelector:
    matchLabels:
      backup: "enabled"
  includedResources:
  - persistentvolumeclaims
  - deployments
  - services
  excludedResources:
  - events
  - logs
EOF
Performance Optimization
Parallel Backup Configuration
cat << EOF | oc patch dpa backup-app -n openshift-adp --type merge --patch '
spec:
  configuration:
    velero:
      podConfig:
        resourceAllocations:
          limits:
            cpu: "2"
            memory: "4Gi"
          requests:
            cpu: "1"
            memory: "2Gi"
    restic:
      podConfig:
        resourceAllocations:
          limits:
            cpu: "1"
            memory: "2Gi"
          requests:
            cpu: "500m"
            memory: "1Gi"
'
EOF
Conclusion
In this comprehensive lab, you have successfully:

• Installed and configured OADP on an OpenShift cluster, learning how to set up the operator and configure storage backends for backup operations

• Implemented backup strategies for persistent volume claims and application data, including the creation of backup schedules, policies, and hooks for database consistency

• Performed manual backups and verified their integrity through restore testing, ensuring that your backup processes are reliable and data can be successfully recovered

• Learned troubleshooting techniques for common backup and restore issues, preparing you to handle real-world scenarios

• Explored advanced configuration options including backup hooks, filtering, and performance optimization

Why This Matters: Data protection is critical in enterprise environments. OADP provides a robust, Kubernetes-native solution for backing up applications and persistent data in OpenShift clusters. The skills you've learned enable you to:

Implement comprehensive disaster recovery strategies
Ensure business continuity through reliable backup processes
Meet compliance requirements for data protection
Reduce recovery time objectives (RTO) and recovery point objectives (RPO)
Protect against data loss from hardware failures, human errors, or security incidents
These backup strategies are essential for production OpenShift deployments and form a cornerstone of enterprise data protection practices. The hands-on experience with OADP prepares you for real-world scenarios where data protection and disaster recovery are business-critical requirements.
