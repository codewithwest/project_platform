# Setup postgres

# 1. In argo ui

ssh into the postgres pod

2. get pod

```sh
kubectl get pods -n storage
```

3. ssh into the postgres pod

```sh
kubectl exec -i <pod-name> -n storage -- psql
```

4. Enable Trust Mode:
   Run this command to replace the authentication method with trust in the configuration file:

```sh
sed -i 's/md5/trust/g' /opt/bitnami/postgresql/conf/pg_hba.conf
# If your version uses scram, use this instead:
sed -i 's/scram-sha-256/trust/g' /opt/bitnami/postgresql/conf/pg_hba.conf
```

4. force new password

```sh
PGPASSWORD="<new-password>" pg_ctl -D /bitnami/postgresql/data restart -m fast -o "-c password_encryption=scram-sha-256"
```

5.get decrypted password

```sh
kubectl get secret -n storage postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode; echo
```

# 5.

```sh
psql -U postgres

```

# 6. create database and user

```sql
CREATE DATABASE n8n;
CREATE USER n8n WITH ENCRYPTED PASSWORD 'passthing';
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;
GRANT ALL ON SCHEMA public TO n8n;
```
