apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: azure-keyvault-secret-store
  namespace: jenkins
spec:
  provider:
    azurekv:
      tenantId: ${tenant_id}
      vaultUrl: ${vault_url}
      authType: WorkloadIdentity
      serviceAccountRef:
        name: external-secrets-sa
