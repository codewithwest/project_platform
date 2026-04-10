# Ginger AI Kubernetes Deployment

These manifests are designed for Argo CD deployment on MicroK8s.

## Secrets Management (Sealed Secrets)

1.  **Populate Template**: Open `secrets-template.yaml` and fill in your actual credentials.
2.  **Seal the Secret**: Run the following command from your local machine (ensure `kubeseal` is installed):
    ```bash
    kubeseal --format=yaml < secrets-template.yaml > sealed-secrets.yaml
    ```
3.  **Clean Up**: **DO NOT** commit `secrets-template.yaml` to your repository. Delete it or ensure it's in `.gitignore`.
4.  **Deploy**: Commit `sealed-secrets.yaml` along with the other manifests.

## Argo CD Setup

1.  Apply the `argo-application.yaml` manifest to your cluster (or add it via the Argo UI):
    ```bash
    kubectl apply -f argo-application.yaml
    ```
2.  Argo CD will automatically create the `ginger-ai` namespace and synchronize all resources.

## MicroK8s Requirements

Ensure the following MicroK8s addons are enabled:
```bash
microk8s enable dns hostpath-storage ingress
```
