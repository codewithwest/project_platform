# **Resolving the Argo CD Application Controller's Permissions Issue**

**Error:** `persistentvolumeclaims is forbidden: User "system:serviceaccount:management:argocd-application-controller" cannot list resource "persistentvolumeclaims" in API group "" at the cluster scope`

**Cause:** The Argo CD Application Controller's Service Account lacks the necessary permissions to list PersistentVolumeClaims (PVCs) at the cluster scope.

**Solution:**

### Step 1: Create a ClusterRole

Define a ClusterRole that grants permissions to get, list, and watch PVCs:

```yaml
# clusterrole-pvc.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argocd-pvc-viewer
rules:
  - apiGroups: [""] # "" indicates the core API group
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch"]
```

### Step 2: Create a ClusterRoleBinding

Bind this ClusterRole to the `argocd-application-controller` Service Account:

```yaml
# clusterrolebinding-pvc.yaml
apiVersion: rbac.authorization.k8s.io/v1
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
    namespace: management # Use your namespace here
```

### Step 3: Apply the resources

Apply both manifests to your cluster using `kubectl`:

```bash
kubectl apply -f clusterrole-pvc.yaml
kubectl apply -f clusterrolebinding-pvc.yaml
```

### Step 4: Restart the argocd-application-controller (optional but recommended)

Restart the deployment to ensure the new permissions are picked up:

```bash
kubectl rollout restart deployment argocd-applicationset-controller -n management
```

**Alternative:** Grant broader access (if acceptable)

If you trust the Argo CD Application Controller and want to give it broader permissions, you can bind it to an existing ClusterRole, such as `cluster-admin` (though this is not recommended for production environments):

```bash
kubectl create clusterrolebinding argocd-application-controller-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=management:argocd-application-controller
```

Note: This alternative approach grants much broader access than necessary and should be used with caution.

# **Resolving Insufficient Permissions for Argo CD Application Controller**

**Error:** Repeated `is forbidden` errors for various Kubernetes resources in the cluster logs

**Cause:** The `argocd-application-controller` service account lacks the necessary permissions to list resources at the cluster scope, preventing the controller from building its cache and managing resources.

**Solution:**

To grant the `argocd-application-controller` service account the necessary permissions, you can bind it to the `cluster-admin` ClusterRole. This will grant it broad, cluster-wide permissions to manage resources across the entire cluster.

**Command:**

```bash
kubectl create clusterrolebinding argocd-application-controller-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=management:argocd-application-controller
```

**What this command does:**

- Creates a new ClusterRoleBinding named `argocd-application-controller-binding`
- Binds the `argocd-application-controller` service account to the `cluster-admin` ClusterRole
- Grants the service account all the necessary permissions to manage resources across the entire cluster

**After applying this command:**

- The Argo CD controller will automatically re-attempt the sync
- With the new permissions, it will be able to list all cluster resources, build its cache, and then proceed with creating the Jenkins deployment and other resources
- This will resolve the issue and allow the controller to function correctly

**Note:** Granting the `cluster-admin` ClusterRole to the `argocd-application-controller` service account provides broad permissions, which may not be suitable for all environments. However, in this case, it is necessary to resolve the issue and allow the controller to function correctly.
