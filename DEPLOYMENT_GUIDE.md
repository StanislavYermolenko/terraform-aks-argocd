# Two-Phase Deployment Guide

## 🚀 Phase 1: Infrastructure + ArgoCD Deployment

### Step 1: Deploy Infrastructure
```bash
# Deploy AKS cluster, networking, and ArgoCD
terraform apply
```

This will create:
- Azure Resource Group
- Virtual Network & Subnet  
- AKS Cluster
- Kubernetes Namespaces
- ArgoCD Helm Release (with LoadBalancer)

### Step 2: Get ArgoCD External IP
```bash
# Wait for LoadBalancer to get external IP (may take 5-10 minutes)
kubectl get svc -n argocd argocd-server

# Or watch for the external IP
kubectl get svc -n argocd argocd-server -w
```

### Step 3: Access ArgoCD UI
```bash
# Get the external IP from previous command
# Access ArgoCD at: http://EXTERNAL_IP

# Default login:
# Username: admin
# Password: Argo123!
```

## 🔧 Phase 2: ArgoCD Configuration

### Step 4: Update Provider Configuration
1. Edit `main.tf` and uncomment the ArgoCD provider:
```hcl
provider "argocd" {
  server_addr = "EXTERNAL_IP:80"  # Replace with actual IP
  auth_token  = var.argocd_auth_token
  insecure    = true
}
```

### Step 5: Get ArgoCD Auth Token
Option A - Using ArgoCD CLI:
```bash
# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Login and get token
argocd login EXTERNAL_IP --username admin --password Argo123! --insecure
argocd account generate-token
```

Option B - Using ArgoCD UI:
1. Login to ArgoCD UI
2. Go to User Info (top right) 
3. Generate new token
4. Copy the token

### Step 6: Update terraform.tfvars
```hcl
argocd_auth_token = "your-actual-token-here"
```

### Step 7: Uncomment ArgoCD Resources
1. Uncomment the ArgoCD application in `application.tf`
2. Uncomment the ArgoCD repository in `repository.tf`

### Step 8: Deploy ArgoCD Configuration
```bash
terraform apply
```

## 🎯 Final Result
After both phases, you'll have:
- ✅ AKS cluster with ArgoCD running
- ✅ ArgoCD configured with your GitOps repository
- ✅ Root application deployed
- ✅ Demo applications syncing automatically

## 🔍 Verification
```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Check demo deployments
kubectl get pods -n demo-app
kubectl get pods -n nginx-app
```

## ⚠️ Why Two Phases?
The ArgoCD provider needs to connect to a running ArgoCD server, but we can't deploy ArgoCD resources until ArgoCD itself is running. This chicken-and-egg problem is solved by splitting the deployment into two phases.
