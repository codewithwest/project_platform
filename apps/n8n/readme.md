# Setup n8n

# 1. Create a secret

```sh
kubectl create secret generic postgres-credentials \
  --n storage \
  --from-literal=postgres-password="[PASSWORD]" \
  --from-literal=password="[PASSWORD]" \
  --dry-run=client -o yaml > unsealed-secret.yaml
```
