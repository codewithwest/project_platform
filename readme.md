# To setup project

### make sure docker is installed and not running as sudo

### clone repo

### run `docker network create jenkins`

### Then run `docker compose up -d` to start the container

### Open on this pod `http://localhost:8080`

## Deployment reusables

### checking pod init logs

```sh
kubectl logs jenkins-0 -n management -c init
```

### alias

```sh
alias get-pods="kubectl get pods"
alias get-service="kubectl get service"
alias get-logs="kubectl logs"
alias ngix-restart="nginx -t; sudo systemctl restart nginx"
alias
```
