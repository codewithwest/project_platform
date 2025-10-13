# ArgoCD Setup with External Access via NodePort and Nginx Proxy

## Prerequisites

- Minikube running
- Nginx installed on host VM
- kubectl configured

## 1. Setup Minikube and Namespace

```bash
# Start minikube
minikube start

# Set kubectl context
kubectl config use-context minikube

# Verify connection
kubectl get nodes

# Create namespace
kubectl create namespace management
```

## 2. Install ArgoCD

```bash
# Add Argo Helm repository
helm repo add argocd https://argoproj.github.io/argo-helm
helm repo update

# Install ArgoCD
helm install argocd charts -n management

# Verify installation
kubectl get pods -n management
```

## 3. Create NodePort Service for External Access

Create `argocd-nodeport.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: argocd-server-nodeport
  namespace: management
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30080
      name: http
    - port: 443
      targetPort: 8080
      nodePort: 30443
      name: https
  selector:
    app.kubernetes.io/name: argocd-server
```

Apply the service:

```bash
kubectl apply -f argocd-nodeport.yaml
```

## 4. Configure Nginx Proxy for External Access

Create `/etc/nginx/sites-available/argocd.conf`:

```nginx
server {
    listen 8002;
    server_name 192.168.100.40;  # Your VM's external IP

    location / {
        proxy_pass https://192.168.49.2:30443;  # Minikube IP:NodePort
        proxy_ssl_verify off;
        proxy_set_header Host 192.168.49.2:30443;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # ArgoCD specific headers
        proxy_set_header Accept-Encoding "";
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;

        # WebSocket support for ArgoCD streaming
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Increase buffer sizes for large responses
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
}
```

Enable the nginx configuration:

```bash
# Enable the site
sudo ln -sf /etc/nginx/sites-available/argocd.conf /etc/nginx/sites-enabled/

# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

## 5. Access ArgoCD

### Internal Access (from VM)

```bash
# Direct NodePort access
curl https://192.168.49.2:30443 --insecure
```

### External Access (from outside VM)

```bash
# Via nginx proxy
https://192.168.100.40:8002
```

## 6. Get Initial Admin Password

```bash
kubectl get secret argocd-initial-admin-secret -n management -o jsonpath="{.data.password}" | base64 -d
```

## 7. Useful Commands

```bash
# Check services
kubectl get svc -n management

# Check minikube service URLs
minikube service list

# Get minikube IP
minikube ip

# Check nginx status
sudo systemctl status nginx

# View nginx logs
sudo tail -f /var/log/nginx/error.log
```

## Network Architecture

```
External Client → VM (192.168.100.40:8002) → Nginx Proxy → Minikube (192.168.49.2:30443) → ArgoCD Pod
```

## Troubleshooting

1. **502 Bad Gateway**: Check if ArgoCD pods are running
2. **Connection refused**: Verify NodePort service is created
3. **SSL errors**: Use `--insecure` flag for testing
4. **Redirect loops**: Ensure ArgoCD is configured for the correct base path
