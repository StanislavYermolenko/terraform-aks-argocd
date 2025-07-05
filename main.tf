data "template_file" "jenkins_secretstore" {
  template = file("${path.module}/gitops-config/manifests/jenkins/azure-keyvault-secretstore.yaml.tpl")
  vars = {
    tenant_id = var.tenant_id
    vault_url = azurerm_key_vault.main.vault_uri
  }
}

resource "kubernetes_manifest" "jenkins_secretstore" {
  manifest = yamldecode(data.template_file.jenkins_secretstore.rendered)
}