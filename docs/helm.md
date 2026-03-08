# Installing Helm

Back to [Readme](../README.md)

### Prerequisites

- Kubectl
- Microk8s or Minikube

### 1. install git

```sh
sudo apt install git -y
```

### 2. Install Helm

```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh
```

### 3. Configure kubectl and helm to use microk8s

```sh
mkdir -p ~/.kube
microk8s config > ~/.kube/config
chmod 600 ~/.kube/config
```