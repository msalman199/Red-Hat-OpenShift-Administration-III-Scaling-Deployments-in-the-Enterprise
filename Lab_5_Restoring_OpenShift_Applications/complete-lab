Lab 5: Restoring OpenShift Applications
Objectives
By the end of this lab, students will be able to:

• Understand the fundamentals of OpenShift application restoration processes • Perform complete application restoration from backup using OADP (OpenShift API for Data Protection) • Execute cross-cluster and cross-namespace restoration scenarios • Validate application functionality and data integrity after restoration • Implement best practices for disaster recovery in OpenShift environments • Troubleshoot common restoration issues and verify successful recovery operations

Prerequisites
Before starting this lab, students should have:

• Basic understanding of OpenShift/Kubernetes concepts (pods, deployments, services, persistent volumes) • Familiarity with command-line interface operations • Knowledge of YAML configuration files • Understanding of backup and restore concepts • Completion of previous labs covering OpenShift backup procedures • Access to oc CLI tool and basic OpenShift administration knowledge

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift clusters already deployed. Simply click Start Lab to access your environment - no need to build your own VM or install OpenShift from scratch.

Your lab environment includes: • Two OpenShift clusters (source and target) • Pre-installed OADP operator • Sample applications with persistent data • Velero CLI tools • All necessary backup configurations

Task 1: Perform a Restore from Backup
Subtask 1.1: Verify Existing Backup Resources
First, let's examine the available backups in our environment.

Connect to your OpenShift cluster:
oc login --server=https://api.cluster1.example.com:6443 --username=admin --password=admin123
Switch to the backup namespace:
oc project openshift-adp
List available backups:
oc get backups
Examine backup details:
oc describe backup sample-app-backup-$(date +%Y%m%d)
Verify backup storage location:
oc get backupstoragelocation -o yaml
Subtask 1.2: Prepare the Application for Restoration
Create a test scenario by deleting the original application:
# Switch to the application namespace
oc project sample-app-namespace

# Scale down the application
oc scale deployment sample-app --replicas=0

# Delete the application resources (simulate disaster)
oc delete deployment sample-app
oc delete service sample-app-service
oc delete configmap sample-app-config
Verify the application is removed:
oc get all -n sample-app-namespace
Subtask 1.3: Execute the Restoration Process
Create a restore configuration file:
cat > restore-sample-app.yaml << EOF
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: sample-app-restore-$(date +%Y%m%d-%H%M)
  namespace: openshift-adp
spec:
  backupName: sample-app-backup-$(date +%Y%m%d)
  includedNamespaces:
  - sample-app-namespace
  restorePVs: true
  existingResourcePolicy: update
EOF
Apply the restore configuration:
oc apply -f restore-sample-app.yaml
Monitor the restore progress:
# Watch restore status
oc get restore -w

# Check detailed restore information
oc describe restore sample-app-restore-$(date +%Y%m%d-%H%M)
Verify restoration completion:
# Check if pods are running
oc get pods -n sample-app-namespace

# Verify services are restored
oc get services -n sample-app-namespace

# Check persistent volumes
oc get pv | grep sample-app
Subtask 1.4: Validate Application Functionality
Test application accessibility:
# Get the application route
oc get routes -n sample-app-namespace

# Test the application endpoint
curl -k https://$(oc get route sample-app -n sample-app-namespace -o jsonpath='{.spec.host}')
Verify data integrity:
# Connect to the application pod
oc exec -it $(oc get pods -n sample-app-namespace -l app=sample-app -o jsonpath='{.items[0].metadata.name}') -- /bin/bash

# Inside the pod, check data files
ls -la /data/
cat /data/important-file.txt
exit
Task 2: Test Restoring to a New Cluster or Namespace
Subtask 2.1: Prepare Target Environment
Switch to the target cluster:
oc login --server=https://api.cluster2.example.com:6443 --username=admin --password=admin123
Create a new target namespace:
oc create namespace restored-app-namespace
oc project restored-app-namespace
Verify OADP operator is installed on target cluster:
oc get pods -n openshift-adp
Subtask 2.2: Configure Cross-Cluster Backup Access
Create backup storage location on target cluster:
cat > target-backup-storage.yaml << EOF
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: cross-cluster-storage
  namespace: openshift-adp
spec:
  provider: aws
  objectStorage:
    bucket: openshift-backup-bucket
    prefix: cluster1-backups
  config:
    region: us-east-1
    s3ForcePathStyle: "true"
    s3Url: https://s3.amazonaws.com
EOF
Apply the storage configuration:
oc apply -f target-backup-storage.yaml
Verify backup accessibility:
oc get backups --all-namespaces
Subtask 2.3: Execute Cross-Cluster Restoration
Create namespace mapping restore configuration:
cat > cross-cluster-restore.yaml << EOF
apiVersion: velero.io/v1
kind: Restore
metadata:
  name: cross-cluster-restore-$(date +%Y%m%d-%H%M)
  namespace: openshift-adp
spec:
  backupName: sample-app-backup-$(date +%Y%m%d)
  includedNamespaces:
  - sample-app-namespace
  namespaceMapping:
    sample-app-namespace: restored-app-namespace
  restorePVs: true
  existingResourcePolicy: update
EOF
Execute the cross-cluster restore:
oc apply -f cross-cluster-restore.yaml
Monitor restoration progress:
# Watch the restore process
oc get restore cross-cluster-restore-$(date +%Y%m%d-%H%M) -w

# Check detailed status
oc describe restore cross-cluster-restore-$(date +%Y%m%d-%H%M)
Subtask 2.4: Verify Cross-Cluster Restoration
Check restored resources in new namespace:
# Verify pods are running
oc get pods -n restored-app-namespace

# Check services
oc get services -n restored-app-namespace

# Verify deployments
oc get deployments -n restored-app-namespace
Create route for the restored application:
oc expose service sample-app-service -n restored-app-namespace --name=restored-app-route
Test application functionality:
# Get the new route
oc get routes -n restored-app-namespace

# Test connectivity
curl -k https://$(oc get route restored-app-route -n restored-app-namespace -o jsonpath='{.spec.host}')
Task 3: Verify Applications and Data Are Restored Correctly
Subtask 3.1: Comprehensive Application Verification
Perform health checks on all restored components:
# Check deployment status
oc get deployments -n restored-app-namespace -o wide

# Verify replica counts
oc get replicasets -n restored-app-namespace

# Check pod health
oc get pods -n restored-app-namespace -o wide
Validate service connectivity:
# Test internal service connectivity
oc run test-pod --image=busybox --rm -it --restart=Never -- /bin/sh

# Inside the test pod
nslookup sample-app-service.restored-app-namespace.svc.cluster.local
wget -qO- http://sample-app-service.restored-app-namespace.svc.cluster.local:8080/health
exit
Subtask 3.2: Data Integrity Verification
Compare data between original and restored applications:
# Connect to restored application pod
oc exec -it $(oc get pods -n restored-app-namespace -l app=sample-app -o jsonpath='{.items[0].metadata.name}') -- /bin/bash

# Check data directory structure
find /data -type f -exec ls -la {} \;

# Verify file contents
md5sum /data/*.txt
cat /data/database.db | head -20
exit
Validate persistent volume data:
# Check PV claims
oc get pvc -n restored-app-namespace

# Verify PV status
oc get pv | grep restored-app-namespace

# Check storage class
oc describe pvc sample-app-data -n restored-app-namespace
Subtask 3.3: Configuration and Secrets Verification
Verify ConfigMaps are restored correctly:
# List all ConfigMaps
oc get configmaps -n restored-app-namespace

# Compare ConfigMap content
oc get configmap sample-app-config -n restored-app-namespace -o yaml
Check Secrets restoration:
# List secrets
oc get secrets -n restored-app-namespace

# Verify secret data (be careful with sensitive information)
oc describe secret sample-app-secret -n restored-app-namespace
Validate environment variables:
# Check environment variables in running pods
oc exec $(oc get pods -n restored-app-namespace -l app=sample-app -o jsonpath='{.items[0].metadata.name}') -- env | grep APP_
Subtask 3.4: Performance and Functionality Testing
Execute application-specific tests:
# Create a test script
cat > app-functionality-test.sh << 'EOF'
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
EOF

chmod +x app-functionality-test.sh
./app-functionality-test.sh
Monitor application performance:
# Check resource usage
oc top pods -n restored-app-namespace

# Monitor application logs
oc logs -f $(oc get pods -n restored-app-namespace -l app=sample-app -o jsonpath='{.items[0].metadata.name}') --tail=50
Subtask 3.5: Generate Restoration Report
Create a comprehensive restoration report:
cat > restoration-report.txt << EOF
OpenShift Application Restoration Report
========================================
Date: $(date)
Operator: $(oc whoami)

RESTORATION SUMMARY:
- Source Backup: sample-app-backup-$(date +%Y%m%d)
- Target Namespace: restored-app-namespace
- Restoration Method: Cross-cluster restore

VERIFICATION RESULTS:
EOF

# Add deployment status
echo "Deployments Status:" >> restoration-report.txt
oc get deployments -n restored-app-namespace >> restoration-report.txt

# Add service status
echo -e "\nServices Status:" >> restoration-report.txt
oc get services -n restored-app-namespace >> restoration-report.txt

# Add PVC status
echo -e "\nPersistent Volume Claims:" >> restoration-report.txt
oc get pvc -n restored-app-namespace >> restoration-report.txt

# Display the report
cat restoration-report.txt
Troubleshooting Common Issues
Issue 1: Restore Stuck in Progress
Symptoms: Restore operation remains in "InProgress" state for extended periods.

Solution:

# Check Velero logs
oc logs -n openshift-adp deployment/velero -f

# Verify backup storage connectivity
oc describe backupstoragelocation -n openshift-adp

# Check for resource conflicts
oc get events -n restored-app-namespace --sort-by='.lastTimestamp'
Issue 2: Persistent Volume Restoration Failures
Symptoms: PVCs remain in "Pending" state after restoration.

Solution:

# Check storage class availability
oc get storageclass

# Verify PV provisioner
oc describe pvc sample-app-data -n restored-app-namespace

# Check node storage capacity
oc describe nodes | grep -A 5 "Allocated resources"
Issue 3: Application Connectivity Issues
Symptoms: Application pods are running but not accessible.

Solution:

# Verify service endpoints
oc get endpoints -n restored-app-namespace

# Check network policies
oc get networkpolicies -n restored-app-namespace

# Test pod-to-pod connectivity
oc exec -it test-pod -- ping sample-app-service.restored-app-namespace.svc.cluster.local
Conclusion
In this comprehensive lab, you have successfully:

• Mastered OpenShift Application Restoration: You learned how to perform complete application restoration from backups using OADP and Velero, understanding the critical components involved in disaster recovery scenarios.

• Executed Cross-Cluster and Cross-Namespace Restoration: You gained hands-on experience with complex restoration scenarios, including restoring applications to different clusters and namespaces, which is essential for disaster recovery and migration strategies.

• Implemented Comprehensive Verification Procedures: You developed skills to thoroughly validate restored applications, ensuring data integrity, configuration accuracy, and functional correctness through systematic testing approaches.

• Applied Enterprise-Grade Disaster Recovery Practices: You learned industry best practices for backup and restoration operations that are crucial for maintaining business continuity in production OpenShift environments.

Why This Matters: In enterprise environments, the ability to quickly and reliably restore applications from backups is critical for business continuity. The skills you've developed in this lab directly apply to real-world scenarios where system failures, data corruption, or disaster events require immediate recovery actions. Understanding cross-cluster restoration capabilities also prepares you for complex migration and disaster recovery strategies that span multiple data centers or cloud regions.

These restoration techniques are fundamental requirements for Red Hat OpenShift Administration III certification and are essential skills for any OpenShift administrator responsible for maintaining production workloads. The verification procedures you've learned ensure that restored applications meet the same reliability and performance standards as the original deployments, which is crucial for maintaining service level agreements in enterprise environments.
