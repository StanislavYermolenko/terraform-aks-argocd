# Single Command Deployment Guide

## 🚀 **One-Command Deployment (Fully Dynamic)**

Your infrastructure is now configured for proper IaC deployment with **dynamic IP resolution**!

### **Deploy Everything:**
```bash
terraform apply
```

This single command will:
1. ✅ Create Azure Resource Group
2. ✅ Deploy Virtual Network & Subnet
3. ✅ Create AKS Cluster
4. ✅ Deploy Kubernetes Namespaces
5. ✅ Install ArgoCD via Helm (gets dynamic LoadBalancer IP)
6. ✅ Get ArgoCD LoadBalancer IP dynamically
7. ✅ Wait for ArgoCD to be ready (with dynamic IP health check)
8. ✅ Configure ArgoCD Repository (with your SSH key)
9. ✅ Deploy ArgoCD Root Application

### **Dynamic Features:**
- 🔄 **No Hardcoded IPs**: ArgoCD IP is retrieved dynamically
- 🔄 **Proper IaC**: Everything is infrastructure-as-code
- 🔄 **Self-Discovering**: Provider configures itself with real LoadBalancer IP
- 🔄 **Output URLs**: Terraform shows you the actual ArgoCD URL after deployment

### **After Deployment:**
Terraform will output:
```
Outputs:

argocd_url = "http://DYNAMIC_LOADBALANCER_IP"
argocd_admin_password = "Argo123!"
kubeconfig_command = "az aks get-credentials --resource-group my-aks-rg --name my-aks-cluster"
```

### **Access ArgoCD:**
```bash
# ArgoCD will be accessible at the dynamic IP shown in outputs
# Login: admin / Argo123!
# Your GitOps applications will sync from: git@github.com:StanislavYermolenko/gitops-config.git
```

### **Deployment Order:**
```
Azure Infrastructure → AKS → Namespaces → ArgoCD → Get Dynamic IP → Wait → Repository → Applications
```

### **Estimated Time:**
- Total deployment: ~20-25 minutes
- ArgoCD readiness wait: ~2-3 minutes
- Application sync: ~1-2 minutes

### **Verification:**
```bash
# Get kubeconfig
az aks get-credentials --resource-group my-aks-rg --name my-aks-cluster

# Check ArgoCD applications
kubectl get applications -n argocd

# Check your demo apps
kubectl get pods -n demo-app
kubectl get pods -n nginx-app

# Get ArgoCD URL (if you missed the output)
kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## 🎯 **Key Features:**
- ✅ **Single Command**: No manual steps required
- ✅ **Fully Dynamic**: No hardcoded IPs anywhere
- ✅ **Proper IaC**: True infrastructure-as-code approach
- ✅ **Auto-Discovery**: Provider finds ArgoCD automatically
- ✅ **SSH Integration**: Uses your existing SSH key
- ✅ **GitOps Ready**: Applications sync automatically
- ✅ **Clean Outputs**: Shows all connection info after deployment

**Ready to deploy? Run: `terraform apply`**
