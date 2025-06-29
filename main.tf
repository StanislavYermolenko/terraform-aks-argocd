terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

# Data source to get ArgoCD service LoadBalancer IP
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }
  
  depends_on = [helm_release.argocd]
}

provider "argocd" {
  server_addr = "${data.kubernetes_service.argocd_server.status.0.load_balancer.0.ingress.0.ip}:80"
  username    = "admin"
  password    = "Argo123!"
  insecure    = true
}

resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.6"
  namespace  = "argocd"

  create_namespace = true

  values = [
    file("${path.module}/argocd-values.yaml")
  ]
}

# Wait for ArgoCD to be ready before configuring it
resource "null_resource" "wait_for_argocd" {
  depends_on = [helm_release.argocd]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for ArgoCD to be ready..."
      sleep 60
      
      # Get the LoadBalancer IP dynamically
      ARGOCD_IP=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
      echo "ArgoCD LoadBalancer IP: $ARGOCD_IP"
      
      # Wait for ArgoCD server to be accessible
      timeout 300 bash -c "
        until curl -k -s http://$ARGOCD_IP/healthz > /dev/null 2>&1; do
          echo 'Waiting for ArgoCD server to be ready...'
          sleep 10
        done
      "
      echo "ArgoCD is ready at http://$ARGOCD_IP"
    EOT
  }
  
  triggers = {
    argocd_service = data.kubernetes_service.argocd_server.status.0.load_balancer.0.ingress.0.ip
  }
}

# Output the ArgoCD URL
output "argocd_url" {
  description = "ArgoCD Web UI URL"
  value       = "http://${data.kubernetes_service.argocd_server.status.0.load_balancer.0.ingress.0.ip}"
  depends_on  = [helm_release.argocd]
}

output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = "Argo123!"
  sensitive   = false
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.aks_cluster_name}"
}