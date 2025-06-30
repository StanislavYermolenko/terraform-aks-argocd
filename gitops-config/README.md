# GitOps Configuration Repository

This repository contains the GitOps configuration for applications managed by ArgoCD using the **App-of-Apps pattern**. It defines the declarative state of all applications and projects deployed on the AKS cluster.

## 🏗️ Repository Structure

```
gitops-config/
├── root/                           # Root Application (App-of-Apps)
│   ├── applications.yaml          # GitOps projects application
│   └── demo-applications.yaml     # Demo applications
├── projects/                       # ArgoCD Project Definitions
│   └── docker-apps.yaml          # Project for containerized applications
└── apps/                          # Application Manifests
    ├── docker-image-demo/         # Docker demo application
    │   ├── deployment.yaml
    │   └── service.yaml
    └── nginx-demo/                # Nginx demo application
        ├── deployment.yaml
        ├── service.yaml
        └── kustomization.yaml
```

## 🎯 ArgoCD App-of-Apps Pattern

This repository implements the **App-of-Apps pattern**, which is an ArgoCD best practice for managing multiple applications:

### Root Application
- **Location**: `root/`
- **Purpose**: Entry point that creates and manages all other ArgoCD applications
- **Benefits**: Centralized management, dependency handling, consistent deployments

### Project Structure
- **Location**: `projects/`
- **Purpose**: Defines ArgoCD Projects for organizing and securing applications
- **Features**: RBAC, resource restrictions, repository access control

### Application Configurations
- **Location**: `apps/`
- **Purpose**: Individual application definitions
- **Contains**: Kubernetes manifests, Helm charts, Kustomize configurations

## 🚀 How It Works

1. **Root Application Deployment**: ArgoCD creates the root application from `root/`
2. **Project Creation**: Root app deploys ArgoCD projects from `projects/`
3. **Application Sync**: Root app deploys individual applications from `apps/`
4. **Continuous Monitoring**: ArgoCD monitors this repo for changes and auto-syncs

## 📦 Current Applications

| Application | Namespace | Description | Status | ArgoCD App |
|-------------|-----------|-------------|---------|------------|
| **docker-image-demo** | `demo-app` | Docker container demo application | Active | docker-image-demo-app |
| **nginx-demo** | `nginx-app` | Nginx web server demonstration | Active | nginx-demo-app |

### Docker Image Demo
- **Namespace**: `demo-app`
- **Type**: Custom Docker application
- **Resources**: Deployment, Service
- **ArgoCD Project**: docker-apps

### Nginx Demo
- **Namespace**: `nginx-app`
- **Type**: Nginx web server
- **Resources**: Deployment, Service, Kustomization
- **ArgoCD Project**: docker-apps

## 🔄 GitOps Workflow

```
Git Commit → GitOps Repo → ArgoCD Detects Change → Auto Sync → Deploy to Cluster → Application Running
```

## 🛠️ Adding New Applications

### 1. Create Application Manifest
Create a new directory in `apps/` with your Kubernetes manifests:

```bash
mkdir apps/my-new-app
# Add your deployment.yaml, service.yaml, etc.
```

### 2. Update Root Application
Add reference to your new app in `root/demo-applications.yaml`:

```yaml
# Add your application definition
```

### 3. Commit and Push
```bash
git add .
git commit -m "feat: add my-new-app application"
git push origin main
```

ArgoCD will automatically detect and deploy your new application!

## 🔧 ArgoCD Configuration

### Projects
- **docker-apps**: Manages containerized applications in demo-app and nginx-app namespaces
- **RBAC**: Controlled access to specific namespaces and resources
- **Resource Quotas**: Limits on CPU, memory, and storage

### Applications
- **gitops-projects**: Manages ArgoCD projects (App-of-Apps pattern)
- **docker-image-demo-app**: Deploys docker demo application
- **nginx-demo-app**: Deploys nginx demo application

### Sync Policies
- **Automated Sync**: Applications automatically sync on Git changes
- **Self-Healing**: Automatic correction of configuration drift
- **Pruning**: Removal of resources deleted from Git
- **CreateNamespace**: Automatically creates target namespaces

## 🔐 Security & RBAC

### Application Isolation
- Each application deploys to its own namespace
- Network policies control inter-application communication
- Resource limits prevent resource exhaustion

### Access Control
- Projects provide RBAC boundaries
- Repository access restrictions
- Namespace-specific permissions

## 🚀 Usage

This repository is automatically synced by ArgoCD using the **App-of-Apps pattern**. Any changes pushed to the `master` branch will be automatically deployed to the AKS cluster.

### Automatic Deployment Process
1. **Git Push**: Developer commits changes to this repository
2. **ArgoCD Detection**: ArgoCD polls and detects changes
3. **Sync Trigger**: Automatic sync begins based on policies
4. **Resource Apply**: Kubernetes resources are created/updated
5. **Health Check**: ArgoCD monitors application health

## 🔄 Sync Process

```
Git Push → ArgoCD Detects Changes → Sync Applications → Deploy to K8s → Health Monitoring
```

## � Monitoring & Observability

### ArgoCD Dashboard
- Application status and health monitoring
- Deployment history and rollback capabilities
- Resource consumption and events tracking

### GitOps Metrics
- Sync frequency and success rates
- Deployment lead times
- Configuration drift detection

## 🚨 Troubleshooting

### Application Won't Sync
1. Check ArgoCD application status in dashboard
2. Verify Git repository access and credentials
3. Check resource quotas and RBAC permissions
4. Review application logs and events

### Common Issues
- **Namespace conflicts**: Ensure unique namespace names
- **RBAC permissions**: Verify project access rights
- **Resource limits**: Check CPU/memory quotas
- **Git access**: Validate repository connectivity

## 📚 Best Practices

1. **Atomic Commits**: Keep related changes together
2. **Descriptive Messages**: Clear commit messages for audit trail
3. **Branch Protection**: Use PR reviews for production changes
4. **Secrets Management**: Never commit secrets to Git (use Azure Key Vault)
5. **Testing**: Validate configurations before merging
6. **Environment Separation**: Use different branches/repositories for environments

## 🔗 Related Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://www.gitops.tech/)
- [App-of-Apps Pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/)

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch
3. Make your changes following GitOps principles
4. Test in staging environment (if available)
5. Submit a pull request with clear description

## 📄 Integration

This GitOps repository is part of a larger Infrastructure as Code solution:
- **Main IaC Repository**: Contains Terraform code for AKS + ArgoCD deployment
- **Azure Key Vault**: Manages all secrets and credentials
- **Automated Setup**: Fully automated infrastructure and GitOps configuration

---

**🚀 Powered by ArgoCD and GitOps principles for reliable, scalable application delivery on Azure Kubernetes Service**
