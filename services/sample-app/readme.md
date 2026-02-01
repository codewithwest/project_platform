# Node Hello Application

This is a simple Node.js Express application designed for deployment on Kubernetes. It serves a basic "Hello from Kubernetes!" message on the root path.

## Prerequisites

- **Docker**: For building the application container image.
- **Minikube**: For running a local Kubernetes cluster.
- **`kubectl`**: The Kubernetes command-line tool.
- **NGINX**: To be used as a reverse proxy on the host machine.

## Getting started

### 1. Build the Docker image

Build the Docker image directly within the Minikube environment. This ensures Minikube has access to the image without needing an external registry.

```sh
# Set the Minikube shell environment
eval $(minikube -p minikube docker-env)

# Build the image using the Dockerfile in the current directory
minikube image build -t node-hello-app:1.0 .
```

### 3. Deploy the application

#### Apply the Kubernetes manifests to your Minikube cluster.

```sh
# apply the deployment and service
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

```

### 4. Start minikube tunnel

#### Run minikube tunnel in a separate terminal with sudo to expose the LoadBalancer service.

```sh
sudo minikube tunnel
# Check the external IP from another terminal
kubectl get services
# Curl the external IP
curl http://<external-ip>:80

```
