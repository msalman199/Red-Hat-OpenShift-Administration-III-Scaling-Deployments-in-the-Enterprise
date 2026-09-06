Lab 8: Pod Scheduling with Affinity and Anti-Affinity
Objectives
By the end of this lab, you will be able to:

• Understand the concepts of pod affinity and anti-affinity in Kubernetes • Configure node affinity rules to control pod placement on specific nodes • Implement pod affinity rules to co-locate related pods • Create pod anti-affinity rules to distribute pods across different nodes • Test and validate scheduling behavior based on affinity and anti-affinity rules • Troubleshoot common scheduling issues related to affinity constraints

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, nodes, deployments) • Familiarity with YAML syntax and Kubernetes manifest files • Knowledge of kubectl command-line tool • Understanding of labels and selectors in Kubernetes • Completion of previous labs covering basic pod and deployment management

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with Kubernetes pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • Multi-node Kubernetes cluster (1 master, 3 worker nodes) • kubectl configured and ready to use • All necessary permissions for pod scheduling operations

Task 1: Define Affinity Rules for Pod Placement
Subtask 1.1: Examine Current Cluster Nodes
First, let's explore the available nodes in our cluster and understand their labels.

# List all nodes in the cluster
kubectl get nodes

# Show detailed information about nodes including labels
kubectl get nodes --show-labels

# Describe a specific node to see all its properties
kubectl describe node <node-name>
Subtask 1.2: Add Custom Labels to Nodes
We'll add custom labels to nodes to demonstrate affinity rules effectively.

# Label nodes with different zones
kubectl label nodes <worker-node-1> zone=east
kubectl label nodes <worker-node-2> zone=west
kubectl label nodes <worker-node-3> zone=central

# Label nodes with different disk types
kubectl label nodes <worker-node-1> disk=ssd
kubectl label nodes <worker-node-2> disk=hdd
kubectl label nodes <worker-node-3> disk=ssd

# Verify the labels were applied
kubectl get nodes --show-labels | grep -E "zone|disk"
Subtask 1.3: Create Pod with Node Affinity
Create a pod that must be scheduled on nodes with SSD storage using requiredDuringSchedulingIgnoredDuringExecution.

# Create file: node-affinity-required.yaml
apiVersion: v1
kind: Pod
metadata:
  name: ssd-required-pod
  labels:
    app: database
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disk
            operator: In
            values:
            - ssd
  containers:
  - name: database
    image: nginx:1.21
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
Apply the configuration:

# Apply the pod configuration
kubectl apply -f node-affinity-required.yaml

# Check where the pod was scheduled
kubectl get pods -o wide

# Verify the pod is running on an SSD node
kubectl describe pod ssd-required-pod | grep -A 5 "Node:"
Subtask 1.4: Create Pod with Preferred Node Affinity
Create a pod that prefers to be scheduled on nodes in the east zone but can be placed elsewhere if needed.

# Create file: node-affinity-preferred.yaml
apiVersion: v1
kind: Pod
metadata:
  name: east-preferred-pod
  labels:
    app: web-server
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values:
            - east
  containers:
  - name: web-server
    image: nginx:1.21
    resources:
      requests:
        memory: "32Mi"
        cpu: "100m"
      limits:
        memory: "64Mi"
        cpu: "200m"
Apply and test:

# Apply the pod configuration
kubectl apply -f node-affinity-preferred.yaml

# Check the scheduling result
kubectl get pods -o wide

# Describe the pod to see scheduling decisions
kubectl describe pod east-preferred-pod
Task 2: Define Anti-Affinity Rules to Prevent Certain Pods from Being Scheduled on the Same Node
Subtask 2.1: Create Deployment with Pod Anti-Affinity
Create a deployment where pods should not be scheduled on the same node to ensure high availability.

# Create file: pod-anti-affinity.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-ha
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
        tier: frontend
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - web-app
            topologyKey: kubernetes.io/hostname
      containers:
      - name: web-app
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
Deploy and verify:

# Apply the deployment
kubectl apply -f pod-anti-affinity.yaml

# Check pod distribution across nodes
kubectl get pods -l app=web-app -o wide

# Verify that pods are on different nodes
kubectl get pods -l app=web-app -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
Subtask 2.2: Create Soft Anti-Affinity Rules
Create a deployment with preferred anti-affinity that tries to spread pods but allows co-location if necessary.

# Create file: soft-anti-affinity.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cache-service
  labels:
    app: cache-service
spec:
  replicas: 4
  selector:
    matchLabels:
      app: cache-service
  template:
    metadata:
      labels:
        app: cache-service
        tier: cache
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - cache-service
              topologyKey: kubernetes.io/hostname
      containers:
      - name: cache
        image: redis:6.2-alpine
        ports:
        - containerPort: 6379
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
Deploy and analyze:

# Apply the deployment
kubectl apply -f soft-anti-affinity.yaml

# Check how pods are distributed
kubectl get pods -l app=cache-service -o wide

# Count pods per node
kubectl get pods -l app=cache-service -o custom-columns=NODE:.spec.nodeName --no-headers | sort | uniq -c
Task 3: Test Scheduling of Pods Based on Affinity and Anti-Affinity
Subtask 3.1: Create Pod Affinity Rules
Create pods that should be co-located with specific other pods using pod affinity.

# Create file: pod-affinity.yaml
apiVersion: v1
kind: Pod
metadata:
  name: database-pod
  labels:
    app: database
    tier: data
spec:
  containers:
  - name: database
    image: postgres:13
    env:
    - name: POSTGRES_PASSWORD
      value: "password123"
    resources:
      requests:
        memory: "256Mi"
        cpu: "200m"
      limits:
        memory: "512Mi"
        cpu: "400m"
---
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  labels:
    app: application
    tier: app
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - database
        topologyKey: kubernetes.io/hostname
  containers:
  - name: application
    image: nginx:1.21
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "200m"
Test pod affinity:

# Apply the pod configurations
kubectl apply -f pod-affinity.yaml

# Verify both pods are on the same node
kubectl get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName

# Check the scheduling events
kubectl describe pod app-pod | grep -A 10 "Events:"
Subtask 3.2: Test Complex Affinity Rules
Create a deployment that combines multiple affinity and anti-affinity rules.

# Create file: complex-affinity.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: complex-app
  labels:
    app: complex-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: complex-app
  template:
    metadata:
      labels:
        app: complex-app
        component: backend
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 50
            preference:
              matchExpressions:
              - key: disk
                operator: In
                values:
                - ssd
        podAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - database
              topologyKey: kubernetes.io/hostname
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - complex-app
            topologyKey: kubernetes.io/hostname
      containers:
      - name: backend
        image: nginx:1.21
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
Deploy and analyze:

# Apply the complex deployment
kubectl apply -f complex-affinity.yaml

# Check the scheduling results
kubectl get pods -l app=complex-app -o wide

# Analyze the scheduling decisions
kubectl describe pods -l app=complex-app | grep -A 15 "Events:"
Subtask 3.3: Test Scheduling Failures
Create a scenario where scheduling fails due to impossible constraints.

# Create file: impossible-affinity.yaml
apiVersion: v1
kind: Pod
metadata:
  name: impossible-pod
  labels:
    app: impossible
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: nonexistent-label
            operator: In
            values:
            - nonexistent-value
  containers:
  - name: app
    image: nginx:1.21
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
Test and troubleshoot:

# Apply the impossible configuration
kubectl apply -f impossible-affinity.yaml

# Check the pod status
kubectl get pods impossible-pod

# Examine why scheduling failed
kubectl describe pod impossible-pod

# Check scheduler events
kubectl get events --sort-by=.metadata.creationTimestamp | grep impossible-pod
Subtask 3.4: Monitor and Validate Scheduling Behavior
Create monitoring commands to validate affinity and anti-affinity rules are working correctly.

# Create a comprehensive monitoring script
cat > monitor-scheduling.sh << 'EOF'
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
EOF

chmod +x monitor-scheduling.sh
./monitor-scheduling.sh
Troubleshooting Common Issues
Issue 1: Pods Stuck in Pending State
# Check pod status and events
kubectl describe pod <pod-name>

# Look for scheduling failures
kubectl get events --field-selector involvedObject.name=<pod-name>

# Verify node labels exist
kubectl get nodes --show-labels | grep <expected-label>
Issue 2: Anti-Affinity Not Working
# Verify pod labels match the anti-affinity selector
kubectl get pods --show-labels

# Check if there are enough nodes to satisfy anti-affinity
kubectl get nodes

# Review the anti-affinity configuration
kubectl get pod <pod-name> -o yaml | grep -A 20 antiAffinity
Issue 3: Performance Impact
# Monitor scheduler performance
kubectl get events | grep -i schedule

# Check resource constraints
kubectl describe nodes | grep -A 5 "Allocated resources"

# Review pod resource requests
kubectl get pods -o custom-columns=NAME:.metadata.name,CPU-REQ:.spec.containers[*].resources.requests.cpu,MEM-REQ:.spec.containers[*].resources.requests.memory
Cleanup
Remove all resources created during this lab:

# Delete all pods and deployments
kubectl delete pod ssd-required-pod east-preferred-pod database-pod app-pod impossible-pod
kubectl delete deployment web-app-ha cache-service complex-app

# Remove custom labels from nodes
kubectl label nodes --all zone-
kubectl label nodes --all disk-

# Clean up files
rm -f node-affinity-required.yaml node-affinity-preferred.yaml pod-anti-affinity.yaml
rm -f soft-anti-affinity.yaml pod-affinity.yaml complex-affinity.yaml impossible-affinity.yaml
rm -f monitor-scheduling.sh

# Verify cleanup
kubectl get pods
kubectl get deployments
Conclusion
In this lab, you have successfully:

• Mastered Node Affinity: Learned to control pod placement on specific nodes using both required and preferred affinity rules • Implemented Pod Anti-Affinity: Created high-availability deployments by ensuring pods are distributed across different nodes • Configured Pod Affinity: Co-located related pods to improve performance and reduce network latency • Tested Complex Scenarios: Combined multiple affinity rules and handled scheduling failures • Developed Monitoring Skills: Created tools to validate and troubleshoot scheduling behavior

Why This Matters: Pod scheduling with affinity and anti-affinity is crucial for:

High Availability: Ensuring application resilience by distributing pods across failure domains
Performance Optimization: Co-locating related services to reduce latency
Resource Efficiency: Placing workloads on nodes with appropriate hardware characteristics
Compliance Requirements: Meeting regulatory or organizational constraints for data locality
These skills are essential for Red Hat OpenShift Administration and enterprise Kubernetes deployments, where proper pod scheduling directly impacts application performance, availability, and operational costs. Understanding these concepts prepares you for real-world scenarios where workload placement decisions can make the difference between a successful and failed deployment.
