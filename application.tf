resource "argocd_application" "root" {
  metadata {
    name      = "root"
    namespace = "argocd"
  }

  spec {
    project = "default"
    source {
      repo_url        = "git@github.com:StanislavYermolenko/gitops-config.git"
      target_revision = "master"
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
    null_resource.wait_for_argocd,
    kubernetes_namespace.demo_app,
    kubernetes_namespace.nginx_app,
    argocd_repository.gitops_config
  ]
}
