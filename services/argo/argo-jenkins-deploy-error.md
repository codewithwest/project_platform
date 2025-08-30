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
