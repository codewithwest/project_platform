# Helpful kubectl commands

### delete stuck application

```sh
kubectl patch application n8n -n argocd \
  -p '{"metadata":{"finalizers":[]}}' --type=merge
```

### force delete application on cli

```sh
kubectl delete application n8n -n argocd --force --grace-period=0
```
