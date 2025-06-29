# Namespace for ArgoCD (created by Helm, but we can reference it)
# The argocd namespace is automatically created by helm_release.argocd

# Namespace for demo applications
resource "kubernetes_namespace" "demo_app" {
  metadata {
    name = "demo-app"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = "demo"
    }
    annotations = {
      "description" = "Namespace for demo applications managed by ArgoCD"
    }
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Namespace for nginx applications
resource "kubernetes_namespace" "nginx_app" {
  metadata {
    name = "nginx-app"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = "demo"
    }
    annotations = {
      "description" = "Namespace for nginx applications managed by ArgoCD"
    }
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Namespace for production workloads (optional - for future use)
resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = "production"
    }
    annotations = {
      "description" = "Namespace for production applications"
    }
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Namespace for staging workloads (optional - for future use)
resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = "staging"
    }
    annotations = {
      "description" = "Namespace for staging applications"
    }
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}
