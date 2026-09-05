Lab 6: Migrating Applications Between Clusters
Objectives
By the end of this lab, students will be able to:

• Understand the fundamentals of application migration between OpenShift clusters • Create comprehensive backups of running applications including configurations, data, and resources • Restore applications to different OpenShift clusters using open-source tools • Verify application functionality and data integrity after migration • Implement best practices for cross-cluster application migration • Troubleshoot common migration issues and validate successful deployments

Prerequisites
Before starting this lab, students should have:

• Basic knowledge of OpenShift/Kubernetes concepts (pods, services, deployments) • Familiarity with command-line interface operations • Understanding of YAML configuration files • Basic knowledge of container concepts and Docker • Experience with oc (OpenShift CLI) commands • Understanding of persistent volumes and storage concepts

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with all necessary tools installed. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • Two OpenShift clusters (source and destination) • Pre-installed OpenShift CLI (oc) • Sample application for migration • All necessary backup and restore tools

Task 1: Perform a Backup of a Running Application
Subtask 1.1: Access the Source Cluster and Examine the Application
First, let's connect to our source OpenShift cluster and examine the running application.

Login to the source OpenShift cluster:
# Login to source cluster
oc login https://source-cluster-api:6443 --username=admin --password=admin123

# Verify cluster connection
oc cluster-info
Create a sample application for migration:
# Create a new project
oc new-project migration-demo

# Deploy a sample web application with database
oc new-app --name=webapp \
  --image=registry.redhat.io/ubi8/nodejs-16:latest \
  --code=https://github.com/sclorg/nodejs-ex.git

# Deploy PostgreSQL database
oc new-app postgresql-persistent \
  --param=POSTGRESQL_USER=webapp \
  --param=POSTGRESQL_PASSWORD=webapp123 \
  --param=POSTGRESQL_DATABASE=webappdb \
  --param=VOLUME_CAPACITY=1Gi

# Wait for deployments to complete
oc get pods -w
Examine the application components:
# List all resources in the project
oc get all

# Check persistent volume claims
oc get pvc

# View configuration maps and secrets
oc get configmaps,secrets
Subtask 1.2: Create Application Configuration Backup
Now we'll create a comprehensive backup of all application configurations.

Create backup directory structure:
# Create backup directory
mkdir -p ~/app-backup/migration-demo/{configs,data}
cd ~/app-backup/migration-demo
Export all application configurations:
# Export deployments
oc get deployments -o yaml > configs/deployments.yaml

# Export services
oc get services -o yaml > configs/services.yaml

# Export routes
oc get routes -o yaml > configs/routes.yaml

# Export persistent volume claims
oc get pvc -o yaml > configs/pvc.yaml

# Export config maps (excluding system ones)
oc get configmaps -o yaml --field-selector metadata.name!=kube-root-ca.crt > configs/configmaps.yaml

# Export secrets (excluding system ones)
oc get secrets -o yaml --field-selector type!=kubernetes.io/service-account-token > configs/secrets.yaml

# Export image streams
oc get imagestreams -o yaml > configs/imagestreams.yaml
Create a comprehensive backup script:
# Create backup script
cat > backup-app.sh << 'EOF'
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
EOF

# Make script executable and run it
chmod +x backup-app.sh
./backup-app.sh
Subtask 1.3: Backup Application Data
For applications with persistent data, we need to backup the actual data stored in persistent volumes.

Identify persistent volumes and data:
# List persistent volume claims
oc get pvc

# Check which pods are using persistent storage
oc get pods -o wide
Create database backup:
# Get PostgreSQL pod name
POSTGRES_POD=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')

# Create database dump
oc exec ${POSTGRES_POD} -- pg_dump -U webapp webappdb > data/database-backup.sql

echo "Database backup created: data/database-backup.sql"
Backup persistent volume data (if applicable):
# For file-based persistent volumes, create a backup job
cat > data-backup-job.yaml << 'EOF'
apiVersion: batch/v1
kind: Job
metadata:
  name: data-backup-job
spec:
  template:
    spec:
      containers:
      - name: backup
        image: registry.redhat.io/ubi8/ubi:latest
        command: ["/bin/bash"]
        args:
        - -c
        - |
          echo "Starting data backup..."
          if [ -d "/data" ]; then
            tar -czf /backup/data-backup.tar.gz -C /data .
            echo "Data backup completed"
          else
            echo "No data directory found"
          fi
        volumeMounts:
        - name: data-volume
          mountPath: /data
        - name: backup-volume
          mountPath: /backup
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: postgresql
      - name: backup-volume
        emptyDir: {}
      restartPolicy: Never
EOF

# Apply the backup job (if needed)
# oc apply -f data-backup-job.yaml
Task 2: Restore the Application to a Different OpenShift Cluster
Subtask 2.1: Prepare the Destination Cluster
Now we'll switch to the destination cluster and prepare it for the application migration.

Login to the destination cluster:
# Login to destination cluster
oc login https://destination-cluster-api:6443 --username=admin --password=admin123

# Verify cluster connection
oc cluster-info
oc get nodes
Create the target project:
# Create the same project name on destination cluster
oc new-project migration-demo

# Verify project creation
oc project migration-demo
Prepare the environment for restoration:
# Create restoration directory
mkdir -p ~/app-restore/migration-demo
cd ~/app-restore/migration-demo

# Copy backup files (in real scenario, you'd transfer these files)
cp -r ~/app-backup/migration-demo/* .
Subtask 2.2: Clean and Prepare Configuration Files
Before applying the configurations, we need to clean them up for the new cluster.

Create a configuration cleanup script:
cat > cleanup-configs.sh << 'EOF'
#!/bin/bash

echo "Cleaning up configuration files for new cluster..."

# Function to clean YAML files
clean_yaml() {
    local file=$1
    echo "Cleaning $file..."
    
    # Remove cluster-specific metadata
    yq eval 'del(.items[].metadata.uid)' -i $file
    yq eval 'del(.items[].metadata.resourceVersion)' -i $file
    yq eval 'del(.items[].metadata.generation)' -i $file
    yq eval 'del(.items[].metadata.creationTimestamp)' -i $file
    yq eval 'del(.items[].metadata.selfLink)' -i $file
    yq eval 'del(.items[].status)' -i $file
    
    # Remove annotations that might cause conflicts
    yq eval 'del(.items[].metadata.annotations."deployment.kubernetes.io/revision")' -i $file
    yq eval 'del(.items[].metadata.annotations."kubectl.kubernetes.io/last-applied-configuration")' -i $file
}

# Install yq if not present
if ! command -v yq &> /dev/null; then
    echo "Installing yq..."
    wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    chmod +x /usr/local/bin/yq
fi

# Clean all configuration files
for file in configs/*.yaml; do
    if [ -f "$file" ]; then
        clean_yaml "$file"
    fi
done

echo "Configuration cleanup completed!"
EOF

chmod +x cleanup-configs.sh
./cleanup-configs.sh
Manual cleanup for specific resources:
# Create a more thorough cleanup script for complex scenarios
cat > advanced-cleanup.sh << 'EOF'
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
EOF

chmod +x advanced-cleanup.sh
./advanced-cleanup.sh
Subtask 2.3: Restore Application Components
Now we'll restore the application components in the correct order.

Create restoration script:
cat > restore-app.sh << 'EOF'
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
EOF

chmod +x restore-app.sh
./restore-app.sh
Monitor the restoration process:
# Watch pods coming up
oc get pods -w

# Check deployment status
oc get deployments

# Verify services are created
oc get services

# Check routes
oc get routes
Subtask 2.4: Restore Application Data
Now we need to restore the application data, particularly the database.

Wait for database pod to be ready:
# Wait for PostgreSQL pod to be running
oc wait --for=condition=Ready pod -l name=postgresql --timeout=300s

# Get the new PostgreSQL pod name
POSTGRES_POD=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')
echo "PostgreSQL pod: ${POSTGRES_POD}"
Restore database data:
# Copy database backup to the pod
oc cp data/database-backup.sql ${POSTGRES_POD}:/tmp/

# Restore the database
oc exec ${POSTGRES_POD} -- psql -U webapp -d webappdb -f /tmp/database-backup.sql

echo "Database restoration completed!"
Verify data restoration:
# Check database contents
oc exec ${POSTGRES_POD} -- psql -U webapp -d webappdb -c "\dt"
oc exec ${POSTGRES_POD} -- psql -U webapp -d webappdb -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"
Task 3: Verify that the Application Functions in the New Cluster
Subtask 3.1: Perform Basic Functionality Tests
Let's verify that our migrated application is working correctly in the new cluster.

Check all pods are running:
# Verify all pods are in Running state
oc get pods

# Check pod logs for any errors
oc logs -l app=webapp --tail=50
oc logs -l name=postgresql --tail=50
Test internal connectivity:
# Test database connectivity from webapp
WEBAPP_POD=$(oc get pods -l app=webapp -o jsonpath='{.items[0].metadata.name}')

# Test database connection
oc exec ${WEBAPP_POD} -- curl -s http://postgresql:5432 || echo "Database connection test"
Verify services are accessible:
# Test service endpoints
oc get endpoints

# Check service connectivity
oc get services -o wide
Subtask 3.2: Test Application Accessibility
Now let's test that the application is accessible from outside the cluster.

Get application route:
# Get the application route
APP_ROUTE=$(oc get route webapp -o jsonpath='{.spec.host}')
echo "Application URL: http://${APP_ROUTE}"
Test application response:
# Test HTTP response
curl -I http://${APP_ROUTE}

# Test application content
curl -s http://${APP_ROUTE} | head -20
Create comprehensive testing script:
cat > test-migration.sh << 'EOF'
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
EOF

chmod +x test-migration.sh
./test-migration.sh
Subtask 3.3: Perform Data Integrity Verification
Let's verify that our data was migrated correctly and the application maintains its functionality.

Compare data between clusters:
# Create data verification script
cat > verify-data.sh << 'EOF'
#!/bin/bash

echo "=== Data Integrity Verification ==="

# Get PostgreSQL pod
POSTGRES_POD=$(oc get pods -l name=postgresql -o jsonpath='{.items[0].metadata.name}')

if [ -n "$POSTGRES_POD" ]; then
    echo "Checking database structure..."
    
    # Check tables
    echo "Database tables:"
    oc exec ${POSTGRES_POD} -- psql -U webapp -d webappdb -c "\dt"
    
    # Check data counts (if applicable)
    echo -e "\nChecking data integrity..."
    oc exec ${POSTGRES_POD} -- psql -U webapp -d webappdb -c "SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del FROM pg_stat_user_tables;"
    
    echo "✓ Database verification completed"
else
    echo "✗ Cannot find PostgreSQL pod for verification"
fi
EOF

chmod +x verify-data.sh
./verify-data.sh
Create final migration report:
cat > migration-report.sh << 'EOF'
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
EOF

chmod +x migration-report.sh
./migration-report.sh
Troubleshooting Common Issues
Issue 1: Pods Stuck in Pending State
Symptoms: Pods remain in Pending state after restoration.

Solution:

# Check pod events
oc describe pod <pod-name>

# Check node resources
oc describe nodes

# Check storage class availability
oc get storageclass

# If PVC issues, check PVC status
oc describe pvc
Issue 2: Database Connection Failures
Symptoms: Application cannot connect to database.

Solution:

# Check database pod logs
oc logs -l name=postgresql

# Verify database service
oc get svc postgresql

# Test database connectivity
oc exec <webapp-pod> -- nc -zv postgresql 5432

# Check database credentials in secrets
oc get secret postgresql -o yaml
Issue 3: Route/Ingress Not Working
Symptoms: Application not accessible from outside.

Solution:

# Check route configuration
oc describe route webapp

# Verify route host resolution
nslookup <route-host>

# Check if route is properly configured
oc get route webapp -o yaml

# Test internal service access
oc exec <test-pod> -- curl http://webapp:8080
Best Practices for Application Migration
Planning Phase
• Inventory all resources: Document all components, dependencies, and configurations • Identify data dependencies: Map all persistent volumes and external data sources • Plan migration order: Determine the sequence for migrating interdependent applications • Test migration process: Always test the migration process in a non-production environment

Execution Phase
• Use consistent naming: Maintain consistent project and resource names across clusters • Backup before migration: Always create comprehensive backups before starting migration • Monitor resource usage: Ensure destination cluster has adequate resources • Validate each step: Verify each component before proceeding to the next

Post-Migration Phase
• Comprehensive testing: Test all application functionality thoroughly • Performance validation: Compare performance metrics between clusters • Documentation updates: Update all documentation to reflect new cluster details • Monitoring setup: Ensure monitoring and alerting are configured for the new environment

Conclusion
In this lab, you have successfully completed a comprehensive application migration between OpenShift clusters. Here's what you accomplished:

Key Achievements: • Backup Creation: You learned how to create complete backups of running applications, including configurations, persistent data, and all associated resources • Configuration Management: You mastered the process of cleaning and preparing configuration files for deployment in different cluster environments • Application Restoration: You successfully restored a multi-component application (web application + database) to a new OpenShift cluster • Data Migration: You implemented database backup and restoration procedures to ensure data integrity across clusters • Verification and Testing: You performed comprehensive testing to validate that the migrated application functions correctly in its new environment

Why This Matters: Application migration between clusters is a critical skill in enterprise environments where organizations need to:

Move applications between development, staging, and production environments
Migrate workloads to new infrastructure or cloud providers
Implement disaster recovery procedures
Perform cluster upgrades or maintenance
Real-World Applications:

Disaster Recovery: Quickly restore applications in alternate data centers during outages
Cloud Migration: Move applications from on-premises to cloud or between cloud providers
Environment Promotion: Promote applications through development lifecycle stages
Infrastructure Modernization: Migrate applications to newer, more efficient cluster infrastructure
The skills you've developed in this lab provide a solid foundation for managing complex application migrations in production environments, ensuring business continuity and operational excellence in containerized application deployments.

Next Steps: Consider exploring advanced migration scenarios such as:

Cross-platform migrations (OpenShift to vanilla Kubernetes)
Large-scale multi-application migrations
Automated migration pipelines using CI/CD tools
Zero-downtime migration strategies
