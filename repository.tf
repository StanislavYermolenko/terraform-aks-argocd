resource "argocd_repository" "gitops_config" {
  repo = "git@github.com:StanislavYermolenko/gitops-config.git"
  type = "git"
  name = "gitops-config"
  ssh_private_key = file("~/.ssh/id_rsa")
}
