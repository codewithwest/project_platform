## Setting up argo with helm and domains

# Start minikube

minikube start

# Set kubectl context to minikube

kubectl config use-context minikube

# Verify connection

kubectl get nodes

# create namespace

kubectl create namespace management

# Add the Argo Helm repository

helm repo add argo https://argoproj.github.io/argo-helm

# Update your local Helm chart repository cache

helm repo update

# Install Argo CD using Helm

helm install argo-cd argo/argo-cd -n management

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
