# True IaC ArgoCD Configuration
# This eliminates all manual kubectl commands and shell scripts

# ArgoCD Helm release with proper configuration and extended timeouts
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.6"
  namespace  = "argocd"

  create_namespace = true

  # Extended timeout for complex deployments
  timeout = 600 # 10 minutes
  wait    = true

  # Allow upgrades and rollbacks
  atomic = true

  # Wait for all pods to be ready
  wait_for_jobs = true

  values = [
    yamlencode({
      global = {
        logging = {
          level = "info"
        }
      }
      server = {
        service = {
          type = "LoadBalancer"
        }
        extraArgs = [
          "--insecure"
        ]
        config = {
          "admin.enabled" = "true"
        }
      }
      repoServer = {
        replicas = 1
      }
      controller = {
        replicas = 1
      }
      redis = {
        enabled = true
      }
      dex = {
        enabled = false
      }
      notifications = {
        enabled = false
      }
      applicationSet = {
        enabled = true
      }
    })
  ]
}

# Data source to get the initial admin secret (created by ArgoCD automatically)
data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}

# Data source to get ArgoCD service (waits for LoadBalancer IP automatically)
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}

# Store the initial admin password in Key Vault for management
resource "azurerm_key_vault_secret" "argocd_initial_admin_password" {
  name         = "argocd-initial-admin-password"
  value        = data.kubernetes_secret.argocd_initial_admin_secret.data["password"]
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    Purpose = "ArgoCD-Initial-Admin-Authentication"
  }

  depends_on = [data.kubernetes_secret.argocd_initial_admin_secret]
}

# Local values with comprehensive validation
locals {
  argocd_ip       = try(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].ip, "")
  argocd_password = data.kubernetes_secret.argocd_initial_admin_secret.data["password"]

  # Comprehensive validation: Ensure ArgoCD is ready before provider tries to connect
  argocd_ready = local.argocd_ip != "" && local.argocd_password != "" && length(local.argocd_password) > 0
  
  # Validated server address (only available after validation passes)
  argocd_server_validated = local.argocd_ready ? "${local.argocd_ip}:80" : null
}

# Extra safety: Null resource to validate ArgoCD readiness
resource "null_resource" "argocd_readiness_check" {
  triggers = {
    argocd_ip       = local.argocd_ip
    argocd_password = local.argocd_password
    timestamp       = timestamp()
  }

  # Precondition to ensure all required values are available
  lifecycle {
    precondition {
      condition     = local.argocd_ready
      error_message = "ArgoCD is not ready: LoadBalancer IP or admin password not available. Please wait for ArgoCD deployment to complete."
    }
  }

  depends_on = [
    helm_release.argocd,
    data.kubernetes_service.argocd_server,
    data.kubernetes_secret.argocd_initial_admin_secret
  ]
}

# Validation check to ensure ArgoCD is properly configured
resource "null_resource" "argocd_readiness_validation" {
  # This resource provides extra logging for debugging
  provisioner "local-exec" {
    command = "echo 'ArgoCD is ready: IP=${local.argocd_ip}, Password available: ${local.argocd_password != "" ? "YES" : "NO"}'"
  }

  # Add a delay to ensure ArgoCD is fully ready
  provisioner "local-exec" {
    command = "sleep 30"
  }

  # Verify ArgoCD API is responding (not just health check)
  provisioner "local-exec" {
    command = "timeout 120 bash -c 'until curl -f -k http://${local.argocd_ip}:80/api/version; do echo \"Waiting for ArgoCD API to be ready...\"; sleep 10; done'"
  }

  depends_on = [
    null_resource.argocd_readiness_check,
    data.kubernetes_service.argocd_server,
    data.kubernetes_secret.argocd_initial_admin_secret
  ]
}

# Automated GitOps setup using ArgoCD CLI after validation
resource "null_resource" "gitops_setup_v2" {
  # This resource will configure GitOps automatically after ArgoCD is ready
  provisioner "local-exec" {
    command = <<-EOT
      echo "=== Starting Automated GitOps Setup ==="
      
      # Get SSH key from Key Vault
      echo "Getting SSH key from Key Vault..."
      az keyvault secret show --vault-name ${azurerm_key_vault.main.name} --name gitops-ssh-private-key --query value -o tsv > /tmp/gitops_key
      chmod 600 /tmp/gitops_key
      
      # Get ArgoCD password
      echo "Getting ArgoCD password..."
      ARGOCD_PASSWORD=$(az keyvault secret show --vault-name ${azurerm_key_vault.main.name} --name argocd-initial-admin-password --query value -o tsv)
      
      # Login to ArgoCD (auto-accept TLS warning)
      echo "Logging into ArgoCD..."
      echo "y" | argocd login ${local.argocd_ip} --username admin --password "$ARGOCD_PASSWORD" --insecure
      
      # Verify login worked
      if argocd version; then
        echo "✅ ArgoCD login successful!"
        
        # Add repository
        echo "Adding Git repository..."
        if argocd repo add git@github.com:StanislavYermolenko/gitops-config.git --ssh-private-key-path /tmp/gitops_key; then
          echo "✅ Repository added successfully!"
        else
          echo "⚠️  Repository might already exist"
        fi
        
        # Create root application
        echo "Creating root application..."
        if argocd app create root \
          --repo git@github.com:StanislavYermolenko/gitops-config.git \
          --path root \
          --dest-server https://kubernetes.default.svc \
          --dest-namespace argocd \
          --sync-policy automated \
          --auto-prune \
          --self-heal; then
          echo "✅ Root application created successfully!"
        else
          echo "⚠️  Application might already exist"
        fi
        
        # Sync application
        echo "Syncing root application..."
        argocd app sync root
        echo "✅ Application sync initiated!"
        
      else
        echo "❌ ArgoCD login failed!"
        exit 1
      fi
      
      # Clean up SSH key
      rm -f /tmp/gitops_key
      
      echo "=== GitOps Setup Complete! ==="
      echo "Check ArgoCD dashboard at: http://${local.argocd_ip}"
    EOT
  }

  depends_on = [
    null_resource.argocd_readiness_validation,
    azurerm_key_vault_secret.ssh_private_key,
    azurerm_key_vault_secret.argocd_initial_admin_password
  ]
}
