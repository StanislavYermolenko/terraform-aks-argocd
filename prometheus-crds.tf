# Prometheus Operator CRDs
# These CRDs need to be installed before the Prometheus Operator can function
# We install them separately to avoid annotation size issues with the Helm chart
# Using null_resource with kubectl for reliable CRD installation

# Use kubectl to apply the actual CRD definitions
resource "null_resource" "install_prometheus_crds" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  provisioner "local-exec" {
    command = <<-EOT
      # Set kubeconfig context
      az aks get-credentials --resource-group ${azurerm_resource_group.aks_rg.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing

      # Wait for cluster to be ready
      kubectl cluster-info --request-timeout=30s

      # Install core Prometheus CRDs that have annotation size issues in Helm charts
      echo "Installing Prometheus Operator CRDs..."
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml || echo "Failed to install prometheuses CRD"
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml || echo "Failed to install prometheusagents CRD"
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml || echo "Failed to install alertmanagers CRD"
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml || echo "Failed to install servicemonitors CRD"
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml || echo "Failed to install prometheusrules CRD"
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml || echo "Failed to install podmonitors CRD"
      kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.68.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml || echo "Failed to install probes CRD"
      
      # Verify CRDs are installed
      echo "Verifying CRD installation..."
      kubectl get crd | grep monitoring.coreos.com || echo "Some CRDs may not be installed yet"
    EOT
  }

  # Trigger re-run if CRDs are missing
  triggers = {
    cluster_id = azurerm_kubernetes_cluster.aks.id
    timestamp  = timestamp()
  }
}
