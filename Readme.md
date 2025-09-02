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
- [Nginx Service](./services/nginx.md)
- [App Expose](./services/app-expose.md)
- [Minikube](./services/minikube-setup.md)
- [Helm Setup](./services/helm.md)

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
```
