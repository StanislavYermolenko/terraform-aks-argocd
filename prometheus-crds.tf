# Prometheus Operator CRDs
# These CRDs need to be installed before the Prometheus Operator can function
# We install them separately to avoid annotation size issues with the Helm chart

resource "kubernetes_manifest" "prometheus_crd" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind       = "CustomResourceDefinition"
    metadata = {
      name = "prometheuses.monitoring.coreos.com"
    }
  }

  # Download and apply the CRD from the official Prometheus Operator repository
  depends_on = [azurerm_kubernetes_cluster.aks]

  lifecycle {
    ignore_changes = [
      manifest["metadata"]["annotations"],
      manifest["spec"]
    ]
  }
}

resource "kubernetes_manifest" "prometheusagent_crd" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind       = "CustomResourceDefinition"
    metadata = {
      name = "prometheusagents.monitoring.coreos.com"
    }
  }

  depends_on = [azurerm_kubernetes_cluster.aks]

  lifecycle {
    ignore_changes = [
      manifest["metadata"]["annotations"],
      manifest["spec"]
    ]
  }
}

# Use kubectl to apply the actual CRD definitions
resource "null_resource" "install_prometheus_crds" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  provisioner "local-exec" {
    command = <<-EOT
      # Set kubeconfig context
      az aks get-credentials --resource-group ${azurerm_resource_group.aks_rg.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing

      # Install core Prometheus CRDs that have annotation size issues in Helm charts
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml || true
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml || true
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml || true
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml || true
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml || true
    EOT
  }

  # Trigger re-run if CRDs are missing
  triggers = {
    cluster_id = azurerm_kubernetes_cluster.aks.id
    timestamp  = timestamp()
  }
}
