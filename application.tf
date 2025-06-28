resource "argocd_application" "root" {
  metadata {
    name      = "root"
    namespace = "argocd"
  }

  spec {
    project = "default"
    source {
      repo_url        = "git@github.com:StanislavYermolenko/gitops-config.git"
      target_revision = "main"
      path            = "root"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argocd"
    }

    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_namespace.demo_app,
    kubernetes_namespace.nginx_app
  ]
}
