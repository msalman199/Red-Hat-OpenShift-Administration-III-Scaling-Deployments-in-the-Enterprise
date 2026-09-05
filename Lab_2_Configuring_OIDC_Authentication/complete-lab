Lab 2: Configuring OIDC Authentication
Objectives
By the end of this lab, students will be able to:

• Understand the fundamentals of OpenID Connect (OIDC) authentication • Set up an OIDC Identity Provider using Google OAuth 2.0 • Configure OIDC authentication in OpenShift cluster • Test OIDC authentication using the oc command-line tool • Troubleshoot common OIDC authentication issues • Implement secure authentication workflows for enterprise OpenShift deployments

Prerequisites
Before starting this lab, students should have:

• Basic understanding of OpenShift concepts and architecture • Familiarity with Kubernetes authentication mechanisms • Experience with command-line interface operations • Basic knowledge of OAuth 2.0 and authentication protocols • Access to a Google account for setting up OAuth credentials • Understanding of YAML configuration files

Lab Environment
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift cluster access. Simply click Start Lab to begin - no need to build your own virtual machine or install additional software.

Your lab environment includes: • OpenShift 4.12+ cluster with administrative access • Pre-installed oc command-line tool • Internet connectivity for external identity provider setup • Text editor (vim/nano) for configuration files

Task 1: Set up an OIDC Identity Provider (Google OAuth)
Subtask 1.1: Create Google OAuth 2.0 Credentials
Step 1: Access Google Cloud Console

Open your web browser and navigate to the Google Cloud Console
Go to: https://console.cloud.google.com/
Sign in with your Google account credentials
Step 2: Create or Select a Project

Click on the project dropdown at the top of the page
Either select an existing project or click New Project
If creating new project:
Enter project name: openshift-oidc-lab
Click Create
Wait for project creation to complete
Step 3: Enable Google+ API

Navigate to APIs & Services > Library
Search for "Google+ API"
Click on Google+ API from results
Click Enable button
Wait for API to be enabled
Step 4: Configure OAuth Consent Screen

Go to APIs & Services > OAuth consent screen
Select External user type
Click Create
Fill in required information:
App name: OpenShift OIDC Authentication
User support email: Your email address
Developer contact information: Your email address
Click Save and Continue
Skip Scopes section by clicking Save and Continue
Skip Test users section by clicking Save and Continue
Review and click Back to Dashboard
Step 5: Create OAuth 2.0 Credentials

Navigate to APIs & Services > Credentials
Click Create Credentials > OAuth client ID
Select Web application as application type
Configure the following:
Name: OpenShift OIDC Client
Authorized JavaScript origins: https://your-openshift-console-url
Authorized redirect URIs: https://oauth-openshift.apps.your-cluster-domain/oauth2callback/google
Note: Replace the URLs with your actual OpenShift cluster URLs. You can find these by running:

oc get routes -n openshift-console
oc get routes -n openshift-authentication
Click Create
Important: Copy and save the Client ID and Client Secret - you'll need these later
Subtask 1.2: Verify Google OAuth Configuration
Step 1: Test OAuth Endpoint

Open terminal in your lab environment
Verify Google's OIDC discovery endpoint:
curl -s https://accounts.google.com/.well-known/openid_configuration | jq .
Step 2: Validate Required Endpoints

Confirm the following endpoints are available in the response: • authorization_endpoint • token_endpoint • userinfo_endpoint • jwks_uri

Task 2: Configure OIDC in OpenShift
Subtask 2.1: Create OIDC Configuration Secret
Step 1: Create Client Secret

Create a secret containing your Google OAuth client secret:
oc create secret generic google-client-secret \
  --from-literal=clientSecret=YOUR_GOOGLE_CLIENT_SECRET \
  -n openshift-config
Replace YOUR_GOOGLE_CLIENT_SECRET with the actual client secret from Google.

Step 2: Verify Secret Creation

oc get secret google-client-secret -n openshift-config -o yaml
Subtask 2.2: Configure OAuth Custom Resource
Step 1: Create OIDC Configuration File

Create a new file called oidc-config.yaml:
vim oidc-config.yaml
Add the following configuration:
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: google-oidc
    mappingMethod: claim
    type: OpenID
    openID:
      clientID: YOUR_GOOGLE_CLIENT_ID
      clientSecret:
        name: google-client-secret
      extraScopes:
      - email
      - profile
      extraAuthorizeParameters:
        include_granted_scopes: "true"
      claims:
        preferredUsername:
        - email
        name:
        - name
        email:
        - email
      issuer: https://accounts.google.com
Important: Replace YOUR_GOOGLE_CLIENT_ID with your actual Google OAuth Client ID.

Step 2: Apply OIDC Configuration

oc apply -f oidc-config.yaml
Step 3: Verify Configuration Applied

oc get oauth cluster -o yaml
Subtask 2.3: Monitor OAuth Pod Restart
Step 1: Watch OAuth Pods

The OAuth pods will automatically restart to pick up the new configuration:

oc get pods -n openshift-authentication -w
Step 2: Verify Pod Status

Wait for all pods to be in Running status:

oc get pods -n openshift-authentication
Step 3: Check OAuth Pod Logs

oc logs -n openshift-authentication deployment/oauth-openshift
Look for successful startup messages and no error logs related to OIDC configuration.

Task 3: Test OIDC Authentication with oc login
Subtask 3.1: Test Web Console Authentication
Step 1: Access OpenShift Web Console

Get your OpenShift console URL:
oc get routes -n openshift-console
Open the console URL in your web browser
You should now see google-oidc as an authentication option
Click on google-oidc
You'll be redirected to Google's authentication page
Step 2: Complete Google Authentication

Enter your Google credentials
Grant permissions to the OpenShift application
You should be redirected back to OpenShift console
Verify you're logged in successfully
Subtask 3.2: Test CLI Authentication
Step 1: Get OAuth Server URL

oc get routes -n openshift-authentication
Step 2: Logout from Current Session

oc logout
Step 3: Login Using OIDC

oc login --web https://api.your-cluster-domain:6443
Replace your-cluster-domain with your actual cluster domain.

Step 4: Complete Browser Authentication

The command will open your default web browser
Select google-oidc authentication method
Complete Google authentication process
Return to terminal - you should see successful login message
Step 5: Verify Authentication

oc whoami
oc get user
Subtask 3.3: Test User Permissions
Step 1: Check Default Permissions

oc auth can-i get pods
oc auth can-i create projects
Step 2: Create Test Project (if permitted)

oc new-project oidc-test-project
Step 3: Verify Project Creation

oc get projects | grep oidc-test
Troubleshooting Common Issues
Issue 1: OAuth Pods Not Restarting
Symptoms: Configuration applied but authentication not working

Solution:

# Force restart OAuth pods
oc delete pods -n openshift-authentication --all

# Wait for pods to restart
oc get pods -n openshift-authentication -w
Issue 2: Invalid Redirect URI
Symptoms: Error during Google authentication about redirect URI mismatch

Solution:

Verify your redirect URI in Google Console matches exactly:
echo "https://oauth-openshift.apps.$(oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}')/oauth2callback/google"
Update Google OAuth configuration with correct URI
Issue 3: Client Secret Not Found
Symptoms: OAuth pods failing to start with secret-related errors

Solution:

# Verify secret exists
oc get secret google-client-secret -n openshift-config

# Recreate secret if needed
oc delete secret google-client-secret -n openshift-config
oc create secret generic google-client-secret \
  --from-literal=clientSecret=YOUR_ACTUAL_SECRET \
  -n openshift-config
Issue 4: User Cannot Access Resources
Symptoms: User can login but cannot perform any operations

Solution:

# Grant cluster-admin role (for testing only)
oc adm policy add-cluster-role-to-user cluster-admin YOUR_EMAIL_ADDRESS

# Or create custom role binding
oc adm policy add-role-to-user edit YOUR_EMAIL_ADDRESS -n default
Verification Commands
Use these commands to verify your OIDC configuration:

# Check OAuth configuration
oc get oauth cluster -o jsonpath='{.spec.identityProviders[*].name}'

# Verify identity provider status
oc get authentication.operator.openshift.io cluster -o yaml

# Check user identities
oc get identities

# List all users
oc get users

# Check OAuth pod logs
oc logs -n openshift-authentication -l app=oauth-openshift --tail=50
Security Best Practices
Principle of Least Privilege
• Only grant necessary permissions to OIDC users • Use role-based access control (RBAC) appropriately • Regularly audit user permissions

Secret Management
• Store client secrets securely in OpenShift secrets • Rotate OAuth credentials periodically • Monitor secret access logs

Configuration Security
# Example secure OIDC configuration
spec:
  identityProviders:
  - name: google-oidc
    mappingMethod: claim  # Use 'claim' for better security
    type: OpenID
    openID:
      clientID: your-client-id
      clientSecret:
        name: google-client-secret
      extraScopes:
      - email
      - profile
      # Avoid requesting unnecessary scopes
      claims:
        preferredUsername:
        - email
        name:
        - name
        email:
        - email
      issuer: https://accounts.google.com
Conclusion
In this lab, you have successfully:

• Configured Google OAuth 2.0 as an external identity provider for enterprise-grade authentication • Implemented OIDC authentication in OpenShift, enabling secure single sign-on capabilities • Tested authentication workflows using both web console and command-line interfaces • Applied security best practices for identity and access management in containerized environments

Why This Matters: OIDC authentication is crucial for enterprise OpenShift deployments because it:

Centralizes Identity Management: Integrates with existing corporate identity systems
Enhances Security: Provides secure, token-based authentication without storing passwords
Improves User Experience: Enables single sign-on across multiple applications
Supports Compliance: Meets enterprise security and audit requirements
Scales Effectively: Handles authentication for large numbers of users and applications
This configuration forms the foundation for implementing comprehensive identity and access management strategies in production OpenShift environments, supporting the scalability and security requirements covered in Red Hat OpenShift Administration III certification objectives.

Next Steps: Consider exploring advanced OIDC features such as group claims, custom attribute mapping, and integration with enterprise identity providers like Active Directory Federation Services (ADFS) or Keycloak.
