Lab 7: Cluster Partitioning with Node Labels
Objectives
By the end of this lab, you will be able to:

• Apply node labels to specific OpenShift nodes for workload organization • Assign workloads to specific nodes using node selectors • Create and manage taints and tolerations to control pod scheduling • Implement cluster partitioning strategies for enterprise environments • Understand the relationship between node labels, selectors, taints, and tolerations • Configure workload isolation and resource allocation across cluster nodes

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes/OpenShift concepts (pods, nodes, deployments) • Familiarity with YAML configuration files • Knowledge of command-line interface operations • Understanding of OpenShift cluster architecture • Access to OpenShift CLI (oc) commands • Basic Linux command-line skills

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with OpenShift pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install OpenShift manually.

Your lab environment includes: • Multi-node OpenShift cluster (1 master, 3 worker nodes) • Pre-configured OpenShift CLI (oc) • Administrative access to the cluster • Sample applications for testing

Task 1: Apply Node Labels to Specific OpenShift Nodes
Node labels are key-value pairs that help categorize and organize nodes in your cluster. They enable you to group nodes based on hardware characteristics, geographical location, or intended workload types.

Subtask 1.1: Examine Current Node Configuration
First, let's explore the existing nodes in your cluster and their current labels.

List all nodes in the cluster:
oc get nodes
View detailed information about nodes including labels:
oc get nodes --show-labels
Examine a specific node's labels in detail:
oc describe node <node-name>
Replace <node-name> with an actual worker node name from your cluster output.

Subtask 1.2: Apply Custom Labels to Nodes
Now we'll add meaningful labels to categorize our nodes for different purposes.

Label nodes based on environment type:
# Label first worker node as production environment
oc label node <worker-node-1> environment=production

# Label second worker node as development environment
oc label node <worker-node-2> environment=development

# Label third worker node as testing environment
oc label node <worker-node-3> environment=testing
Label nodes based on hardware characteristics:
# Label nodes with disk type information
oc label node <worker-node-1> disk-type=ssd
oc label node <worker-node-2> disk-type=hdd
oc label node <worker-node-3> disk-type=ssd
Label nodes based on workload specialization:
# Label nodes for specific workload types
oc label node <worker-node-1> workload=database
oc label node <worker-node-2> workload=web-frontend
oc label node <worker-node-3> workload=compute-intensive
Verify the labels have been applied:
oc get nodes --show-labels | grep -E "(environment|disk-type|workload)"
Subtask 1.3: Create a Node Label Management Script
Create a script to manage node labels efficiently:

Create a label management script:
cat > node-label-manager.sh << 'EOF'
#!/bin/bash

# Node Label Management Script
echo "OpenShift Node Label Manager"
echo "============================"

# Function to list all nodes with custom labels
list_labeled_nodes() {
    echo "Current node labels:"
    oc get nodes -o custom-columns=NAME:.metadata.name,ENVIRONMENT:.metadata.labels.environment,DISK-TYPE:.metadata.labels.disk-type,WORKLOAD:.metadata.labels.workload
}

# Function to add environment label
add_environment_label() {
    local node=$1
    local env=$2
    echo "Adding environment label '$env' to node '$node'"
    oc label node $node environment=$env --overwrite
}

# Function to remove labels
remove_label() {
    local node=$1
    local label=$2
    echo "Removing label '$label' from node '$node'"
    oc label node $node $label-
}

# Main menu
case $1 in
    "list")
        list_labeled_nodes
        ;;
    "add-env")
        add_environment_label $2 $3
        ;;
    "remove")
        remove_label $2 $3
        ;;
    *)
        echo "Usage: $0 {list|add-env <node> <environment>|remove <node> <label>}"
        echo "Examples:"
        echo "  $0 list"
        echo "  $0 add-env worker-1 production"
        echo "  $0 remove worker-1 environment"
        ;;
esac
EOF

chmod +x node-label-manager.sh
Test the script:
# List current labels
./node-label-manager.sh list

# Add a new environment label
./node-label-manager.sh add-env <worker-node-1> staging
Task 2: Assign Workloads to Nodes Using Node Selectors
Node selectors allow you to constrain pods to run on specific nodes based on labels. This is essential for workload placement and resource optimization.

Subtask 2.1: Create Applications with Node Selectors
Create a production database application:
cat > production-database.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: production-database
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: production-database
  template:
    metadata:
      labels:
        app: production-database
    spec:
      nodeSelector:
        environment: production
        workload: database
      containers:
      - name: database
        image: registry.redhat.io/rhel8/mysql-80:latest
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "rootpassword"
        - name: MYSQL_DATABASE
          value: "proddb"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        ports:
        - containerPort: 3306
EOF
Create a development web application:
cat > development-webapp.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: development-webapp
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: development-webapp
  template:
    metadata:
      labels:
        app: development-webapp
    spec:
      nodeSelector:
        environment: development
        workload: web-frontend
      containers:
      - name: webapp
        image: registry.redhat.io/ubi8/httpd-24:latest
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        ports:
        - containerPort: 8080
EOF
Create a compute-intensive testing application:
cat > testing-compute.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: testing-compute
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: testing-compute
  template:
    metadata:
      labels:
        app: testing-compute
    spec:
      nodeSelector:
        environment: testing
        workload: compute-intensive
        disk-type: ssd
      containers:
      - name: compute-app
        image: registry.redhat.io/ubi8/ubi:latest
        command: ["/bin/bash"]
        args: ["-c", "while true; do echo 'Computing...'; sleep 30; done"]
        resources:
          requests:
            memory: "256Mi"
            cpu: "500m"
          limits:
            memory: "512Mi"
            cpu: "1000m"
EOF
Subtask 2.2: Deploy and Verify Node Selector Functionality
Deploy all applications:
oc apply -f production-database.yaml
oc apply -f development-webapp.yaml
oc apply -f testing-compute.yaml
Verify pod placement:
# Check where pods are scheduled
oc get pods -o wide

# Get detailed information about pod scheduling
oc describe pod -l app=production-database
oc describe pod -l app=development-webapp
oc describe pod -l app=testing-compute
Create a monitoring script to track pod placement:
cat > pod-placement-monitor.sh << 'EOF'
#!/bin/bash

echo "Pod Placement Monitor"
echo "===================="
echo ""

# Function to show pod placement
show_placement() {
    echo "Current Pod Placement:"
    echo "----------------------"
    oc get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,APP:.metadata.labels.app --no-headers | while read pod node app; do
        if [ ! -z "$node" ]; then
            env_label=$(oc get node $node -o jsonpath='{.metadata.labels.environment}' 2>/dev/null)
            workload_label=$(oc get node $node -o jsonpath='{.metadata.labels.workload}' 2>/dev/null)
            echo "Pod: $pod | Node: $node | Environment: $env_label | Workload: $workload_label"
        fi
    done
    echo ""
}

# Function to show node selector compliance
check_compliance() {
    echo "Node Selector Compliance Check:"
    echo "--------------------------------"
    
    # Check production database
    prod_db_node=$(oc get pod -l app=production-database -o jsonpath='{.items[0].spec.nodeName}' 2>/dev/null)
    if [ ! -z "$prod_db_node" ]; then
        prod_env=$(oc get node $prod_db_node -o jsonpath='{.metadata.labels.environment}' 2>/dev/null)
        prod_workload=$(oc get node $prod_db_node -o jsonpath='{.metadata.labels.workload}' 2>/dev/null)
        echo "Production DB: Environment=$prod_env, Workload=$prod_workload"
    fi
    
    # Check development webapp
    dev_webapp_node=$(oc get pod -l app=development-webapp -o jsonpath='{.items[0].spec.nodeName}' 2>/dev/null)
    if [ ! -z "$dev_webapp_node" ]; then
        dev_env=$(oc get node $dev_webapp_node -o jsonpath='{.metadata.labels.environment}' 2>/dev/null)
        dev_workload=$(oc get node $dev_webapp_node -o jsonpath='{.metadata.labels.workload}' 2>/dev/null)
        echo "Development WebApp: Environment=$dev_env, Workload=$dev_workload"
    fi
    
    # Check testing compute
    test_compute_node=$(oc get pod -l app=testing-compute -o jsonpath='{.items[0].spec.nodeName}' 2>/dev/null)
    if [ ! -z "$test_compute_node" ]; then
        test_env=$(oc get node $test_compute_node -o jsonpath='{.metadata.labels.environment}' 2>/dev/null)
        test_workload=$(oc get node $test_compute_node -o jsonpath='{.metadata.labels.workload}' 2>/dev/null)
        test_disk=$(oc get node $test_compute_node -o jsonpath='{.metadata.labels.disk-type}' 2>/dev/null)
        echo "Testing Compute: Environment=$test_env, Workload=$test_workload, Disk=$test_disk"
    fi
}

show_placement
check_compliance
EOF

chmod +x pod-placement-monitor.sh
Run the monitoring script:
./pod-placement-monitor.sh
Subtask 2.3: Test Node Selector Constraints
Create an application with impossible node selector requirements:
cat > impossible-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: impossible-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: impossible-app
  template:
    metadata:
      labels:
        app: impossible-app
    spec:
      nodeSelector:
        environment: production
        workload: non-existent
      containers:
      - name: test-app
        image: registry.redhat.io/ubi8/ubi:latest
        command: ["/bin/bash"]
        args: ["-c", "while true; do echo 'Running...'; sleep 60; done"]
EOF
Deploy and observe the scheduling failure:
oc apply -f impossible-app.yaml

# Check pod status
oc get pods -l app=impossible-app

# Examine why the pod is not scheduled
oc describe pod -l app=impossible-app
Clean up the impossible application:
oc delete -f impossible-app.yaml
Task 3: Create Taints and Tolerations
Taints and tolerations work together to ensure that pods are not scheduled onto inappropriate nodes. Taints are applied to nodes, and tolerations are applied to pods.

Subtask 3.1: Understanding and Applying Taints
Taints have three effects:

NoSchedule: Pods will not be scheduled on the node
PreferNoSchedule: System will try to avoid scheduling pods on the node
NoExecute: Pods will not be scheduled on the node and existing pods will be evicted
Apply taints to nodes:
# Taint the production node to only allow production workloads
oc adm taint node <worker-node-1> dedicated=production:NoSchedule

# Taint the development node with a preference against scheduling
oc adm taint node <worker-node-2> environment=development:PreferNoSchedule

# Taint the testing node to prevent non-testing workloads
oc adm taint node <worker-node-3> testing-only=true:NoExecute
Verify taints have been applied:
# Check taints on all nodes
oc describe nodes | grep -A 5 -B 5 Taints

# Check specific node taints
oc describe node <worker-node-1> | grep Taints
oc describe node <worker-node-2> | grep Taints
oc describe node <worker-node-3> | grep Taints
Subtask 3.2: Create Applications with Tolerations
Create a production application with appropriate tolerations:
cat > production-app-with-toleration.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: production-app-toleration
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: production-app-toleration
  template:
    metadata:
      labels:
        app: production-app-toleration
    spec:
      nodeSelector:
        environment: production
      tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "production"
        effect: "NoSchedule"
      containers:
      - name: prod-app
        image: registry.redhat.io/ubi8/httpd-24:latest
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        ports:
        - containerPort: 8080
EOF
Create a testing application with testing tolerations:
cat > testing-app-with-toleration.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: testing-app-toleration
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: testing-app-toleration
  template:
    metadata:
      labels:
        app: testing-app-toleration
    spec:
      nodeSelector:
        environment: testing
      tolerations:
      - key: "testing-only"
        operator: "Equal"
        value: "true"
        effect: "NoExecute"
      containers:
      - name: test-app
        image: registry.redhat.io/ubi8/ubi:latest
        command: ["/bin/bash"]
        args: ["-c", "while true; do echo 'Testing application running...'; sleep 30; done"]
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
EOF
Create an application without tolerations to test taint enforcement:
cat > no-toleration-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: no-toleration-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: no-toleration-app
  template:
    metadata:
      labels:
        app: no-toleration-app
    spec:
      containers:
      - name: basic-app
        image: registry.redhat.io/ubi8/ubi:latest
        command: ["/bin/bash"]
        args: ["-c", "while true; do echo 'Basic application running...'; sleep 60; done"]
EOF
Subtask 3.3: Deploy and Test Taint/Toleration Behavior
Deploy all applications:
oc apply -f production-app-with-toleration.yaml
oc apply -f testing-app-with-toleration.yaml
oc apply -f no-toleration-app.yaml
Monitor pod scheduling behavior:
# Check pod status and placement
oc get pods -o wide

# Check for any pending pods
oc get pods | grep Pending

# Describe pending pods to understand scheduling issues
oc describe pod -l app=no-toleration-app
Create a comprehensive taint and toleration monitoring script:
cat > taint-toleration-monitor.sh << 'EOF'
#!/bin/bash

echo "Taint and Toleration Monitor"
echo "============================"
echo ""

# Function to show node taints
show_taints() {
    echo "Node Taints:"
    echo "------------"
    for node in $(oc get nodes -o name | cut -d/ -f2); do
        echo "Node: $node"
        taints=$(oc describe node $node | grep "Taints:" | cut -d: -f2- | xargs)
        if [ -z "$taints" ] || [ "$taints" = "<none>" ]; then
            echo "  No taints"
        else
            echo "  Taints: $taints"
        fi
        echo ""
    done
}

# Function to show pod tolerations and scheduling
show_tolerations() {
    echo "Pod Tolerations and Scheduling:"
    echo "-------------------------------"
    
    for pod in $(oc get pods -o name); do
        pod_name=$(echo $pod | cut -d/ -f2)
        app_label=$(oc get $pod -o jsonpath='{.metadata.labels.app}' 2>/dev/null)
        node_name=$(oc get $pod -o jsonpath='{.spec.nodeName}' 2>/dev/null)
        phase=$(oc get $pod -o jsonpath='{.status.phase}' 2>/dev/null)
        
        echo "Pod: $pod_name (App: $app_label)"
        echo "  Status: $phase"
        if [ ! -z "$node_name" ]; then
            echo "  Scheduled on: $node_name"
        else
            echo "  Not scheduled"
        fi
        
        # Show tolerations
        tolerations=$(oc get $pod -o jsonpath='{.spec.tolerations}' 2>/dev/null)
        if [ "$tolerations" != "null" ] && [ ! -z "$tolerations" ]; then
            echo "  Has tolerations: Yes"
        else
            echo "  Has tolerations: No"
        fi
        echo ""
    done
}

# Function to check scheduling issues
check_scheduling_issues() {
    echo "Scheduling Issues:"
    echo "------------------"
    
    pending_pods=$(oc get pods --field-selector=status.phase=Pending -o name 2>/dev/null)
    if [ -z "$pending_pods" ]; then
        echo "No pending pods found."
    else
        echo "Pending pods detected:"
        for pod in $pending_pods; do
            pod_name=$(echo $pod | cut -d/ -f2)
            echo "  - $pod_name"
            # Get the reason for pending
            reason=$(oc describe $pod | grep -A 10 "Events:" | grep "FailedScheduling" | tail -1)
            if [ ! -z "$reason" ]; then
                echo "    Reason: $reason"
            fi
        done
    fi
    echo ""
}

show_taints
show_tolerations
check_scheduling_issues
EOF

chmod +x taint-toleration-monitor.sh
Run the monitoring script:
./taint-toleration-monitor.sh
Subtask 3.4: Advanced Taint and Toleration Scenarios
Create a toleration with wildcard matching:
cat > wildcard-toleration-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wildcard-toleration-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wildcard-toleration-app
  template:
    metadata:
      labels:
        app: wildcard-toleration-app
    spec:
      tolerations:
      - key: "dedicated"
        operator: "Exists"
        effect: "NoSchedule"
      - key: "environment"
        operator: "Exists"
        effect: "PreferNoSchedule"
      containers:
      - name: flexible-app
        image: registry.redhat.io/ubi8/ubi:latest
        command: ["/bin/bash"]
        args: ["-c", "while true; do echo 'Flexible application running...'; sleep 45; done"]
EOF
Deploy and test the wildcard toleration:
oc apply -f wildcard-toleration-app.yaml

# Monitor where it gets scheduled
oc get pods -l app=wildcard-toleration-app -o wide
Create a time-limited toleration:
cat > time-limited-toleration.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: time-limited-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: time-limited-app
  template:
    metadata:
      labels:
        app: time-limited-app
    spec:
      tolerations:
      - key: "testing-only"
        operator: "Equal"
        value: "true"
        effect: "NoExecute"
        tolerationSeconds: 300
      containers:
      - name: temp-app
        image: registry.redhat.io/ubi8/ubi:latest
        command: ["/bin/bash"]
        args: ["-c", "while true; do echo 'Temporary application - will be evicted in 5 minutes'; sleep 30; done"]
EOF
Deploy and observe time-limited behavior:
oc apply -f time-limited-toleration.yaml

# Watch the pod for 5 minutes to see eviction
watch oc get pods -l app=time-limited-app
Subtask 3.5: Managing and Removing Taints
Create a script to manage taints:
cat > taint-manager.sh << 'EOF'
#!/bin/bash

# Taint Management Script
echo "OpenShift Taint Manager"
echo "======================"

# Function to list all taints
list_taints() {
    echo "Current Node Taints:"
    echo "-------------------"
    for node in $(oc get nodes -o name | cut -d/ -f2); do
        echo "Node: $node"
        oc describe node $node | grep "Taints:" | sed 's/Taints:/  /'
        echo ""
    done
}

# Function to add taint
add_taint() {
    local node=$1
    local key=$2
    local value=$3
    local effect=$4
    
    if [ -z "$node" ] || [ -z "$key" ] || [ -z "$effect" ]; then
        echo "Usage: add_taint <node> <key> <value> <effect>"
        echo "Effects: NoSchedule, PreferNoSchedule, NoExecute"
        return 1
    fi
    
    if [ -z "$value" ]; then
        echo "Adding taint $key:$effect to node $node"
        oc adm taint node $node $key:$effect
    else
        echo "Adding taint $key=$value:$effect to node $node"
        oc adm taint node $node $key=$value:$effect
    fi
}

# Function to remove taint
remove_taint() {
    local node=$1
    local key=$2
    
    if [ -z "$node" ] || [ -z "$key" ]; then
        echo "Usage: remove_taint <node> <key>"
        return 1
    fi
    
    echo "Removing taint with key '$key' from node '$node'"
    oc adm taint node $node $key-
}

# Function to remove all taints from a node
remove_all_taints() {
    local node=$1
    
    if [ -z "$node" ]; then
        echo "Usage: remove_all_taints <node>"
        return 1
    fi
    
    echo "Removing all taints from node '$node'"
    # Get all taint keys for the node
    taint_keys=$(oc describe node $node | grep "Taints:" | cut -d: -f2- | tr ',' '\n' | cut -d= -f1 | cut -d: -f1 | xargs)
    
    for key in $taint_keys; do
        if [ "$key" != "<none>" ] && [ ! -z "$key" ]; then
            echo "  Removing taint key: $key"
            oc adm taint node $node $key- 2>/dev/null || true
        fi
    done
}

# Main menu
case $1 in
    "list")
        list_taints
        ;;
    "add")
        add_taint $2 $3 $4 $5
        ;;
    "remove")
        remove_taint $2 $3
        ;;
    "remove-all")
        remove_all_taints $2
        ;;
    *)
        echo "Usage: $0 {list|add|remove|remove-all}"
        echo ""
        echo "Commands:"
        echo "  list                           - List all node taints"
        echo "  add <node> <key> <value> <effect> - Add taint to node"
        echo "  remove <node> <key>            - Remove specific taint from node"
        echo "  remove-all <node>              - Remove all taints from node"
        echo ""
        echo "Examples:"
        echo "  $0 list"
        echo "  $0 add worker-1 dedicated production NoSchedule"
        echo "  $0 remove worker-1 dedicated"
        echo "  $0 remove-all worker-1"
        ;;
esac
EOF

chmod +x taint-manager.sh
Test the taint management script:
# List current taints
./taint-manager.sh list

# Add a new taint
./taint-manager.sh add <worker-node-2> maintenance true NoSchedule

# Remove a specific taint
./taint-manager.sh remove <worker-node-2> maintenance
Troubleshooting Common Issues
Issue 1: Pods Stuck in Pending State
Symptoms: Pods remain in Pending state and never get scheduled.

Diagnosis:

# Check pod events
oc describe pod <pod-name>

# Look for scheduling failures in events
oc get events --sort-by=.metadata.creationTimestamp
Solutions:

Verify node labels match nodeSelector requirements
Check if nodes have appropriate tolerations for taints
Ensure nodes have sufficient resources
Issue 2: Pods Scheduled on Wrong Nodes
Symptoms: Pods are running on nodes that don't match the intended placement.

Diagnosis:

# Check node labels
oc get nodes --show-labels

# Verify pod nodeSelector configuration
oc get pod <pod-name> -o yaml | grep -A 10 nodeSelector
Solutions:

Verify node labels are correctly applied
Check nodeSelector syntax in pod specifications
Ensure no conflicting scheduling policies
Issue 3: Taint Effects Not Working
Symptoms: Pods are scheduled on tainted nodes despite lacking tolerations.

Diagnosis:

# Check node taints
oc describe node <node-name> | grep Taints

# Verify pod tolerations
oc get pod <pod-name> -o yaml | grep -A 20 tolerations
Solutions:

Verify taint syntax and effects
Check toleration key, value, and effect matching
Ensure taint effects are appropriate (NoSchedule vs PreferNoSchedule vs NoExecute)
Lab Cleanup
Before concluding the lab, clean up the resources created:

# Remove all deployments
oc delete deployment production-database development-webapp testing-compute
oc delete deployment production-app-toleration testing-app-toleration no-toleration-app
oc delete deployment wildcard-toleration-app time-limited-app

# Remove taints from nodes (replace with actual node names)
./taint-manager.sh remove-all <worker-node-1>
./taint-manager.sh remove-all <worker-node-2>
./taint-manager.sh remove-all <worker-node-3>

# Remove custom labels (optional - you may want to keep them for future labs)
oc label node <worker-node-1> environment- disk-type- workload-
oc label node <worker-node-2> environment- disk-type- workload-
oc label node <worker-node-3> environment- disk-type- workload-

# Remove created files
rm -f *.yaml *.sh
Conclusion
In this comprehensive lab, you have successfully learned and implemented cluster partitioning techniques using node labels, node selectors, taints, and tolerations. Here's what you accomplished:

Key Achievements:

• Node Labeling: Applied meaningful labels to categorize nodes based on environment, hardware characteristics, and workload specialization • Workload Placement: Used node selectors to ensure applications run on appropriate nodes based on their requirements • Resource Isolation: Implemented taints and tolerations to create dedicated node pools and prevent unwanted workload placement • Automation: Created management scripts for efficient node label and taint administration • Monitoring: Developed monitoring tools to track pod placement and scheduling compliance

Why This Matters:

Cluster partitioning is crucial for enterprise OpenShift deployments because it enables:

Resource Optimization: Ensures workloads run on nodes with appropriate hardware characteristics
Security Isolation: Separates sensitive production workloads from development and testing environments
Performance Guarantees: Dedicates specific nodes to high-performance applications
Cost Management: Optimizes resource utilization across different node types and pricing tiers
Compliance: Meets regulatory requirements for workload isolation and data separation
Real-World Applications:

The techniques you've learned are essential for:

Multi-tenant cluster management
Hybrid cloud deployments
