# GitOps Configuration - Backup Instructions
# This file provides manual setup instructions as a fallback reference
# The actual automated GitOps setup is handled in argocd.tf via null_resource.gitops_setup_v2

# SSH Key setup for GitOps (handled in keyvault.tf)
# The SSH key is securely stored in Azure Key Vault and automatically retrieved during setup

# Backup instructions for GitOps setup (for reference or manual execution if needed)
resource "null_resource" "gitops_instructions" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "=== GitOps Setup Instructions ==="
      echo "After ArgoCD is ready, run these commands:"
      echo ""
      echo "# 1. Get SSH key from Key Vault"
      echo "az keyvault secret show --vault-name ${azurerm_key_vault.main.name} --name gitops-ssh-private-key --query value -o tsv > ~/.ssh/gitops_key"
      echo "chmod 600 ~/.ssh/gitops_key"
      echo ""
      echo "# 2. Login to ArgoCD"
      echo "argocd login ${local.argocd_ip} --username admin --password \"\$(az keyvault secret show --vault-name ${azurerm_key_vault.main.name} --name argocd-initial-admin-password --query value -o tsv)\" --insecure"
      echo ""
      echo "# 3. Add repository"
      echo "argocd repo add git@github.com:StanislavYermolenko/terraform-aks-argocd.git --ssh-private-key-path ~/.ssh/gitops_key"
      echo ""
      echo "# 4. Create root application"
      echo "argocd app create root --repo git@github.com:StanislavYermolenko/terraform-aks-argocd.git --path gitops-config/root --dest-server https://kubernetes.default.svc --dest-namespace argocd --sync-policy automated --auto-prune --self-heal"
      echo ""
      echo "# 5. Sync application"
      echo "argocd app sync root"
      echo ""
      echo "=== GitOps Setup Complete ==="
    EOT
  }

  depends_on = [
    helm_release.argocd,
    data.kubernetes_service.argocd_server,
    data.kubernetes_secret.argocd_initial_admin_secret,
    null_resource.argocd_readiness_check,
    kubernetes_namespace.demo_app,
    kubernetes_namespace.nginx_app,
    kubernetes_namespace.staging,
    kubernetes_namespace.production,
    kubernetes_namespace.monitoring,
    azurerm_key_vault_secret.ssh_private_key
  ]
}
