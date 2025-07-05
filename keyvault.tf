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

resource "azuread_application" "eso" {
  display_name = "aks-eso-identity"
}

resource "azuread_service_principal" "eso" {
  application_id = azuread_application.eso.application_id
}

resource "azuread_application_federated_identity_credential" "eso" {
  application_object_id = azuread_application.eso.object_id
  display_name          = "eso-federated-cred"
  description           = "Federated identity for ESO in jenkins namespace"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject               = "system:serviceaccount:jenkins:external-secrets-sa"
}

resource "azurerm_role_assignment" "eso_kv_access" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.eso.id
}

variable "github_username" {
  description = "GitHub username for CI/CD integration"
  type        = string
}

variable "github_token" {
  description = "GitHub token for CI/CD integration"
  type        = string
  sensitive   = true
}

resource "azurerm_key_vault_secret" "github_username" {
  name         = "github-username"
  value        = var.github_username
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "github_token" {
  name         = "github-token"
  value        = var.github_token
  key_vault_id = azurerm_key_vault.main.id
}
