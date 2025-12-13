# Jenkins in argocd

#### since this uses multi repo sources then you cannot create via ui

## add helm repo

```sh
helm repo add jenkins https://charts.jenkins.io
```

## update helm

```sh
helm repo update
```

## install jenkins

### create file you will use to create the jenkins app

```sh
nano jenkins-app.yaml
```

### add contents of file services/jenkins/app.yaml

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
    # Jenkins Helm chart
    - repoURL: https://charts.jenkins.io
      targetRevision: 5.8.110
      chart: jenkins
      helm:
        valueFiles:
          - $values/services/jenkins/values.yaml

    # Repo containing values.yaml
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

### apply jenkins app

```sh
kubectl apply -f jenkins-app.yaml
```

### verify jenkins app created or check argo-cd ui

```sh
kubectl get all -n management
```

## Access jenkins

- Get jenkins admin password

```sh
kubectl get secret --namespace=management jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
```

- Access jenkins UI https://<hostName>:<port>/

Add url to jenkins system configuration

- Jenkins URL: http://<hostName>:<port>/
- or use svc url `http://jenkins.jenkins.svc.cluster.local:8080/`
