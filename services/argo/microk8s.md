# Install argo cd on microk8s

Back to [Readme](../../README.md)

## 1. Add repository

```sh
helm repo add argo https://argoproj.github.io/argo-helm
```

## 2. Update your local Helm chart repository cache

```sh
helm repo update
```

## 3. Install Argo CD

```sh
helm install argo argo/argo-cd --n management --create-namespace
```

## 4. Verify the installation

```sh
kubectl get pods -n argocd
```

## 5. Expose argo cd

```sh
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
```

## 6. verify the nodeport

```sh
kubectl get svc argocd-server -n argocd
```


## 7.Access argo cd

```sh
https://<vm-ip>:<nodeport>
```

## 8. Get the Argo CD admin password

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 9. Access the Argo CD UI

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 10. Login to the Argo CD UI

```sh
https://localhost:8080
```

## 11. Logout from the Argo CD UI

```sh
kubectl -n argocd delete secret argocd-initial-admin-secret
```