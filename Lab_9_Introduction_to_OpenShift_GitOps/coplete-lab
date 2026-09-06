Lab 9: Introduction to OpenShift GitOps
Objectives
By the end of this lab, students will be able to:

• Understand the core concepts of GitOps and its benefits in container orchestration • Install and configure OpenShift GitOps Operator on an OpenShift cluster • Set up a Git repository to store application configurations and Kubernetes manifests • Configure ArgoCD to automatically sync OpenShift resources with Git repository changes • Deploy applications using GitOps methodology • Monitor and troubleshoot GitOps deployments through the ArgoCD web interface • Implement basic GitOps workflows for continuous deployment

Prerequisites
Before starting this lab, students should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with OpenShift fundamentals and CLI operations • Basic knowledge of Git version control system • Understanding of YAML syntax and Kubernetes manifest files • Access to an OpenShift cluster with cluster-admin privileges • Git client installed and configured • OpenShift CLI (oc) installed and configured

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with OpenShift cluster access pre-configured. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes: • OpenShift cluster with admin access • Pre-installed OpenShift CLI (oc) • Git client ready for use • Web browser for accessing OpenShift and ArgoCD consoles

Task 1: Install OpenShift GitOps
Subtask 1.1: Verify Cluster Access
First, let's verify that you have proper access to the OpenShift cluster.

Open a terminal in your lab environment
Check your cluster connection:
oc whoami
oc cluster-info
Verify you have cluster-admin privileges:
oc auth can-i create clusterroles
The output should show "yes" if you have the required permissions.

Subtask 1.2: Install OpenShift GitOps Operator
The OpenShift GitOps Operator provides ArgoCD as a managed service on OpenShift.

Create the operator subscription:
cat << EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-gitops-operator
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-gitops-operator
  namespace: openshift-gitops-operator
spec:
  targetNamespaces:
  - openshift-gitops-operator
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-gitops-operator
  namespace: openshift-gitops-operator
spec:
  channel: latest
  installPlanApproval: Automatic
  name: openshift-gitops-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
Wait for the operator to be installed:
oc get csv -n openshift-gitops-operator
Verify the GitOps operator is running:
oc get pods -n openshift-gitops-operator
Subtask 1.3: Verify ArgoCD Installation
The operator automatically creates an ArgoCD instance in the openshift-gitops namespace.

Check if the ArgoCD instance is created:
oc get pods -n openshift-gitops
Wait for all pods to be in Running state:
oc get pods -n openshift-gitops -w
Press Ctrl+C when all pods show Running status.

Get the ArgoCD server route:
oc get route -n openshift-gitops
Note the ArgoCD server URL for later use.

Subtask 1.4: Access ArgoCD Web Interface
Get the ArgoCD admin password:
oc extract secret/openshift-gitops-cluster -n openshift-gitops --to=-
Open the ArgoCD URL in your browser (use the route from previous step)
Login with:
Username: admin
Password: (the password extracted in step 1)
Task 2: Configure a Git Repository for Application Configuration
Subtask 2.1: Create a Git Repository Structure
We'll create a local Git repository to store our application configurations.

Create a directory for your GitOps repository:
mkdir ~/gitops-lab
cd ~/gitops-lab
Initialize the Git repository:
git init
git config user.name "Lab User"
git config user.email "lab@example.com"
Create the directory structure:
mkdir -p applications/sample-app
mkdir -p environments/dev
mkdir -p environments/prod
Subtask 2.2: Create Sample Application Manifests
Create a sample application deployment:
cat << EOF > applications/sample-app/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app: sample-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
EOF
Create a service for the application:
cat << EOF > applications/sample-app/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
  labels:
    app: sample-app
spec:
  selector:
    app: sample-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF
Create a route for external access:
cat << EOF > applications/sample-app/route.yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: sample-app-route
  labels:
    app: sample-app
spec:
  to:
    kind: Service
    name: sample-app-service
  port:
    targetPort: 80
EOF
Subtask 2.3: Create Environment-Specific Configurations
Create development environment kustomization:
cat << EOF > environments/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: sample-app-dev

resources:
- ../../applications/sample-app

patchesStrategicMerge:
- replica-patch.yaml

commonLabels:
  environment: dev
EOF
Create development replica patch:
cat << EOF > environments/dev/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 1
EOF
Create production environment kustomization:
cat << EOF > environments/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: sample-app-prod

resources:
- ../../applications/sample-app

patchesStrategicMerge:
- replica-patch.yaml

commonLabels:
  environment: prod
EOF
Create production replica patch:
cat << EOF > environments/prod/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 3
EOF
Subtask 2.4: Commit Changes to Git
Add all files to Git:
git add .
Commit the initial configuration:
git commit -m "Initial GitOps configuration for sample application"
Create a simple Git server for this lab (using git daemon):
cd ~
git clone --bare gitops-lab gitops-lab.git
cd gitops-lab.git
git --bare update-server-info
Start a simple Git server:
cd ~
python3 -m http.server 8080 --directory . &
Note: In a production environment, you would use a proper Git hosting service like GitHub, GitLab, or Bitbucket.

Task 3: Set up ArgoCD to Sync OpenShift Resources with Git Changes
Subtask 3.1: Create Target Namespaces
Create namespaces for our applications:
oc create namespace sample-app-dev
oc create namespace sample-app-prod
Label the namespaces for ArgoCD management:
oc label namespace sample-app-dev argocd.argoproj.io/managed-by=openshift-gitops
oc label namespace sample-app-prod argocd.argoproj.io/managed-by=openshift-gitops
Subtask 3.2: Configure ArgoCD Repository
Create a repository secret for ArgoCD to access our Git repository:
cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: gitops-lab-repo
  namespace: openshift-gitops
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: http://$(hostname -I | awk '{print $1}'):8080/gitops-lab.git
EOF
Subtask 3.3: Create ArgoCD Applications
Create ArgoCD application for development environment:
cat << EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app-dev
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: http://$(hostname -I | awk '{print $1}'):8080/gitops-lab.git
    targetRevision: HEAD
    path: environments/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: sample-app-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF
Create ArgoCD application for production environment:
cat << EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app-prod
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: http://$(hostname -I | awk '{print $1}'):8080/gitops-lab.git
    targetRevision: HEAD
    path: environments/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: sample-app-prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF
Subtask 3.4: Verify Application Deployment
Check ArgoCD applications status:
oc get applications -n openshift-gitops
Verify pods are running in both environments:
oc get pods -n sample-app-dev
oc get pods -n sample-app-prod
Check the number of replicas in each environment:
echo "Development replicas:"
oc get deployment sample-app -n sample-app-dev -o jsonpath='{.spec.replicas}'
echo ""
echo "Production replicas:"
oc get deployment sample-app -n sample-app-prod -o jsonpath='{.spec.replicas}'
echo ""
Subtask 3.5: Test GitOps Synchronization
Navigate back to your Git repository:
cd ~/gitops-lab
Modify the development replica count:
cat << EOF > environments/dev/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 2
EOF
Commit the change:
git add environments/dev/replica-patch.yaml
git commit -m "Scale dev environment to 2 replicas"
Update the bare repository:
cd ~/gitops-lab.git
git --bare fetch ../gitops-lab master:master
git --bare update-server-info
Wait for ArgoCD to sync (or manually sync through the UI):
sleep 30
oc get deployment sample-app -n sample-app-dev -o jsonpath='{.spec.replicas}'
echo ""
Subtask 3.6: Monitor Through ArgoCD Web Interface
Access the ArgoCD web interface using the route obtained earlier
Login with admin credentials
Observe the applications and their sync status
Click on each application to see detailed resource information
Verify that the development environment now shows 2 replicas
Troubleshooting Tips
Common Issues and Solutions
Issue: ArgoCD applications show "Unknown" status Solution: Check if the Git repository URL is accessible and the path exists

curl -I http://$(hostname -I | awk '{print $1}'):8080/gitops-lab.git
Issue: Applications fail to sync Solution: Verify namespace labels and RBAC permissions

oc get namespace sample-app-dev -o yaml | grep labels -A 5
Issue: Git server not accessible Solution: Restart the Python HTTP server

pkill -f "python3 -m http.server"
cd ~
python3 -m http.server 8080 --directory . &
Issue: Pods not starting Solution: Check resource quotas and node capacity

oc describe pod -n sample-app-dev
oc get nodes -o wide
Verification Commands
Use these commands to verify your lab completion:

# Check GitOps operator installation
oc get csv -n openshift-gitops-operator

# Verify ArgoCD is running
oc get pods -n openshift-gitops

# Check applications are created
oc get applications -n openshift-gitops

# Verify deployments in both environments
oc get deployments -n sample-app-dev
oc get deployments -n sample-app-prod

# Check application accessibility
oc get routes -n sample-app-dev
oc get routes -n sample-app-prod
Conclusion
In this lab, you have successfully:

• Installed OpenShift GitOps: You deployed the GitOps operator and ArgoCD on your OpenShift cluster, providing a foundation for GitOps-based application delivery.

• Created a Git Repository Structure: You established a well-organized repository with environment-specific configurations using Kustomize, demonstrating best practices for GitOps repository management.

• Configured Automated Synchronization: You set up ArgoCD applications that automatically sync your OpenShift resources with Git repository changes, enabling true GitOps workflows.

• Implemented Environment Separation: You created separate development and production environments with different configurations, showing how GitOps supports multi-environment deployments.

• Tested GitOps Workflows: You verified that changes to your Git repository automatically propagate to your OpenShift cluster, demonstrating the power of declarative, Git-driven deployments.

Why This Matters: GitOps represents a paradigm shift in how we deploy and manage applications in Kubernetes environments. By treating Git as the single source of truth for your infrastructure and applications, you gain:

Improved Security: All changes go through Git's audit trail and approval processes
Better Reliability: Declarative configurations ensure consistent deployments
Enhanced Collaboration: Developers and operations teams work with familiar Git workflows
Simplified Rollbacks: Git history provides easy rollback capabilities
Increased Visibility: All changes are tracked and visible through Git and ArgoCD interfaces
This foundation prepares you for advanced GitOps practices including multi-cluster deployments, progressive delivery strategies, and integration with CI/CD pipelines - essential skills for modern cloud-native application delivery in enterprise environments.
