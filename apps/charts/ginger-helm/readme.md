# Ginger AI Platform

## Overview

Ginger is the AI assistant platform consisting of:
- **ginger-api** — Python FastAPI backend
- **ginger-ui** — Svelte frontend

Deployed via ArgoCD in the `applications` namespace.

## Dependencies (existing services)

Ginger connects to these already-deployed cluster services:

| Service | Namespace | How it's referenced |
|---|---|---|
| PostgreSQL | `storage` | Via `ginger-db-credentials` secret (key `url`) |
| Valkey | `storage` | Via `ginger-valkey-credentials` secret (key `url`) |
| LiteLLM | `applications` | `http://litellm-proxy-litellm-proxy.applications.svc.cluster.local:4000` |
| ChromaDB | `storage` | `ginger-chromadb.storage.svc.cluster.local:8000` |
| Qdrant | `storage` | `ginger-qdrant.storage.svc.cluster.local:6333` |
| Ollama | `applications` | `http://ollama.applications.svc.cluster.local:11434` |

## Secrets

Three SealedSecrets must exist in the `applications` namespace before deploying:

### 1. `ginger-api-secret`

| Key | Description |
|---|---|
| `LITELLM_MASTER_KEY` | Master key for LiteLLM admin API |
| `LITELLM_PROXY_API_KEY` | API key for LiteLLM proxy |

### 2. `ginger-db-credentials`

| Key | Description |
|---|---|
| `url` | PostgreSQL connection string (e.g. `postgresql://user:pass@host:5432/db`) |

### 3. `ginger-valkey-credentials`

| Key | Description |
|---|---|
| `url` | Valkey connection string (e.g. `valkey://host:6379/0`) |

### Sealing the secrets

Run these on the cluster (replace values with actual secrets):

```sh
kubectl create secret generic ginger-api-secret \
  -n applications --dry-run=client -o yaml \
  --from-literal=LITELLM_MASTER_KEY="sk-..." \
  --from-literal=LITELLM_PROXY_API_KEY="sk-..." \
  | kubeseal --controller-name=sealed-secrets \
    --controller-namespace=management \
    --format yaml > sealed-api-secret.yaml

kubectl create secret generic ginger-db-credentials \
  -n applications --dry-run=client -o yaml \
  --from-literal=url=postgresql://user:pass@postgres-postgresql.storage.svc.cluster.local:5432/ginger \
  | kubeseal --controller-name=sealed-secrets \
    --controller-namespace=management \
    --format yaml > sealed-db.yaml

kubectl create secret generic ginger-valkey-credentials \
  -n applications --dry-run=client -o yaml \
  --from-literal=url=valkey://n8n-redis-master.applications.svc.cluster.local:6379/0 \
  | kubeseal --controller-name=sealed-secrets \
    --controller-namespace=management \
    --format yaml > sealed-valkey.yaml
```

Copy the `encryptedData` values into `templates/sealed-secret.yaml`.

## Deploy via ArgoCD

```sh
kubectl apply -f ginger-app.yaml
```

ArgoCD syncs from `project_platform/apps/charts/ginger-helm` on the `dev` branch.

## Image pull

By default images are pulled from `ghcr.io/codewithwest/`. To use a private registry, add `imagePullSecrets` in `values.yaml`:

```yaml
imagePullSecrets:
  - name: harbor-pull-secret
```

And update the image repository to your registry (e.g. `harbor.westdynamics.io/library/ginger-api`).

## Access

The app is available at `https://ginger.westdynamics.io`:
- `/v1`, `/ws`, `/api` → ginger-api backend
- `/` → ginger-ui frontend
