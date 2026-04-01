# 404 Error Page Chart

This chart deploys a custom 404 "Lost in Space" background for your entire MicroK8s cluster.

## Installation

```bash
# Via Helm
helm install error-404 apps/charts/404 -n management

# Via ArgoCD
# Set path to: apps/charts/404
# Set namespace to: management
```

## Features
- **Modern Design**: High-definition CSS gradients and starfield animations.
- **Glassmorphism**: Sleek floating UI for the error message.
- **MicroK8s Ready**: Specifically designed to work as a "Default Backend" for Nginx Ingress.
