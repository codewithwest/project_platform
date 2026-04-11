# Install Argo CD on MicroK8s (Wrapper Chart)

This repository uses a **Wrapper Chart** located in `services/charts/argo` to manage the official Argo CD installation along with local configurations (like Nginx Ingress and ConfigMap patches).

## 1. Prepare Dependencies
You must download the official `argo-cd` subchart before installing:

```sh
helm dependency build services/charts/argo
```

## 2. Install/Upgrade Argo CD
Deploy the wrapper chart with your custom `values.yaml`:

```sh
# This installs/updates the 'argocd' release in the 'management' namespace
helm upgrade argocd services/charts/argo -n management --install --create-namespace
```

## 3. Verify the installation
Check that all pods are running and healthy:

```sh
kubectl get pods -n management | grep argo
```

## 4. Automation Features
Our `values.yaml` in the wrapper chart handles the following automatically:
- **Insecure mode**: `server.insecure: true` for use behind Ingress.
- **Resource Limits**: CPU/Memory limits for the controller.
- **Nginx Integration**: Patching the global Ingress ConfigMap via `extraObjects`.
- **Ingress**: Managed ingress for `argo.westdynamics.io`.

## 5. Access Argo CD

### Initial Admin Password
```sh
kubectl -n management get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### URL
Access via the configured ingress: [https://argo.westdynamics.io](https://argo.westdynamics.io)

---
Back to [Main README](../../../README.md)