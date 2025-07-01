# True IaC Key Vault Configuration
# Eliminates manual password generation and uses Terraform-native approaches

# Generate random suffix for unique Key Vault name
resource "random_string" "kv_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Azure Key Vault
resource "azurerm_key_vault" "main" {
  name                = "kv-aks-${random_string.kv_suffix.result}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Current user access policy
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"
    ]
  }

  # AKS managed identity access policy
  access_policy {
    tenant_id = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
    object_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id

    secret_permissions = [
      "Get", "List"
    ]
  }

  tags = {
    Environment = var.environment
    Purpose     = "AKS-GitOps-Secrets"
  }
}

# Store SSH private key in Key Vault (for GitOps repository access)
resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "gitops-ssh-private-key"
  value        = file("~/.ssh/id_ed25519_anonymous")
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    Purpose = "GitOps-Repository-Access"
  }

  depends_on = [azurerm_key_vault.main]
}
