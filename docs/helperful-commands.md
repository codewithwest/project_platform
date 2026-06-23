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

### get postgres password from secret

```sh
kubectl get secret postgres-secret -n storage -o jsonpath="{.data.postgres-password}" | base64 -d && echo
kubectl get secret postgres-secret -n storage -o jsonpath="{.data.password}" | base64 -d && echo
```

### get chart-generated postgres password

```sh
kubectl get secret postgres-postgresql -n storage -o jsonpath="{.data.postgres-password}" | base64 -d && echo
```

### connect to postgres

```sh
kubectl exec -it -n storage postgres-postgresql-0 -- psql -U postgres
```

### force delete stuck postgres PVC

```sh
kubectl delete pvc data-postgres-postgresql-0 -n storage --force --grace-period=0
```

### check litellm-proxy logs

```sh
kubectl logs -n applications -l app.kubernetes.io/name=litellm-proxy --tail=50
```

### get litellm-proxy secret values

```sh
kubectl get secret litellm-proxy-secret -n applications -o jsonpath="{.data.DATABASE_PASSWORD}" | base64 -d && echo
kubectl get secret litellm-proxy-secret -n applications -o jsonpath="{.data.PROXY_MASTER_KEY}" | base64 -d && echo
```

### create database and user for service (litellm, n8n, etc.)

```sh
kubectl exec -it -n storage postgres-postgresql-0 -- psql -U postgres
```

```sql
CREATE DATABASE <dbname>;
CREATE USER <username> WITH PASSWORD '<password>';
GRANT ALL PRIVILEGES ON DATABASE <dbname> TO <username>;
\c <dbname>
GRANT ALL ON SCHEMA public TO <username>;
```
