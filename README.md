# 🚀 AKS with ArgoCD and GitOps

A complete Infrastructure as Code (IaC) solution for deploying Azure Kubernetes Service (AKS) with ArgoCD and GitOps workflow using Terraform.

## 📋 Overview

This project provides a fully automated deployment of:
- **Azure Kubernetes Service (AKS)** cluster with networking
- **ArgoCD** for GitOps continuous deployment
- **Kubernetes namespaces** with proper RBAC
- **Demo applications** managed through GitOps workflow
- **Complete CI/CD pipeline** using ArgoCD

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Azure Cloud                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                AKS Cluster                          │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   ArgoCD    │  │  Demo Apps  │  │ Nginx Apps  │ │   │
│  │  │ Namespace   │  │ Namespace   │  │ Namespace   │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ GitOps Sync
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  GitHub Repository                          │
│            StanislavYermolenko/gitops-config               │
└─────────────────────────────────────────────────────────────┘
```

## 🛠️ Technologies Used

- **Infrastructure**: Azure (AKS, VNet, Resource Group)
- **IaC Tool**: Terraform
- **Container Orchestration**: Kubernetes
- **GitOps**: ArgoCD
- **CI/CD**: GitOps workflow
- **Monitoring**: ArgoCD Dashboard

## 📁 Project Structure

```
├── main.tf                     # Core infrastructure (AKS, networking, ArgoCD)
├── ns.tf                       # Kubernetes namespaces
├── application.tf              # ArgoCD application configuration
├── repository.tf               # ArgoCD repository configuration
├── variables.tf                # Variable definitions
├── terraform.tfvars            # Variable values (customize this)
├── argocd-values.yaml         # ArgoCD Helm chart values
├── DEPLOYMENT_GUIDE.md        # Detailed deployment instructions
├── SINGLE_DEPLOYMENT.md       # Single-command deployment guide
├── PRE_IMPLEMENTATION_ANALYSIS.md # Code analysis report
├── DEPENDENCIES.md            # Dependency documentation
└── gitops-config/             # GitOps applications (submodule)
    ├── root/                  # Root ArgoCD applications
    ├── projects/              # ArgoCD projects
    └── apps/                  # Individual application manifests
        ├── docker-image-demo/
        └── nginx-demo/
```

## 🚀 Quick Start

### Prerequisites

- **Azure CLI** installed and configured
- **Terraform** >= 1.0
- **kubectl** installed
- **SSH key** for GitHub access

### One-Command Deployment

```bash
# Clone the repository
git clone <your-repo-url>
cd job

# Customize variables (optional)
vim terraform.tfvars

# Deploy everything
terraform init
terraform apply
```

That's it! This single command will:
1. ✅ Create AKS cluster with networking
2. ✅ Deploy ArgoCD with LoadBalancer
3. ✅ Configure GitOps repository
4. ✅ Deploy demo applications automatically

## 🔧 Configuration

### Required Variables

Update `terraform.tfvars` with your values:

```hcl
resource_group_name = "your-rg-name"
location            = "East US"
subscription_id     = "your-azure-subscription-id"
```

### ArgoCD Access

After deployment, ArgoCD will be accessible at the LoadBalancer IP:
- **URL**: Displayed in Terraform output
- **Username**: `admin`
- **Password**: `Argo123!`

## 📖 Detailed Documentation

- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Step-by-step deployment instructions
- **[SINGLE_DEPLOYMENT.md](SINGLE_DEPLOYMENT.md)** - Single-command deployment guide
- **[DEPENDENCIES.md](DEPENDENCIES.md)** - Dependency analysis and execution order
- **[PRE_IMPLEMENTATION_ANALYSIS.md](PRE_IMPLEMENTATION_ANALYSIS.md)** - Code analysis report

## 🎯 Features

### Infrastructure
- ✅ **Azure AKS** cluster with System Assigned Identity
- ✅ **Virtual Network** with dedicated subnet
- ✅ **Multiple namespaces** with proper labeling
- ✅ **LoadBalancer** service for ArgoCD access

### GitOps
- ✅ **ArgoCD** deployment via Helm
- ✅ **Automated sync** from Git repository
- ✅ **Multi-application** management
- ✅ **Project-based** resource isolation

### Security
- ✅ **SSH key** authentication for Git
- ✅ **RBAC** with managed identity
- ✅ **Network isolation** with VNet
- ✅ **Sensitive variable** protection

## 🔍 Verification

After deployment, verify the setup:

```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Check demo applications
kubectl get pods -n demo-app
kubectl get pods -n nginx-app

# Get ArgoCD URL
terraform output argocd_url
```

## 🛠️ Customization

### Adding New Applications

1. Create application manifests in `gitops-config/apps/`
2. Update `gitops-config/root/demo-applications.yaml`
3. Commit and push - ArgoCD will sync automatically

### Scaling the Cluster

Update `terraform.tfvars`:
```hcl
node_count = 3
vm_size    = "Standard_DS3_v2"
```

Then run `terraform apply`.

## 📊 Monitoring

- **ArgoCD Dashboard**: Monitor application sync status
- **Kubernetes Dashboard**: View cluster resources
- **Azure Portal**: Monitor AKS cluster metrics

## 🔧 Troubleshooting

### Common Issues

1. **ArgoCD not accessible**: Check LoadBalancer IP assignment
2. **Application sync failed**: Verify Git repository access
3. **Resource conflicts**: Check for duplicate applications

### Useful Commands

```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to ArgoCD (alternative access)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-server
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Stanislav Yermolenko**
- GitHub: [@StanislavYermolenko](https://github.com/StanislavYermolenko)

## 🙏 Acknowledgments

- ArgoCD team for the excellent GitOps platform
- HashiCorp for Terraform
- Microsoft Azure for AKS

---

**⭐ If this project helped you, please give it a star!**
