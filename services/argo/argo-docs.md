## Setting up argo with helm and domains

# Start minikube

```bash
minikube start
```

# Set kubectl context to minikube

```bash
kubectl config use-context minikube
```

# Verify connection

```bash
kubectl get nodes
```

# create namespace

```bash
kubectl create namespace management
```

# Add the Argo Helm repository

```bash
helm repo add argo https://argoproj.github.io/argo-helm
```

# Update your local Helm chart repository cache

```bash
helm repo update
```

# Install Argo CD using Helm

```bash
 helm install argo-cd charts -n management
```

# Verify the installation

kubectl get pods -n management

# create tls secret

### Senerate self signed cert

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/certificates/argo.westdynamics.local.key \
  -out /etc/nginx/certificates/argo.westdynamics.local.crt \
  -subj "/CN=argo.westdynamics.local"
```

### Check files in /etc/nginx/certificates

```bash
ls -l /etc/nginx/certificates
```

### Create TLS secret in Kubernetes

```bash
kubectl create secret tls argo-server-tls \
  --key /etc/nginx/certificates/argo.westdynamics.local.key \
  --cert /etc/nginx/certificates/argo.westdynamics.local.crt \
  -n management
```

### Verify the secret

```bash
kubectl get secret argo-server-tls -n management
```

### Add this to values file for argo cd to use NodePort

```yaml
server:
  service:
    type: NodePort
    nodePorts:
      http: 3080
      https: 8443
```

### Upgrade argo cd with new values file

```bash
    helm upgrade argo-cd charts -n management --values values.yaml
    # OR
    helm upgrade argo-cd charts/argo-cd -n management
```

### Verify the service is using NodePort

```bash
kubectl get svc -n management
```

### Access Argo CD UI

```bash
minikube service argo-cd-argocd-server -n management --url
```

### Get the initial admin password

```bash
kubectl get secret argo-cd-argocd-initial-admin-secret -n management
```

## create nginx entry

### open nginx.conf

```bash
sudo nano /etc/nginx/sites-available/argocd.conf
```

### add the context of the file .nginx-argocd.conf

## Then run

```bash
sudo ln -s /etc/nginx/sites-available/argocd.conf /etc/nginx/sites-enabled/argocd.conf
sudo nginx -t
sudo systemctl restart nginx
```

### Access the argo cd UI

```bash

```
