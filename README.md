# AKS + ArgoCD + Monitoring Stack

Production-ready Infrastructure as Code solution deploying Azure Kubernetes Service with ArgoCD GitOps and a complete monitoring stack (Prometheus, Grafana, Loki, Promtail).

## 🚀 What Gets Deployed

- **AKS Cluster** with Azure Key Vault integration
- **ArgoCD** for GitOps workflow management
- **Complete Monitoring Stack**:
  - Prometheus (metrics collection)
  - Grafana (visualization with LoadBalancer)
  - Alertmanager (alerting)
  - Loki (log aggregation)
  - Promtail (log collection)
  - Node Exporter & Kube State Metrics
- **Demo Applications** (nginx, docker-image demos)

## 🏗️ Architecture

```
Azure Infrastructure (Terraform)
├── AKS Cluster + Key Vault + Networking
├── Prometheus CRDs (automated installation)
└── ArgoCD Installation

GitOps Applications (ArgoCD)
├── monitoring-stack project
│   ├── prometheus (metrics)
│   ├── grafana (dashboards) 
│   ├── loki (logs)
│   └── promtail (log collection)
└── default project
    ├── docker-image-demo
    └── nginx-demo
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| `main.tf` | AKS cluster and core infrastructure |
| `keyvault.tf` | Azure Key Vault for secrets |
| `prometheus-crds.tf` | **Automated CRD installation** |
| `argocd.tf` | ArgoCD installation and GitOps setup |
| `gitops-config/apps/` | **Monitoring applications** |
| `gitops-config/projects/` | ArgoCD projects and RBAC |

## 🛠️ Prerequisites

- Azure CLI: `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
- Terraform >= 1.0
- Azure subscription with contributor access

## 🚀 Quick Deployment

```bash
# 1. Clone repository
git clone https://github.com/StanislavYermolenko/terraform-aks-argocd.git
cd terraform-aks-argocd

# 2. Azure authentication
az login
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

# 3. Deploy everything
terraform init
terraform apply
```

**That's it!** The entire infrastructure deploys automatically.

## � Access Your Stack

### **ArgoCD Dashboard**
```bash
# Get external IP
kubectl get svc argocd-server -n argocd

# Get admin password  
az keyvault secret show --vault-name <vault-name> --name argocd-initial-admin-password --query value -o tsv
```

### **Grafana Dashboard** 
```bash
# Get Grafana LoadBalancer IP
kubectl get svc grafana -n monitoring

# Login: admin / admin123
# Data sources: Prometheus + Loki (pre-configured)
```

### **View Logs in Grafana**
1. Go to **Explore** → Select **Loki** data source
2. Try these queries:
   ```logql
   {namespace="monitoring"}              # All monitoring logs
   {namespace="monitoring"} |= "error"   # Error logs only
   {pod=~"prometheus.*"}                 # Prometheus pod logs
   ```

## 🎯 What's Automated

✅ **Infrastructure**: AKS + Key Vault + Networking  
✅ **CRDs**: Prometheus Operator CRDs (avoids Helm issues)  
✅ **ArgoCD**: Installed and configured with GitOps  
✅ **Monitoring**: Complete stack with persistent storage  
✅ **Data Sources**: Grafana pre-configured with Prometheus + Loki  
✅ **Applications**: Demo apps deployed via GitOps

## 🔧 Customization

Modify `terraform.tfvars` to customize resource names, regions, and sizing.

Edit `gitops-config/apps/*.yaml` to modify monitoring stack configuration.

## 🗑️ Cleanup

```bash
terraform destroy
```

- **Azure Key Vault Integration**: All secrets stored securely
- **No Hardcoded Credentials**: Dynamic secret generation
- **RBAC Enabled**: Role-based access control on AKS
- **Private Networking**: Resources deployed in dedicated VNet
- **SSH Key Management**: Automated SSH key generation for GitOps

## 🔄 GitOps Workflow

The solution automatically configures:

1. **Repository Connection**: Adds your GitOps repository to ArgoCD
2. **Root Application**: Creates an App-of-Apps pattern
3. **Automatic Sync**: Enables auto-sync with self-healing
4. **Application Management**: Deploys applications from your GitOps repo

## 📊 Resource Inventory

| Resource Type | Count | Purpose |
|---------------|-------|---------|
| Resource Group | 1 | Container for all resources |
| Virtual Network | 1 | Network isolation |
| Subnet | 1 | AKS node placement |
| AKS Cluster | 1 | Kubernetes platform |
| Key Vault | 1 | Secret management |
| Key Vault Secrets | 2 | ArgoCD password + SSH key |
| Kubernetes Namespaces | 4 | Application isolation |
| Helm Releases | 1 | ArgoCD installation |

## 🧪 Validation

The infrastructure includes built-in validation:

- **ArgoCD Readiness**: Health checks before GitOps setup
- **API Validation**: Ensures ArgoCD API is responsive
- **Automated Setup**: CLI-based GitOps configuration
- **Error Handling**: Graceful handling of existing resources

## 🔧 Customization

### Variables
Modify `terraform.tfvars` to customize:
- Resource group name and location
- AKS node size and count
- Network address spaces
- Application namespaces

### ArgoCD Configuration
Modify `argocd-values.yaml` to customize:
- Service type and configuration
- Replica counts
- Feature enablement
- Security settings

## � Monitoring Stack

The solution includes a complete observability stack deployed via GitOps:

### **Components Deployed**
- **Prometheus**: Metrics collection and time-series database
- **Alertmanager**: Alert routing and management
- **Grafana**: Visualization and dashboarding with LoadBalancer access
- **Loki**: Log aggregation and storage
- **Promtail**: Log collection from all cluster nodes
- **Node Exporter**: Node-level metrics
- **Kube State Metrics**: Kubernetes cluster metrics

### **Automated Configuration**
- **Pre-configured Data Sources**: Prometheus and Loki automatically connected to Grafana
- **Persistent Storage**: All stateful components use Azure managed-csi storage
- **GitOps Managed**: All monitoring components deployed and managed via ArgoCD
- **RBAC Compliant**: Proper permissions and security contexts

### **Access Points**
```bash
# Access Grafana (admin/admin123)
kubectl get svc grafana -n monitoring

# Access Prometheus (internal)
kubectl port-forward svc/prometheus-prometheus -n monitoring 9090:9090

# Access ArgoCD to manage monitoring apps
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### **Custom Resource Definitions (CRDs)**
The `prometheus-crds.tf` file automatically installs required Prometheus Operator CRDs to avoid Helm chart annotation size issues:
- `prometheuses.monitoring.coreos.com`
- `prometheusagents.monitoring.coreos.com`  
- `alertmanagers.monitoring.coreos.com`
- `servicemonitors.monitoring.coreos.com`
- `prometheusrules.monitoring.coreos.com`

## �🗑️ Cleanup

```bash
# Destroy all resources
terraform destroy
```

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [GitOps Best Practices](https://www.gitops.tech/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🏆 Project Status

✅ **Production Ready** - Fully tested and validated  
✅ **Security Compliant** - All secrets properly managed  
✅ **Highly Automated** - Zero manual intervention required  
✅ **Well Documented** - Comprehensive documentation provided  

---

**Built with ❤️ using Terraform, Azure, Kubernetes, and ArgoCD**