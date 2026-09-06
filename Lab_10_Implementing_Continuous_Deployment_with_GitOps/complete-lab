Lab 10: Implementing Continuous Deployment with GitOps
Objectives
By the end of this lab, you will be able to:

• Understand the core principles and benefits of GitOps methodology • Set up and configure ArgoCD as a GitOps operator in OpenShift • Create a complete GitOps pipeline for automated application deployment • Implement Git-based configuration management for Kubernetes applications • Perform automated deployments triggered by Git repository changes • Execute application rollbacks using GitOps principles • Monitor and troubleshoot GitOps deployments in OpenShift • Apply GitOps best practices for enterprise-scale deployments

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Git version control system • Familiarity with Kubernetes/OpenShift concepts (pods, deployments, services) • Knowledge of YAML configuration files • Experience with command-line interface operations • Understanding of container concepts and Docker basics • Basic knowledge of CI/CD principles

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift cluster access. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes: • OpenShift 4.12+ cluster with admin access • Pre-installed oc (OpenShift CLI) tool • Git client configured and ready to use • Internet access for pulling container images • Web browser for accessing OpenShift console

Task 1: Setting Up GitOps Infrastructure
Subtask 1.1: Install ArgoCD Operator
First, we'll install the ArgoCD operator which will serve as our GitOps engine.

Login to OpenShift cluster:
oc login --server=https://api.cluster.example.com:6443 --username=admin
Create a dedicated namespace for ArgoCD:
oc new-project argocd-system
Install the ArgoCD Operator:
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: argocd-operator
  namespace: argocd-system
spec:
  channel: stable
  installPlanApproval: Automatic
  name: argocd-operator
  source: operatorhub
  sourceNamespace: openshift-marketplace
EOF
Verify the operator installation:
oc get csv -n argocd-system
Wait until the operator shows Succeeded status.

Subtask 1.2: Deploy ArgoCD Instance
Create ArgoCD instance:
cat << EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd-server
  namespace: argocd-system
spec:
  server:
    route:
      enabled: true
      tls:
        termination: edge
        insecureEdgeTerminationPolicy: Redirect
  dex:
    openShiftOAuth: true
  rbac:
    defaultPolicy: 'role:readonly'
    policy: |
      g, system:cluster-admins, role:admin
    scopes: '[groups]'
EOF
Wait for ArgoCD components to be ready:
oc get pods -n argocd-system -w
Press Ctrl+C when all pods show Running status.

Get ArgoCD server URL:
oc get route argocd-server-server -n argocd-system -o jsonpath='{.spec.host}'
Subtask 1.3: Configure ArgoCD Access
Get the initial admin password:
oc get secret argocd-server-cluster -n argocd-system -o jsonpath='{.data.admin\.password}' | base64 -d
Access ArgoCD UI:
Open the ArgoCD URL in your browser
Login with username: admin
Use the password from step 1
Task 2: Creating a GitOps Pipeline for Application Deployment
Subtask 2.1: Prepare Application Repository
Create a new project for your application:
oc new-project gitops-demo
Create a sample application directory structure:
mkdir -p ~/gitops-lab/app-config
cd ~/gitops-lab
Initialize Git repository:
git init
git config user.name "GitOps Lab User"
git config user.email "user@example.com"
Create application deployment manifest:
cat << EOF > app-config/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: gitops-demo
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
Create service manifest:
cat << EOF > app-config/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
  namespace: gitops-demo
spec:
  selector:
    app: sample-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
EOF
Create route manifest:
cat << EOF > app-config/route.yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: sample-app-route
  namespace: gitops-demo
spec:
  to:
    kind: Service
    name: sample-app-service
  port:
    targetPort: 80
EOF
Subtask 2.2: Create Kustomization File
Create kustomization.yaml:
cat << EOF > app-config/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- deployment.yaml
- service.yaml
- route.yaml

commonLabels:
  managed-by: argocd
  environment: demo
EOF
Commit initial configuration:
git add .
git commit -m "Initial application configuration"
Subtask 2.3: Set Up Git Repository (Using Local Git Server)
For this lab, we'll simulate a Git server using a local bare repository:

Create a bare Git repository:
cd ~
git init --bare gitops-repo.git
Add remote to your working repository:
cd ~/gitops-lab
git remote add origin ~/gitops-repo.git
git push -u origin main
Subtask 2.4: Create ArgoCD Application
Create ArgoCD application manifest:
cat << EOF > ~/argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
  namespace: argocd-system
spec:
  project: default
  source:
    repoURL: file:///home/$(whoami)/gitops-repo.git
    targetRevision: HEAD
    path: app-config
  destination:
    server: https://kubernetes.default.svc
    namespace: gitops-demo
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF
Apply the ArgoCD application:
oc apply -f ~/argocd-app.yaml
Verify application creation in ArgoCD UI:

Refresh your ArgoCD web interface
You should see the sample-app application
Check application status:

oc get application sample-app -n argocd-system
Task 3: Testing Automatic Deployment
Subtask 3.1: Verify Initial Deployment
Check if pods are running:
oc get pods -n gitops-demo
Verify service creation:
oc get svc -n gitops-demo
Check route:
oc get route -n gitops-demo
Test application access:
curl $(oc get route sample-app-route -n gitops-demo -o jsonpath='{.spec.host}')
Subtask 3.2: Update Application Configuration
Now we'll test the GitOps pipeline by making changes to our application.

Update the application image:
cd ~/gitops-lab
sed -i 's/nginx:1.21/nginx:1.22/g' app-config/deployment.yaml
Increase replica count:
sed -i 's/replicas: 2/replicas: 3/g' app-config/deployment.yaml
Commit and push changes:
git add app-config/deployment.yaml
git commit -m "Update nginx version to 1.22 and scale to 3 replicas"
git push origin main
Subtask 3.3: Observe Automatic Deployment
Monitor ArgoCD application sync:
watch oc get application sample-app -n argocd-system
Press Ctrl+C after observing the sync status.

Watch pod changes:
oc get pods -n gitops-demo -w
You should see new pods being created with the updated image.

Verify the changes in ArgoCD UI:

Check the application status in ArgoCD web interface
Review the sync history and details
Confirm replica count:

oc get deployment sample-app -n gitops-demo
Task 4: Implementing Application Rollback via GitOps
Subtask 4.1: Create a Problematic Update
Let's simulate a problematic deployment that needs to be rolled back.

Introduce a configuration error:
cd ~/gitops-lab
sed -i 's/nginx:1.22/nginx:invalid-tag/g' app-config/deployment.yaml
Commit the problematic change:
git add app-config/deployment.yaml
git commit -m "Update to invalid nginx tag (simulating error)"
git push origin main
Subtask 4.2: Observe Failed Deployment
Monitor the deployment:
oc get pods -n gitops-demo -w
You should see pods failing to start due to the invalid image.

Check pod status details:
oc describe pod -l app=sample-app -n gitops-demo
View ArgoCD application status:
Check the ArgoCD UI for sync status
Review error messages and failed resources
Subtask 4.3: Perform GitOps Rollback
View Git commit history:
git log --oneline
Identify the last working commit (the one before the invalid tag):
git log --oneline -n 3
Revert to the previous working state:
git revert HEAD --no-edit
Push the revert commit:
git push origin main
Subtask 4.4: Verify Rollback Success
Monitor the rollback process:
oc get pods -n gitops-demo -w
Confirm application is healthy:
oc get deployment sample-app -n gitops-demo
oc get pods -n gitops-demo
Test application functionality:
curl $(oc get route sample-app-route -n gitops-demo -o jsonpath='{.spec.host}')
Verify in ArgoCD UI:
Check that the application shows Healthy and Synced status
Review the sync history showing the rollback
Task 5: Advanced GitOps Configuration
Subtask 5.1: Implement Environment-Specific Configurations
Create environment overlays:
mkdir -p ~/gitops-lab/environments/{dev,staging,prod}
Create development overlay:
cat << EOF > ~/gitops-lab/environments/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../app-config

patchesStrategicMerge:
- replica-patch.yaml

namePrefix: dev-
commonLabels:
  environment: development
EOF
Create development replica patch:
cat << EOF > ~/gitops-lab/environments/dev/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 1
EOF
Create production overlay:
cat << EOF > ~/gitops-lab/environments/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../../app-config

patchesStrategicMerge:
- replica-patch.yaml
- resource-patch.yaml

namePrefix: prod-
commonLabels:
  environment: production
EOF
Create production patches:
cat << EOF > ~/gitops-lab/environments/prod/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 5
EOF

cat << EOF > ~/gitops-lab/environments/prod/resource-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  template:
    spec:
      containers:
      - name: sample-app
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
EOF
Subtask 5.2: Deploy Environment-Specific Applications
Create development application:
cat << EOF > ~/dev-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app-dev
  namespace: argocd-system
spec:
  project: default
  source:
    repoURL: file:///home/$(whoami)/gitops-repo.git
    targetRevision: HEAD
    path: environments/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: gitops-demo
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
Apply the development application:
oc apply -f ~/dev-app.yaml
Commit and push environment configurations:
cd ~/gitops-lab
git add environments/
git commit -m "Add environment-specific configurations"
git push origin main
Troubleshooting Common Issues
Issue 1: ArgoCD Application Not Syncing
Symptoms: Application shows OutOfSync status but doesn't automatically sync.

Solution:

# Check ArgoCD application logs
oc logs -l app.kubernetes.io/name=argocd-application-controller -n argocd-system

# Manually trigger sync
oc patch application sample-app -n argocd-system --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'
Issue 2: Git Repository Access Issues
Symptoms: ArgoCD cannot access the Git repository.

Solution:

# Verify repository path in application spec
oc get application sample-app -n argocd-system -o yaml

# Check if the repository path exists
ls -la ~/gitops-repo.git
Issue 3: Namespace Creation Issues
Symptoms: Resources fail to deploy due to missing namespace.

Solution:

# Ensure CreateNamespace=true in syncOptions
oc patch application sample-app -n argocd-system --type merge -p '{"spec":{"syncPolicy":{"syncOptions":["CreateNamespace=true"]}}}'
Monitoring and Observability
Subtask 6.1: Set Up Application Monitoring
Check application health:
# View application status
oc get application -n argocd-system

# Check resource health
oc get application sample-app -n argocd-system -o jsonpath='{.status.health.status}'
Monitor sync status:
# Check sync status
oc get application sample-app -n argocd-system -o jsonpath='{.status.sync.status}'

# View last sync time
oc get application sample-app -n argocd-system -o jsonpath='{.status.operationState.finishedAt}'
Subtask 6.2: Configure Notifications
Create notification configuration:
cat << EOF > ~/notification-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  namespace: argocd-system
data:
  service.webhook.generic: |
    url: http://webhook-receiver.example.com/webhook
    headers:
    - name: Content-Type
      value: application/json
  template.app-deployed: |
    webhook:
      generic:
        method: POST
        body: |
          {
            "text": "Application {{.app.metadata.name}} is now running new version."
          }
  trigger.on-deployed: |
    - when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
      send: [app-deployed]
EOF
Best Practices and Security
Security Considerations
Use RBAC for ArgoCD access:
# Create role for GitOps users
cat << EOF | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: gitops-demo
  name: gitops-user
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]
EOF
Implement resource quotas:
cat << EOF | oc apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: gitops-demo-quota
  namespace: gitops-demo
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    pods: "10"
EOF
GitOps Best Practices
Use declarative configurations: Always define desired state, not imperative commands
Version control everything: All configuration changes should go through Git
Implement proper branching strategy: Use feature branches for changes
Test configurations: Validate YAML before committing
Monitor and alert: Set up proper monitoring for GitOps operations
Conclusion
In this comprehensive lab, you have successfully:

• Implemented a complete GitOps pipeline using ArgoCD in OpenShift, demonstrating how Git repositories can serve as the single source of truth for application deployments

• Configured automated deployment workflows that respond to Git repository changes, eliminating manual deployment processes and reducing human error

• Executed application rollbacks using GitOps principles, showing how version control enables quick recovery from problematic deployments

• Set up environment-specific configurations using Kustomize overlays, demonstrating how to manage multiple deployment environments efficiently

• Applied security and monitoring best practices for production-ready GitOps implementations

Why This Matters: GitOps represents a paradigm shift in how we manage application deployments and infrastructure. By treating Git as the source of truth, organizations can achieve:

Improved reliability through automated, consistent deployments
Enhanced security via audit trails and controlled access
Faster recovery through easy rollbacks and version control
Better collaboration between development and operations teams
Reduced operational overhead through automation
The skills you've developed in this lab are directly applicable to enterprise environments where GitOps is becoming the standard for managing Kubernetes and OpenShift deployments. This approach aligns with modern DevOps practices and supports the scalability requirements of large-scale applications.

Your hands-on experience with ArgoCD, Kustomize, and OpenShift GitOps workflows prepares you for real-world scenarios where reliable, automated deployment pipelines are essential for business success.
