# Custom 404 Pages

This application provides a beautiful, high-definition "Lost in Space" 404 error page for the entire cluster.

## Deployment

1. **Deploy via ArgoCD**:
   - Path: `apps/charts/404`
   - Namespace: `management`
   - Technical Name: `error-404`

2. **Configure MicroK8s Ingress**:
   Find your Ingress ConfigMap name:
   ```bash
   kubectl get configmap -A | grep -i "ingress\|nginx"
   ```

   Apply the patch (replace `<NAME>` and `<NAMESPACE>`):
   ```bash
   kubectl patch configmap <NAME> -n <NAMESPACE> \
     --type merge \
     -p '{"data": {"default-backend": "management/error-404", "custom-http-errors": "404,500,502,503,504"}}'
   ```

## Design
The page uses pure CSS for its starfield animations and nebula gradients to ensure fast load times and compatibility with Kubernetes ConfigMap size limits (1MB).

- **Theme**: Digital Void / Lost in Space
- **Tech**: HTML5, CSS3 (Glows, Glassmorphism, Keyframe Animations)
