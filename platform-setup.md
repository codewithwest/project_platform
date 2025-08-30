# **Jenkins Deployment on Minikube with Proxmox Access**

## **Table of Contents**

1. [Prerequisites](#prerequisites)
2. [Step 1: Deploy Jenkins on Minikube using Helm](#step-1-deploy-jenkins-on-minikube-using-helm)
3. [Step 2: Access Jenkins from the Ubuntu VM](#step-2-access-jenkins-from-the-ubuntu-vm)
4. [Step 3: Configure NGINX Reverse Proxy on the Ubuntu VM](#step-3-configure-nginx-reverse-proxy-on-the-ubuntu-vm)
5. [Step 4: Configure Proxmox iptables](#step-4-configure-proxmox-iptables)
6. [Step 5: Access Jenkins from the Proxmox Host](#step-5-access-jenkins-from-the-proxmox-host)

## **Prerequisites**

- Proxmox Host: A running Proxmox VE installation with a functional network configuration.
- Ubuntu VM: A virtual machine running Ubuntu Server within Proxmox.
- Minikube: Installed and running on the Ubuntu VM.
- kubectl: Installed and configured on the Ubuntu VM to interact with the Minikube cluster.
- Helm: Installed on the Ubuntu VM.
- NGINX: Installed on the Ubuntu VM.

## **Network Details**

- Proxmox Host IP: 192.168.100.31
- Ubuntu VM IP: 192.168.100.35
- Minikube IP: 192.168.49.2 (Example)

## **Step 1: Deploy Jenkins on Minikube using Helm**

1. Add the Jenkins Helm chart repository on your Ubuntu VM.

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update
```

2. Create a namespace for Jenkins.

```bash
kubectl create namespace jenkins
```

3. Install Jenkins using the Helm chart.

```bash
helm install jenkins -n jenkins jenkins/jenkins --set controller.serviceType=NodePort
```

4. Start minikube tunnel in a separate terminal to expose the LoadBalancer (simulated by Minikube). This needs to be running continuously.

```bash
sudo minikube tunnel
```

## **Step 2: Access Jenkins from the Ubuntu VM**

1. Get the NodePort for Jenkins.

```bash
kubectl get service jenkins -n jenkins
```

2. Get the external IP provided by minikube tunnel.

```bash
kubectl get service jenkins -n jenkins
```

3. Access Jenkins from within the Ubuntu VM.

```bash
# Using the tunnel's external IP
curl http://<external-ip>:80

# Or using the Minikube IP and NodePort
curl http://$(minikube ip):<node-port>
```

## **Step 3: Configure NGINX Reverse Proxy on the Ubuntu VM**

1. Stop Tailscale on the Ubuntu VM if it's running, as it can conflict with networking rules.

```bash
sudo systemctl stop tailscaled
```

2. Get the external IP and NodePort for Jenkins from the previous step.
3. Configure NGINX on the Ubuntu VM to listen on port 8080 and forward traffic to the Minikube tunnel's external IP or the Minikube IP and NodePort.

```nginx
server {
    listen 8080;
    server_name 192.168.100.35; # Listen on your VM's main IP

    location / {
        # Use either the minikube tunnel IP or the minikube IP + NodePort
        proxy_pass http://<minikube-external-ip>:80;
        # Or: proxy_pass http://<minikube-ip>:<node-port>;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

4. Restart NGINX to apply the changes.

```bash
sudo systemctl restart nginx
```

## **Step 4: Configure Proxmox iptables**

1. Stop Tailscale on the Proxmox host if it's running.

```bash
systemctl stop tailscaled
```

2. Add iptables NAT rules to forward traffic on port 8080 from the Proxmox host to the Ubuntu VM.

```bash
# On the Proxmox host
# Replace <proxmox_public_interface> with your interface (e.g., vmbr0)
iptables -t nat -A PREROUTING -i <proxmox_public_interface> -p tcp --dport 8080 -j DNAT --to-destination 192.168.100.35:8080
iptables -t nat -A OUTPUT -p tcp --dport 8080 -j DNAT --to-destination 192.168.100.
```
