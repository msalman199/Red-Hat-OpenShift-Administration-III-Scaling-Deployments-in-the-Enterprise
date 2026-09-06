Lab 11: OpenShift Monitoring with Prometheus
Objectives
By the end of this lab, you will be able to:

• Install and configure Prometheus on an OpenShift cluster • Set up Prometheus to collect metrics from OpenShift cluster components • Configure ServiceMonitor resources to scrape application metrics • Access and navigate the Prometheus web interface • Query and analyze cluster metrics using PromQL • Understand the relationship between Prometheus and OpenShift's built-in monitoring stack • Troubleshoot common Prometheus configuration issues

Prerequisites
Before starting this lab, you should have:

• Basic understanding of OpenShift/Kubernetes concepts (pods, services, deployments) • Familiarity with YAML configuration files • Basic knowledge of Linux command line operations • Understanding of monitoring concepts and metrics • Access to an OpenShift cluster with cluster-admin privileges • Basic knowledge of container orchestration principles

Ready-to-Use Cloud Machines
Al Nafi provides pre-configured Linux-based cloud machines with OpenShift already installed and configured. Simply click Start Lab to access your environment. No need to build your own VM or install OpenShift from scratch.

Your lab environment includes: • OpenShift 4.12+ cluster with administrative access • Pre-installed oc CLI tool • Network connectivity configured • All necessary permissions set up

Lab Environment Setup
Task 1: Verify OpenShift Cluster Access
Subtask 1.1: Connect to Your OpenShift Cluster
Open your terminal in the provided cloud machine
Verify your OpenShift cluster connection:
oc whoami
oc cluster-info
Check cluster nodes status:
oc get nodes
Verify you have cluster-admin privileges:
oc auth can-i '*' '*'
Expected output should show "yes" indicating administrative access.

Subtask 1.2: Explore Existing Monitoring Infrastructure
Check if OpenShift's built-in monitoring is already present:
oc get pods -n openshift-monitoring
List monitoring-related projects:
oc get projects | grep monitoring
Note: OpenShift 4.x includes a built-in monitoring stack with Prometheus. We'll install an additional Prometheus instance for learning purposes.

Task 2: Install Prometheus on OpenShift
Subtask 2.1: Create a Dedicated Project
Create a new project for our Prometheus installation:
oc new-project prometheus-lab
Verify the project creation:
oc project prometheus-lab
oc get project prometheus-lab
Subtask 2.2: Create Prometheus Configuration
Create a ConfigMap for Prometheus configuration:
cat << 'EOF' > prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: prometheus-lab
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    rule_files:
      # - "first_rules.yml"
      # - "second_rules.yml"
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      
      - job_name: 'kubernetes-apiservers'
        kubernetes_sd_configs:
        - role: endpoints
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: default;kubernetes;https
      
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
        - role: node
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/${1}/proxy/metrics
      
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: kubernetes_pod_name
EOF
Apply the ConfigMap:
oc apply -f prometheus-config.yaml
Verify the ConfigMap creation:
oc get configmap prometheus-config -o yaml
Subtask 2.3: Create Service Account and RBAC
Create a service account for Prometheus:
cat << 'EOF' > prometheus-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: prometheus-lab
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: prometheus-lab
EOF
Apply the RBAC configuration:
oc apply -f prometheus-rbac.yaml
Verify the service account and permissions:
oc get serviceaccount prometheus
oc get clusterrole prometheus
oc get clusterrolebinding prometheus
Subtask 2.4: Deploy Prometheus
Create the Prometheus deployment:
cat << 'EOF' > prometheus-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: prometheus-lab
  labels:
    app: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      serviceAccountName: prometheus
      containers:
      - name: prometheus
        image: prom/prometheus:v2.40.0
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus/'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--storage.tsdb.retention.time=200h'
          - '--web.enable-lifecycle'
        ports:
        - containerPort: 9090
        resources:
          requests:
            cpu: 200m
            memory: 1000Mi
          limits:
            cpu: 1000m
            memory: 2500Mi
        volumeMounts:
        - name: prometheus-config-volume
          mountPath: /etc/prometheus/
        - name: prometheus-storage-volume
          mountPath: /prometheus/
      volumes:
      - name: prometheus-config-volume
        configMap:
          defaultMode: 420
          name: prometheus-config
      - name: prometheus-storage-volume
        emptyDir: {}
EOF
Apply the deployment:
oc apply -f prometheus-deployment.yaml
Monitor the deployment progress:
oc get deployment prometheus -w
Press Ctrl+C when the deployment shows 1/1 ready.

Verify the pod is running:
oc get pods -l app=prometheus
Subtask 2.5: Create Prometheus Service
Create a service to expose Prometheus:
cat << 'EOF' > prometheus-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus-service
  namespace: prometheus-lab
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/port:   '9090'
spec:
  selector: 
    app: prometheus
  type: ClusterIP
  ports:
  - port: 8080
    targetPort: 9090 
    protocol: TCP
EOF
Apply the service:
oc apply -f prometheus-service.yaml
Verify the service:
oc get service prometheus-service
Subtask 2.6: Create Route for External Access
Create a route to access Prometheus externally:
oc expose service prometheus-service --name=prometheus-route
Get the route URL:
oc get route prometheus-route
Test the route:
PROMETHEUS_URL=$(oc get route prometheus-route -o jsonpath='{.spec.host}')
echo "Prometheus URL: http://$PROMETHEUS_URL"
Task 3: Configure Prometheus to Collect OpenShift Metrics
Subtask 3.1: Deploy Sample Application with Metrics
Create a sample application that exposes metrics:
cat << 'EOF' > sample-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-metrics-app
  namespace: prometheus-lab
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-metrics-app
  template:
    metadata:
      labels:
        app: sample-metrics-app
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: sample-app
        image: quay.io/prometheus/node-exporter:latest
        ports:
        - containerPort: 9100
          name: metrics
        args:
        - --path.procfs=/host/proc
        - --path.sysfs=/host/sys
        - --collector.filesystem.ignored-mount-points
        - ^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly:  true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
      hostNetwork: true
      hostPID: true
---
apiVersion: v1
kind: Service
metadata:
  name: sample-metrics-service
  namespace: prometheus-lab
  labels:
    app: sample-metrics-app
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9100"
spec:
  ports:
  - port: 9100
    targetPort: 9100
    name: metrics
  selector:
    app: sample-metrics-app
EOF
Deploy the sample application:
oc apply -f sample-app.yaml
Verify the deployment:
oc get pods -l app=sample-metrics-app
oc get service sample-metrics-service
Subtask 3.2: Create ServiceMonitor for Application Discovery
First, check if the Prometheus Operator is available:
oc get crd | grep servicemonitor
If ServiceMonitor CRD exists, create a ServiceMonitor:
cat << 'EOF' > service-monitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: sample-app-monitor
  namespace: prometheus-lab
  labels:
    app: sample-metrics-app
spec:
  selector:
    matchLabels:
      app: sample-metrics-app
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
EOF
Apply the ServiceMonitor (if CRD exists):
oc apply -f service-monitor.yaml 2>/dev/null || echo "ServiceMonitor CRD not available, using static configuration"
Subtask 3.3: Update Prometheus Configuration for Additional Targets
Update the Prometheus configuration to include our sample application:
cat << 'EOF' > prometheus-config-updated.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: prometheus-lab
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      
      - job_name: 'sample-metrics-app'
        static_configs:
          - targets: ['sample-metrics-service:9100']
        scrape_interval: 30s
        metrics_path: /metrics
      
      - job_name: 'kubernetes-apiservers'
        kubernetes_sd_configs:
        - role: endpoints
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
          action: keep
          regex: default;kubernetes;https
      
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
        - role: node
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
        bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - target_label: __address__
          replacement: kubernetes.default.svc:443
        - source_labels: [__meta_kubernetes_node_name]
          regex: (.+)
          target_label: __metrics_path__
          replacement: /api/v1/nodes/${1}/proxy/metrics
      
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: kubernetes_pod_name
      
      - job_name: 'kubernetes-service-endpoints'
        kubernetes_sd_configs:
        - role: endpoints
        relabel_configs:
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
          action: replace
          target_label: __scheme__
          regex: (https?)
        - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
          action: replace
          target_label: __address__
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_service_name]
          action: replace
          target_label: kubernetes_name
EOF
Apply the updated configuration:
oc apply -f prometheus-config-updated.yaml
Restart Prometheus to reload the configuration:
oc rollout restart deployment prometheus
Wait for the rollout to complete:
oc rollout status deployment prometheus
Task 4: Access and Explore Prometheus UI
Subtask 4.1: Access Prometheus Web Interface
Get the Prometheus route URL:
PROMETHEUS_URL=$(oc get route prometheus-route -o jsonpath='{.spec.host}')
echo "Access Prometheus at: http://$PROMETHEUS_URL"
Open your web browser and navigate to the Prometheus URL

You should see the Prometheus web interface with the following sections:

Graph: For querying and visualizing metrics
Alerts: For viewing active alerts
Status: For checking configuration and targets
Subtask 4.2: Explore Prometheus Targets
In the Prometheus UI, click on Status → Targets

You should see several target groups:

prometheus: The Prometheus server itself
sample-metrics-app: Your sample application
kubernetes-apiservers: OpenShift API servers
kubernetes-nodes: Cluster nodes
kubernetes-pods: Discovered pods with metrics
kubernetes-service-endpoints: Service endpoints
Verify that targets are showing as UP (green). If any show as DOWN (red), note the error messages.

Subtask 4.3: Query Basic Metrics
Click on the Graph tab in Prometheus UI

Try these basic queries in the expression browser:

Query 1: Check Prometheus is scraping itself

up{job="prometheus"}
Query 2: View all available metrics from your sample app

{job="sample-metrics-app"}
Query 3: Check node CPU usage

node_cpu_seconds_total
Query 4: View memory usage

node_memory_MemAvailable_bytes
For each query:
Click Execute
Switch between Table and Graph views
Observe the time series data
Subtask 4.4: Advanced Metric Queries
Try these more advanced queries:
Query 5: CPU usage rate over 5 minutes

rate(node_cpu_seconds_total[5m])
Query 6: Available memory in GB

node_memory_MemAvailable_bytes / 1024 / 1024 / 1024
Query 7: Number of running pods per namespace

count by (namespace) (kube_pod_info)
Query 8: Prometheus scrape duration

prometheus_target_scrape_duration_seconds
Experiment with the time range selector:
Change from 1h to 6h or 1d
Observe how the graphs change
Subtask 4.5: Explore Configuration and Service Discovery
Go to Status → Configuration to view the current Prometheus configuration

Go to Status → Service Discovery to see how Prometheus discovers targets

Check Status → TSDB Status to view database statistics

Task 5: Monitor OpenShift-Specific Metrics
Subtask 5.1: Deploy Additional Monitoring Components
Create a simple web application to generate more metrics:
cat << 'EOF' > web-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: prometheus-lab
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: web-app
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
  namespace: prometheus-lab
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "80"
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
EOF
Deploy the web application:
oc apply -f web-app.yaml
Subtask 5.2: Query OpenShift-Specific Metrics
In the Prometheus UI, try these OpenShift-specific queries:
Query 9: Pod resource requests

kube_pod_container_resource_requests
Query 10: Pod status by phase

kube_pod_status_phase
Query 11: Deployment replicas

kube_deployment_status_replicas
Query 12: Node capacity

kube_node_status_capacity
Create a custom query to monitor your web application:
Query 13: Web app pod count

count(kube_pod_info{pod=~"web-app-.*"})
Subtask 5.3: Set Up Basic Alerting Rules
Create an alerting rules file:
cat << 'EOF' > prometheus-rules.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-rules
  namespace: prometheus-lab
data:
  alert.rules: |
    groups:
    - name: example
      rules:
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.8
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: High memory usage detected
          description: "Memory usage is above 80% for more than 2 minutes"
      
      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: Pod is crash looping
          description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is restarting frequently"
EOF
Apply the rules:
oc apply -f prometheus-rules.yaml
Update Prometheus configuration to include rules:
cat << 'EOF' > prometheus-config-with-rules.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: prometheus-lab
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    rule_files:
      - "/etc/prometheus-rules/alert.rules"
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      
      - job_name: 'sample-metrics-app'
        static_configs:
          - targets: ['sample-metrics-service:9100']
        scrape_interval: 30s
        metrics_path: /metrics
      
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
          action: keep
          regex: true
        - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
          action: replace
          target_label: __metrics_path__
          regex: (.+)
        - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
          action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - source_labels: [__meta_kubernetes_namespace]
          action: replace
          target_label: kubernetes_namespace
        - source_labels: [__meta_kubernetes_pod_name]
          action: replace
          target_label: kubernetes_pod_name
EOF
Update the Prometheus deployment to mount the rules:
cat << 'EOF' > prometheus-deployment-with-rules.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: prometheus-lab
  labels:
    app: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      serviceAccountName: prometheus
      containers:
      - name: prometheus
        image: prom/prometheus:v2.40.0
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus/'
          - '--web.console.libraries=/etc/prometheus/console_libraries'
          - '--web.console.templates=/etc/prometheus/consoles'
          - '--storage.tsdb.retention.time=200h'
          - '--web.enable-lifecycle'
        ports:
        - containerPort: 9090
        resources:
          requests:
            cpu: 200m
            memory: 1000Mi
          limits:
            cpu: 1000m
            memory: 2500Mi
        volumeMounts:
        - name: prometheus-config-volume
          mountPath: /etc/prometheus/
        - name: prometheus-rules-volume
          mountPath: /etc/prometheus-rules/
        - name: prometheus-storage-volume
          mountPath: /prometheus/
      volumes:
      - name: prometheus-config-volume
        configMap:
          defaultMode: 420
          name: prometheus-config
      - name: prometheus-rules-volume
        configMap:
          defaultMode: 420
          name: prometheus-rules
      - name: prometheus-storage-volume
        emptyDir: {}
EOF
Apply the updated configuration and deployment:
oc apply -f prometheus-config-with-rules.yaml
oc apply -f prometheus-deployment-with-rules.yaml
Wait for the deployment to update:
oc rollout status deployment prometheus
Task 6: Troubleshooting and Verification
Subtask 6.1: Verify Prometheus Health
Check Prometheus pod logs:
oc logs -l app=prometheus --tail=50
Verify configuration reload:
oc exec -it deployment/prometheus -- promtool check config /etc/prometheus/prometheus.yml
Check if rules are loaded:
oc exec -it deployment/prometheus -- promtool check rules /etc/prometheus-rules/alert.rules
Subtask 6.2: Test Metric Collection
Verify targets are being scraped:
curl -s http://$(oc get route prometheus-route -o jsonpath='{.spec.host}')/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health, lastError: .lastError}'
Test a simple metric query via API:
curl -s "http://$(oc get route prometheus-route -o jsonpath='{.spec.host}')/api/v1/query?query=up" | jq '.data.result[] | {metric: .metric, value: .value}'
Subtask 6.3: Common Troubleshooting Steps
If targets are down:

Check service endpoints: oc get endpoints
Verify network policies: oc get networkpolicy
Check pod logs: oc logs <pod-name>
If metrics are missing:

Verify scrape annotations on pods/services
Check Prometheus configuration syntax
Ensure proper RBAC permissions
If Prometheus UI is not accessible:

Check route status: oc get route prometheus-route
Verify service is running: oc get service prometheus-service
Check pod status: oc get pods -l app=prometheus
Subtask 6.4: Performance Verification
Check Prometheus resource usage:
oc top pod -l app=prometheus
Monitor scrape duration:
curl -s "http://$(oc get route prometheus-route -o jsonpath='{.spec.host}')/api/v1/query?query=prometheus_target_scrape_duration_seconds" | jq '.data.result[] | {job: .metric.job, duration: .value[1]}'
Check storage usage:
oc exec -it deployment/prometheus -- df -h /prometheus
Conclusion
Congratulations! You have successfully completed Lab 11: OpenShift Monitoring with Prometheus. Here's what you accomplished:

Key Achievements
• Installed Prometheus: You deployed a complete Prometheus monitoring stack on OpenShift, including proper RBAC configuration and service accounts

• Configured Metric Collection: You set up Prometheus to automatically discover and scrape metrics from OpenShift cluster components, including API servers, nodes, pods, and services

• Deployed Sample Applications: You created sample applications with proper metric annotations to demonstrate how applications can expose metrics for Prometheus collection

• Explored Prometheus UI: You learned to navigate the Prometheus web interface, execute PromQL queries, and visualize time-series data

• Implemented Service Discovery: You configured Kubernetes service discovery to automatically find and monitor new targets as they are deployed

• Set Up Alerting Rules: You created basic alerting rules to monitor system health and application performance

• Performed Troubleshooting: You learned essential troubleshooting
