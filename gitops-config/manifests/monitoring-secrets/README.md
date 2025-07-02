# Monitoring Secrets

This directory contains stub/placeholder secrets required for the monitoring stack to function properly.

## prometheus-admission-secret.yaml

**Purpose**: Provides a dummy TLS certificate secret to satisfy the `prometheus-operator` deployment requirements.

**Problem Solved**: 
- The `kube-prometheus-stack` Helm chart configures the prometheus-operator to mount a TLS certificate secret even when `admissionWebhooks.enabled: false` and `tls.enabled: false`
- Without this secret, the prometheus-operator pod fails to start with "secret not found" errors

**Solution**:
- Creates a stub `kubernetes.io/tls` secret with non-functional placeholder certificate data
- Allows the pod to start successfully while TLS remains disabled via container arguments (`--web.enable-tls=false`)
- Uses sync wave `-1` to ensure this secret is created before the prometheus-operator deployment

**Security Note**: 
- The certificate data in this secret is completely dummy/non-functional
- TLS is explicitly disabled in the prometheus-operator configuration
- This secret exists only to satisfy Kubernetes volume mount requirements

## Usage

This secret is automatically deployed by ArgoCD as part of the monitoring-secrets application.
