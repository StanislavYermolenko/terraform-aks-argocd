# Create required namespaces
resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}

resource "kubernetes_namespace" "demo_app" {
  metadata {
    name = "demo-app"
  }
}

resource "kubernetes_namespace" "nginx_app" {
  metadata {
    name = "nginx-app"
  }
}
