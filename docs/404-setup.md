# Custom 404 Pages

This application provides a beautiful, high-definition "Lost in Space" 404 error page for the entire cluster.

## Deployment

1. **Deploy via ArgoCD**:
   - Path: `apps/charts/404`
   - Namespace: `management`
   - Technical Name: `error-404`

2. **Automated Configuration (Preferred)**:
   The Nginx Ingress integration is now fully automated via the Argo CD wrapper chart. Simply ensure the following block exists in `services/charts/argo/values.yaml`:
   ```yaml
   argo:
     server:
       extraObjects:
         - apiVersion: v1
           kind: ConfigMap
           metadata:
             name: nginx-load-balancer-microk8s-conf
             namespace: ingress
           data:
             default-backend-service: "management/error-404:80"
             custom-http-errors: "404,500,502,503,504"
   ```

3. **Manual Patch (Legacy/Troubleshooting)**:
   If you need to manually force the configuration:
   ```bash
   kubectl patch configmap nginx-load-balancer-microk8s-conf -n ingress \
     --type merge \
     -p '{"data": {"default-backend-service": "management/error-404:80", "custom-http-errors": "404,500,502,503,504"}}'
   ```

## Design
The page uses pure CSS for its starfield animations and nebula gradients to ensure fast load times and compatibility with Kubernetes ConfigMap size limits (1MB).

- **Theme**: Digital Void / Lost in Space
- **Tech**: HTML5, CSS3 (Glows, Glassmorphism, Keyframe Animations)
