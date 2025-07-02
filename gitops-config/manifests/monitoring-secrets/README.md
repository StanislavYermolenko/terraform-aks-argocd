# Monitoring Configuration - Production Approach

## Overview

This monitoring stack uses a **clean production configuration** that properly disables admission webhooks and TLS certificate mounting for the Prometheus Operator.

## Configuration Strategy

### ✅ **Current Approach: Proper Webhook Disabling**

The prometheus-operator is configured with:

```yaml
prometheusOperator:
  admissionWebhooks:
    enabled: false         # No admission webhooks
  tls:
    enabled: false          # No TLS encryption
  secretName: ""            # No certificate secret mounting
  extraArgs:
    - --web.enable-tls=false  # Explicit TLS disable at runtime
  volumes: []               # No volume mounts
  volumeMounts: []          # No certificate volumes
```

### 🎯 **Benefits of This Approach:**

1. **Production-Ready**: Explicitly disables unneeded security features
2. **Clean & Simple**: No dummy secrets or workarounds needed
3. **Maintainable**: Clear configuration with proper Helm values
4. **Stable**: No dependency on complex certificate management
5. **Secure**: Only enables what's actually needed

### 🚀 **Evolution Path:**

For enterprise environments requiring admission webhooks:

1. **Phase 1** (Current): Webhooks disabled, clean monitoring
2. **Phase 2** (Future): External certificate management via Azure Key Vault
3. **Phase 3** (Enterprise): Full PKI integration with certificate rotation

## Implementation Notes

- Uses `extraArgs` field (correct Helm chart field name)
- Explicitly sets `secretName: ""` to prevent secret mounting
- Disables TLS at both Helm and container argument levels
- No stub secrets or workarounds required

This configuration provides **production-grade monitoring** without unnecessary complexity.
