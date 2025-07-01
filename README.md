# AKS + ArgoCD + GitOps Infrastructure as Code

A fully automated, secure, and modular Infrastructure as Code (IaC) solution for deploying Azure Kubernetes Service (AKS), ArgoCD, and GitOps workflows on Azure using Terraform with Azure Key Vault (AKV) for comprehensive secret management.

## 🚀 Features

- **Fully Automated**: Zero manual steps required for deployment
- **Secure by Design**: All secrets managed in Azure Key Vault
- **Modular Architecture**: Clean separation of concerns across multiple Terraform files
- **GitOps Ready**: Automated ArgoCD setup with repository and application configuration
- **Production Ready**: Includes networking, RBAC, and proper resource management
- **Reproducible**: Validated through multiple deploy/destroy cycles

## 🏗️ Architecture

```
Azure Resource Group
├── Virtual Network (10.0.0.0/8)
│   └── AKS Subnet (10.240.0.0/16)
├── AKS Cluster (1 node, Standard_DS2_v2)
├── Azure Key Vault
│   ├── ArgoCD Admin Password
│   └── GitOps SSH Private Key
└── ArgoCD (Helm Chart)
    ├── LoadBalancer Service
    ├── Automated GitOps Setup
    └── Application Sync
```

## 📁 File Structure

This project uses a **modular Terraform structure** following enterprise best practices:

| File | Purpose | Description |
|------|---------|-------------|
| `terraform.tf` | **Core Configuration** | Terraform version constraints and required providers |
| `providers.tf` | **Provider Setup** | Azure, Kubernetes, and Helm provider configurations |
| `variables.tf` | **Input Variables** | Configurable parameters for the deployment |
| `infrastructure.tf` | **Azure Infrastructure** | Resource group, VNet, subnet, and AKS cluster |
| `keyvault.tf` | **Secret Management** | Azure Key Vault and secure secret storage |
| `kubernetes.tf` | **K8s Resources** | Kubernetes namespaces and basic resources |
| `argocd.tf` | **ArgoCD & Automation** | ArgoCD Helm installation and automated GitOps setup |
| `gitops.tf` | **GitOps Instructions** | Backup manual setup instructions for reference |
| `outputs.tf` | **Output Values** | Access information and connection details |
| `argocd-values.yaml` | **ArgoCD Config** | Helm values for ArgoCD customization |
| `gitops-config/` | **GitOps Applications** | ArgoCD applications using App-of-Apps pattern |

## 🛠️ Prerequisites

- Azure CLI installed and authenticated
- Terraform >= 1.0
- kubectl (for Kubernetes access, optional for troubleshooting)

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install kubectl (optional, for troubleshooting)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Login to Azure
az login

# Set your Azure subscription ID
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
# Or manually: export ARM_SUBSCRIPTION_ID="your-subscription-id-here"
```

## 🚀 Quick Start

### 1. Clone and Configure
```bash
git clone https://github.com/StanislavYermolenko/terraform-aks-argocd.git
cd terraform-aks-argocd

# Review and modify variables if needed
vi terraform.tfvars
```

### 2. Deploy Infrastructure
```bash
# Set Azure subscription ID (required)
export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy infrastructure
terraform apply
```

### 3. Access ArgoCD
```bash
# Get connection information
terraform output

# Get ArgoCD password
az keyvault secret show --vault-name <key-vault-name> --name argocd-initial-admin-password --query value -o tsv

# Configure kubectl
az aks get-credentials --resource-group my-aks-rg --name my-aks-cluster

# Access ArgoCD UI at the provided URL
```

## 🔐 Security Features

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

## 🗑️ Cleanup

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