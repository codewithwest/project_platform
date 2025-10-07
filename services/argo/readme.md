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
kubectl -n management get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode ; echo
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

### Step 6: Customization

Create a file named values.yaml with the following content:

```yaml
# Add volumes and volume mounts for the argocd-repo-server
repoServer:
  extraVolumes:
    - name: ssh-known-hosts
      configMap:
        name: argocd-ssh-known-hosts-cm
    - name: repo-credentials
      secret:
        secretName: argocd-repo-key-secret
  extraVolumeMounts:
    - name: ssh-known-hosts
      mountPath: /etc/ssh/ssh_known_hosts
      subPath: ssh_known_hosts
    - name: repo-credentials
      mountPath: /home/argocd/.ssh

# Add the extra Role and RoleBinding for the argocd-server
# Note: The namespace `management` will be replaced by the Helm release namespace (`-n argocd`).
server:
  extraRoles:
    - apiVersion: rbac.authorization.k8s.io/v1
      kind: Role
      metadata:
        name: argocd-pod-reader
      rules:
        - apiGroups: [""]
          resources: ["pods", "pods/log", "pods/exec"]
          verbs: ["get", "list", "watch"]
        - apiGroups: ["apps"]
          resources: ["controllerrevisions"]
          verbs: ["get", "list", "watch"]
  extraRoleBindings:
    - apiVersion: rbac.authorization.k8s.io/v1
      kind: RoleBinding
      metadata:
        name: argocd-pod-reader-binding
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: Role
        name: argocd-pod-reader
      subjects:
        - kind: ServiceAccount
          name: argocd-server

# Add the extra ClusterRole and ClusterRoleBinding for the argocd-application-controller
applicationController:
  extraClusterRoles:
    - apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRole
      metadata:
        name: argocd-pvc-viewer
      rules:
        - apiGroups: [""]
          resources: ["persistentvolumeclaims"]
          verbs: ["get", "list", "watch"]
  extraClusterRoleBindings:
    - apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRoleBinding
      metadata:
        name: argocd-pvc-viewer-binding
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: argocd-pvc-viewer
      subjects:
        - kind: ServiceAccount
          name: argocd-application-controller
```

Key considerations
Namespace handling: The Argo Helm chart automatically handles namespaces for namespace-scoped resources. If you install into the argocd namespace with the command helm install argocd argo/argo-cd -n argocd, the namespace: management you specified in the Role and RoleBinding will be automatically replaced with argocd. This is expected behavior and avoids hardcoding the namespace.
Pre-existing resources: The argocd-ssh-known-hosts-cm configmap and argocd-repo-key-secret secret must exist in the target namespace before you run the helm install command.

### The Helm chart will not create these resources for you, but it will use them for mounting.

How to use the values.yaml file

### After creating the your-custom-values.yaml file, run the helm install command from the directory where the file is saved:

```sh
helm install argocd argo/argo-cd -n management -f values.yaml
```

### Setup secrets

```sh
kubectl create secret generic repo-secret-codewithwest \
    --from-literal=name=codewithwest \
    --from-literal=url=git@github.com:codewithwest/project_platform.git \
    --from-literal=type=git \
    --from-file=sshPrivateKey=/home/west/.ssh/argocd-repo-key \
    --dry-run=client -o yaml | kubectl label -f - --local='true' argocd.argoproj.io/secret-type=repository -o yaml | kubectl apply -f - -n management
```

You can now check in `Settings > Repositories` to see the new repository

### Step 7: Creating a new
