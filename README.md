# Project Platform Documentation

## Table of Contents

- [Overview](#overview)
- [Architecture Direction](#architecture-direction)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [AX Agent Orchestration](#ax-agent-orchestration)
- [Deployment Reusables](#deployment-reusables)
- [Alias](#alias)

## Overview

This repository contains the infrastructure and platform configuration used to build the Dragonslur platform.

The platform direction is **bare-metal Ubuntu + K3s**, with persistent storage and database services managed inside Kubernetes. Legacy documentation for Proxmox, Minikube and MicroK8s remains below where applicable, but new Dragonslur work should target K3s.

## Architecture Direction

```text
Bare-metal Ubuntu
        │
        ▼
       K3s
        │
 ┌──────┼─────────────────────────────┐
 │      │                             │
 ▼      ▼                             ▼
Longhorn  CloudNativePG        Platform Services
 │        │                             │
 └────────┴──────────────┬──────────────┘
                         │
                         ▼
                AX Agent Runtime
                         │
                         ▼
                  G.I.N.G.E.R.
```

The intended separation is:

- **Dragonslur / Project Platform** — infrastructure, Kubernetes, networking, storage, databases and platform services.
- **AX** — isolated autonomous agent execution and task orchestration.
- **G.I.N.G.E.R.** — planning, reasoning, memory, user interaction and delegation decisions.
- **Tooling Control Center** — management of tools, MCP servers, skills, workspaces, models and agent tasks.

## Features

- K3s-based platform infrastructure
- Persistent storage with Longhorn
- PostgreSQL with CloudNativePG
- Helm-based service deployment
- Traefik ingress
- Argo CD deployment workflows
- Jenkins CI/CD
- Harbor container registry
- G.I.N.G.E.R. AI platform integration
- Planned AX agent orchestration layer

## Prerequisites

- Ubuntu Server
- K3s
- Kubectl
- Helm
- Longhorn prerequisites
- CloudNativePG

Legacy deployment documentation may also reference Proxmox, Minikube or MicroK8s.

## Installation

- [Nginx Service](./docs/nginx-service.md)
- [App Expose](./docs/app-expose.md)
- [Minikube](./docs/minikube-setup.md) or [Microk8s](./docs/microk8s.md)
- [Helm Setup](./docs/helm.md)
- [Tools](./docs/tools.md)
- [Argo CD for Microk8s](./services/charts/argo/microk8s.md) or [Argo CD for Minikube](./services/charts/argo/minikube.md)
- [Jenkins](./services/charts/jenkins/readme.md)
- [Custom 404 Setup](./docs/404-setup.md)
- [PostgreSQL](./storage/charts/postgres/readme.md)
- [Harbor Registry](./services/charts/harbor/values.yaml)
- [Ginger AI](./apps/charts/ginger-helm/readme.md)
- [AX Agent Orchestration Plan](./docs/ax-integration.md)

## AX Agent Orchestration

AX is planned as an **experimental agent execution substrate on top of Dragonslur/K3s**. It is not intended to replace K3s, Longhorn, CloudNativePG or the existing platform services.

The implementation plan covers:

- Dedicated `ax-system` namespace
- Isolated AX Tasks with CPU/memory limits
- Workspace-based Git/MCP/skill capabilities
- Gateway-based network restrictions
- Centralized model configuration
- Ginger-to-AX task delegation
- Tooling Control Center integration
- Task lifecycle and result collection
- Security, quotas, observability and rollback

See the full [AX Agent Orchestration Integration Plan](./docs/ax-integration.md).

AX should remain isolated while its upstream APIs and concepts are still evolving.

## Deployment reusables

### checking pod init logs

```sh
kubectl logs jenkins-0 -n management -c init
```

### Alias

```sh
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

### Kubectl aliases
alias get-pods="kubectl get pods"
alias get-pods-all="kubectl get pods --all-namespaces"
alias get-man-pods="kubectl get pods -n management"
alias get-app-pods="kubectl get pods -n applications"
alias get-storage-pods="kubectl get pods -n storage"
alias describe-pod="kubectl describe pod"
alias get-service="kubectl get service"
alias get-service-all="kubectl get service --all-namespaces"
alias get-service-man="kubectl get service -n management"
alias get-service-app="kubectl get service -n applications"
alias get-service-storage="kubectl get service -n storage"
alias get-logs="kubectl logs"
alias get-logs-all="kubectl logs --all-namespaces"
alias get-logs-man="kubectl logs -n management"
alias get-logs-app="kubectl logs -n applications"
alias get-logs-storage="kubectl logs -n storage"
alias nginx-restart="nginx -t; sudo systemctl restart nginx"
alias k-apply="kubectl -f apply"
alias edit-nginx="nano /etc/nginx/sites-available/minikube-proxy.conf"
alias test-nginx="nginx -t"
alias restart-nginx="systemctl restart nginx"
alias helm='microk8s helm3'
```

## Modern Installation Workflow

Since this repository now uses **Wrapper Charts** to manage configurations and dependencies, the deployment process has been simplified:

### 1. Build Dependencies

Before running Helm for the first time or after a Chart.yaml update:

```sh
helm dependency build services/charts/<service-name>
```

### 2. Deploy/Upgrade

Apply your `values.yaml` and configurations in one go:

```sh
helm upgrade <release-name> services/charts/<service-name> -n management --install
```

### 3. Key Services

- **Argo CD**: [argo.westdynamics.io](https://argo.westdynamics.io)
- **Jenkins**: [jenkins.westdynamics.io](https://jenkins.westdynamics.io)
- **Harbor**: [harbor.westdynamics.io](https://harbor.westdynamics.io) — Container registry
- **Error Handler**: Automated via Argo CD ExtraObjects

### 4. Ingress Controller

The cluster uses **Traefik** as the ingress controller (replacing Ingress NGINX which was retired March 2026). All Ingress resources use `ingressClassName: public` to route through Traefik.

### 5. TLS Certificates

All services use wildcard TLS certs for `*.westdynamics.io`. TLS secrets must exist in the cluster before ingress becomes functional:

```sh
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout ca.key -out ca.crt -subj "/CN=WestDynamics CA"
openssl req -newkey rsa:4096 -sha256 -nodes \
  -keyout wildcard.key -out wildcard.csr -subj "/CN=*.westdynamics.io"
openssl x509 -req -in wildcard.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out wildcard.crt -days 365 -sha256 \
  -extfile <(echo "subjectAltName=DNS:*.westdynamics.io")

kubectl create secret tls <secret-name> -n <namespace> \
  --cert=wildcard.crt --key=wildcard.key --dry-run=client -o yaml \
  | kubectl apply -f -

sudo cp wildcard.crt /usr/local/share/ca-certificates/westdynamics-ca.crt
sudo update-ca-certificates
sudo systemctl restart docker
```

TLS secrets used by service:

| Service | Secret Name | Ingress |
|---|---|---|
| Harbor | `harbor-tls-secret` | `harbor.westdynamics.io` |
| Jenkins | `jenkins-tls-secret` | `jenkins.westdynamics.io` |
| ArgoCD | `argocd-server-tls` | `argo.westdynamics.io` |
| n8n | `n8n-tls-secret` | `n8n.westdynamics.io` |
| Litellm | `llm-proxy-tls-secret` | `llm-proxy.westdynamics.io` |
| Qdrant | `qdrant-tls-secret` | `qdrant.westdynamics.io` |
| ChromaDB | `chromadb-tls-secret` | `chromadb.westdynamics.io` |
| Valkey | `valkey-tls-secret` | `valkey.westdynamics.io` |
| Docs | `docs-tls-secret` | `docs.westdynamics.io` |
