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
- [Argo CD for Microk8s](./services/charts/argo/microk8s.md) or [Argo CD for Minikube](./services/charts/argo/minikube.md)
- [Jenkins](./services/charts/jenkins/readme.md)
- [Custom 404 Setup](./docs/404-setup.md)
- [PostgreSQL](./storage/charts/postgres/readme.md)

## Deployment reusables

### checking pod init logs

```sh
kubectl logs jenkins-0 -n management -c init
```

### Alias

```sh
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
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

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
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
# Add this to your ~/.bashrc if you want to use the built-in helm
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
- **Error Handler**: Automated via Argo CD ExtraObjects
