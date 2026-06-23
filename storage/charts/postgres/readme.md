# PostgreSQL Setup (Bitnami Chart)

## Overview

PostgreSQL is deployed as a Bitnami Helm chart via ArgoCD in the `storage` namespace. Credentials are managed using a SealedSecret (`postgres-secret`).

## Configuration

### `values.yaml` key settings

```yaml
auth:
  username: postgres     # Built-in superuser (leave as postgres or change)
  database: <db-name>    # Database to create on first init
  existingSecret: postgres-secret  # Use SealedSecret instead of auto-generated
```

### Secret key mapping

The SealedSecret `postgres-secret` contains these keys:

| Key | Purpose | Chart default |
|---|---|---|
| `postgres-password` | Superuser (`postgres`) password | `postgres-password` |
| `password` | App user password | `password` |

## Getting passwords

```sh
# From the SealedSecret (authoritative source)
kubectl get secret postgres-secret -n storage -o jsonpath="{.data.postgres-password}" | base64 -d && echo
kubectl get secret postgres-secret -n storage -o jsonpath="{.data.password}" | base64 -d && echo

# From the chart-generated secret (if existingSecret is not configured)
kubectl get secret postgres-postgresql -n storage -o jsonpath="{.data.postgres-password}" | base64 -d && echo
```

## Connecting

```sh
kubectl exec -it -n storage postgres-postgresql-0 -- psql -U postgres
```

## Resetting when password doesn't match

If the pod has **old persisted data**, the password hash stored in the DB won't match the current secret. Fixes:

### Option A: Full clean reset (deletes all data)

Delete the PVC so the chart reinitializes from scratch:

```sh
kubectl delete pvc data-postgres-postgresql-0 -n storage
# Allow StatefulSet controller to recreate it
```

### Option B: Connect via local trust and change password

Connect without password auth by editing `pg_hba.conf`:

```sh
kubectl exec -it -n storage postgres-postgresql-0 -- bash
sed -i 's/md5/trust/g' /opt/bitnami/postgresql/conf/pg_hba.conf
# or: sed -i 's/scram-sha-256/trust/g' /opt/bitnami/postgresql/conf/pg_hba.conf
pg_ctl reload -D /bitnami/postgresql/data
```

Then connect and set the password:

```sql
ALTER USER postgres WITH PASSWORD 'new-password';
```

Then revert `pg_hba.conf` back to `md5` and reload.

### Option C: Sync password in DB to match secret

```sql
ALTER USER postgres WITH PASSWORD '<value-from-secret>';
CREATE USER <username> WITH PASSWORD '<value-from-secret>';
CREATE DATABASE <dbname> OWNER <username>;
GRANT ALL PRIVILEGES ON DATABASE <dbname> TO <username>;
GRANT ALL ON SCHEMA public TO <username>;
```

## Dependent services needing DB setup

Some services use PostgreSQL and require the database and user to exist. These are **not** created by the PostgreSQL chart — they must be created manually or via the app's own migration job.

| Service | Namespace | DB Name | DB User | Auth |
|---|---|---|---|---|
| **n8n** | applications | `n8n` | `n8n` | Uses `n8n-secret` SealedSecret in `applications` ns |
| **LiteLLM Proxy** | applications | `litellm` | `llmproxy` | Uses `litellm-proxy-secret` SealedSecret in `applications` ns |

To set up a dependent service's database:

```sql
-- Connect to postgres superuser first
CREATE DATABASE <dbname>;
CREATE USER <username> WITH PASSWORD '<value-from-app-secret>';
GRANT ALL PRIVILEGES ON DATABASE <dbname> TO <username>;
\c <dbname>
GRANT ALL ON SCHEMA public TO <username>;
```

### LiteLLM Proxy notes

- The litellm-proxy pod runs a migration job (`python litellm/proxy/prisma_migration.py`) on startup that creates its tables automatically once the database exists.
- If the `litellm` database or `llmproxy` user don't exist, the pod will crash loop with probe failures like:
  ```
  Readiness probe failed: dial tcp ...:4000: connect: connection refused
  Liveness probe failed: dial tcp ...:4000: connect: connection refused
  ```

## Common issues

| Problem | Cause | Fix |
|---|---|---|
| Password auth fails after redeploy | Old PVC retains previous password hash | Delete PVC (Option A) |
| `existingSecret` not taking effect | ArgoCD out of sync or not committed | Commit & push, then sync |
| Pod stuck `Terminating` on PVC delete | PVC stuck with finalizer | `kubectl delete pvc <name> -n storage --force --grace-period=0` |
| Role "n8n" does not exist | DB initialized without creating the user | Create user manually (Option C) |
| LiteLLM proxy crash loop | `litellm` DB or `llmproxy` user missing in PostgreSQL | Create DB + user, restart pod |
