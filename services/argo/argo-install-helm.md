# Installing Argo CD with Helm

This guide covers the installation of Argo CD using Helm, a package manager for Kubernetes. The steps are similar for other Argo projects, such as Argo Workflows, but with different chart names.

### Step 1: Update Your Local Helm Chart Repository Cache

After adding the new repository, update your local cache to ensure you have the latest chart information.

```sh
helm repo update
```

### Step 2: Install Argo CD with Helm

You can now install the `argo-cd` chart. It is recommended to install it in its own namespace for better resource management.

#### Create a New Namespace for Argo CD

```sh
kubectl create namespace management
```

#### Install the Chart into the `argocd` Namespace

```sh
helm install argocd argo/argo-cd --namespace management
```

Note: This command installs with the default values. For a custom installation, you can generate a `values.yaml` file first, modify it, and then apply it.

```sh
helm show values argo/argo-cd > values.yaml
# Edit values.yaml
helm install argocd argo/argo-cd --namespace management --values values.yaml
```

### Step 4: Access the Argo CD UI

After installation, you can get the initial password and use port-forwarding to access the web UI.

#### Retrieve the Initial Admin Password

The default username is `admin`.

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode ; echo
```

#### Use Port-Forwarding to Access the UI

This forwards a local port (e.g., 8080) to the Argo CD server running in your Minikube cluster.

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open your web browser and navigate to `http://localhost:8080`. Log in with the username `admin` and the password you retrieved in the previous step.

### Step 5: Clean Up (Optional)

If you need to remove Argo CD, use the `helm uninstall` command.

```sh
helm uninstall argocd --namespace argocd
kubectl delete namespace argocd
```

Remember to use caution when executing these commands, as they may impact your Kubernetes cluster.
