# True IaC Outputs
# Uses native Terraform data sources instead of manual commands

output "argocd_url" {
  description = "ArgoCD Web UI URL"
  value       = local.argocd_ip != "" ? "http://${local.argocd_ip}" : "LoadBalancer IP not yet assigned"
}

output "key_vault_name" {
  description = "Name of the Azure Key Vault containing secrets"
  value       = azurerm_key_vault.main.name
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.aks_cluster_name}"
}

output "ssh_key_vault_location" {
  description = "SSH key location in Key Vault"
  value       = "Key Vault: ${azurerm_key_vault.main.name}, Secret: ${azurerm_key_vault_secret.ssh_private_key.name}"
}

output "argocd_admin_username" {
  description = "ArgoCD admin username"
  value       = "admin"
}

output "argocd_password_command" {
  description = "Command to retrieve ArgoCD admin password from Key Vault"
  value       = "az keyvault secret show --vault-name ${azurerm_key_vault.main.name} --name argocd-initial-admin-password --query value -o tsv"
}


