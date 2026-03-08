# Project Platform Documentation

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Deployment Reusables](#deployment-reusables)
- [Alias](#alias)

## Overview

This is a documentation for the project platform, this is all the steps required to setup the platform for using with a proxmox->ubuntu->minikube setup

## Prerequisites

- Proxmox
- Ubuntu
- Kubectl
- Minikube

## Installation

- [Proxmox](https://www.proxmox.com/en/proxmox-ve)
- [Ubuntu](https://ubuntu.com/download)
- [Nginx Service](./docs/nginx-service.md)
- [App Expose](./docs/app-expose.md)
- [Minikube](./docs/minikube-setup.md) or [Microk8s](./docs/microk8s.md)
- [Helm Setup](./docs/helm.md)
- [Tools](./docs/tools.md)
- [Argo CD for Microk8s](./services/argo/microk8s.md) or [Argo CD for Minikube](./services/argo/minikube.md)
- [Jenkins](./services/jenkins/microk8s.md)

## Deployment reusables

### checking pod init logs

```sh
kubectl logs jenkins-0 -n management -c init
```

### Alias

```sh
alias get-pods="kubectl get pods"
alias get-service="kubectl get service"
alias get-logs="kubectl logs"
alias nginx-restart="nginx -t; sudo systemctl restart nginx"
alias k-apply="kubectl -f apply"
alias edit-nginx="nano /etc/nginx/sites-available/minikube-proxy.conf"
alias test-nginx="nginx -t"
alias restart-nginx="systemctl restart nginx"
# Add this to your ~/.bashrc if you want to use the built-in helm
alias helm='microk8s helm3'
```
