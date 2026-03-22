# Setup n8n

# 1. Create a secret

```sh
kubectl create secret generic postgres-credentials \
  --n storage \
  --from-literal=postgres-password="[PASSWORD]" \
  --from-literal=password="[PASSWORD]" \
  --dry-run=client -o yaml > unsealed-secret.yaml
```

```sh
kubeseal \
 --controller-name=sealed-secrets \
 --controller-namespace=management \
 -f postgres-secret.yaml \
 -o yaml > postgres-sealedsecret.yaml
```

# cli sync

```sh
kubectl delete pod -n applications -l app.kubernetes.io/name=n8n-worker
```
