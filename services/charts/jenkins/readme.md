# Jenkins Deployment Guide

This repository uses a **Wrapper Chart** approach to manage Jenkins. The configuration is located in `services/charts/jenkins`.

## 1. Installation (via Helm)

You can deploy Jenkins directly using the wrapper chart. This is the simplest way to apply local configurations (like resource limits and ingress).

### Build Dependencies
```sh
helm dependency build services/charts/jenkins
```

### Install/Upgrade
```sh
# Installs the 'jenkins' release in the 'management' namespace
helm upgrade jenkins services/charts/jenkins -n management --install
```

---

## 2. Installation (via Argo CD)

If you prefer to manage Jenkins using GitOps, use a **Multi-Source Application**.

### Create the Application Manifest
Create a file named `jenkins-app.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: jenkins
  namespace: management
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: management
  sources:
    # 1. Official Jenkins Helm chart
    - repoURL: https://charts.jenkins.io
      targetRevision: 5.9.12  # Matching the version in Chart.yaml
      chart: jenkins
      helm:
        valueFiles:
          - $values/services/charts/jenkins/values.yaml

    # 2. This repository (containing the values.yaml)
    - repoURL: https://github.com/codewithwest/project_platform.git
      targetRevision: dev
      ref: values
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Apply the Application
```sh
kubectl apply -f jenkins-app.yaml
```

---

## 3. Accessing Jenkins

### Get Admin Password
```sh
kubectl get secret --namespace=management jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
```

### URL
Access via Ingress: [https://jenkins.westdynamics.io](https://jenkins.westdynamics.io)

> [!NOTE]
> Since this is a subchart, all configurations in `values.yaml` must be nested under a root `jenkins:` key.
