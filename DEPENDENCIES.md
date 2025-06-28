# Terraform Infrastructure Dependencies Analysis

## File Structure and Dependencies

### Core Infrastructure Files:
- `main.tf` - Main infrastructure (AKS cluster, networking, ArgoCD Helm chart)
- `ns.tf` - Kubernetes namespaces (NEW FILE)
- `application.tf` - ArgoCD application configuration
- `repository.tf` - ArgoCD repository configuration
- `variables.tf` - Variable definitions
- `terraform.tfvars` - Variable values

## Dependency Chain

### 1. Azure Infrastructure Layer
```
azurerm_resource_group.aks_rg
├── azurerm_virtual_network.aks_vnet
│   └── azurerm_subnet.aks_subnet
│       └── azurerm_kubernetes_cluster.aks
```

### 2. Kubernetes Layer
```
azurerm_kubernetes_cluster.aks
├── helm_release.argocd (creates argocd namespace)
├── kubernetes_namespace.demo_app
├── kubernetes_namespace.nginx_app
├── kubernetes_namespace.production
└── kubernetes_namespace.staging
```

### 3. ArgoCD Configuration Layer
```
helm_release.argocd
├── argocd_repository.gitops_config
└── argocd_application.root
    ├── depends_on: helm_release.argocd
    ├── depends_on: kubernetes_namespace.demo_app
    └── depends_on: kubernetes_namespace.nginx_app
```

## Namespace Analysis

### Created by Terraform (`ns.tf`):
1. **demo-app** - For demo applications
2. **nginx-app** - For nginx applications  
3. **production** - For production workloads (future use)
4. **staging** - For staging workloads (future use)

### Created by Helm:
1. **argocd** - Created automatically by `helm_release.argocd`

### Referenced in GitOps Config:
- `argocd` - ArgoCD applications and projects
- `demo-app` - Docker image demo application
- `nginx-app` - Nginx demo application

## Key Dependencies Configured:

1. **Namespaces depend on AKS cluster**: All namespace resources have `depends_on = [azurerm_kubernetes_cluster.aks]`

2. **ArgoCD Application depends on**:
   - `helm_release.argocd` (ArgoCD must be installed first)
   - `kubernetes_namespace.demo_app` (target namespace must exist)
   - `kubernetes_namespace.nginx_app` (target namespace must exist)

3. **Repository configuration**: Independent of namespaces but requires ArgoCD to be running

## Execution Order:
1. Azure Resource Group
2. Virtual Network
3. Subnet
4. AKS Cluster
5. Kubernetes Namespaces (demo-app, nginx-app, production, staging)
6. ArgoCD Helm Chart (creates argocd namespace)
7. ArgoCD Repository Configuration
8. ArgoCD Root Application

## Security Considerations:
- SSH private key for GitOps repository is referenced from `~/.ssh/id_rsa`
- ArgoCD admin password is hashed in `argocd-values.yaml`
- ArgoCD auth token should be set in `terraform.tfvars` (currently placeholder)

## Notes:
- The ArgoCD application points to the "root" path in the GitOps repository
- All namespaces are properly labeled for management and environment tracking
- Future namespaces (production, staging) are prepared for expansion
