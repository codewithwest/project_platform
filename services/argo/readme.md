# Argo CD GitOps Setup

This repository tracks the deployment of Argo CD within a Minikube cluster, following a GitOps approach. The official manifest is used for a reliable installation, and all steps are documented here for auditability.

## Contents

- `argo/official-install.yaml`: The official Argo CD installation manifest from the `stable` branch of the `argoproj/argo-cd` GitHub repository.

## Prerequisites

- A running Minikube cluster.
- `kubectl` configured to connect to the cluster.
- A dedicated Git repository for your configurations.
- NGINX installed on the Ubuntu VM for external access.

## Installation

1.  **Create the `management` namespace** in your Kubernetes cluster.
    ```sh
    kubectl create namespace management
    ```
2.  **Clone this repository** to your local machine.
    ```sh
    git clone https://github.com/your-username/your-repo.git
    cd your-repo
    ```
3.  **Apply the Argo CD manifest** to the cluster, ensuring the `ClusterRoleBinding` is correctly configured for the `management` namespace.
    ```sh
    # This command uses the manifest from your repo
    kubectl apply -n management -f ./argo/official-install.yaml
    ```
4.  **Correct the ClusterRoleBinding** to reference the `management` namespace.
    ```sh
    kubectl edit clusterrolebinding argocd-server -n management
    ```
5.  **Verify the deployment**. Check that all pods in the `management` namespace are running.
    ```sh
    kubectl get pods -n management
    ```

## Accessing the Argo CD UI

1.  **Retrieve the initial admin password**.
    ```sh
    kubectl -n management get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
    ```
2.  **Access the UI** via port forwarding from your Ubuntu VM.
    ```sh
    kubectl port-forward svc/argocd-server -n management 8080:443
    ```
3.  **Log in** to your web browser at `https://localhost:8080`. Use `admin` as the username and the retrieved password.

## Exposing Argo CD to the Proxmox Host

# **Generating a Self-Signed SSL Certificate and Configuring NGINX**

## **Step 1: Generate a Self-Signed SSL Certificate**

Run the following command to create a self-signed SSL certificate on your Ubuntu VM:

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/private.key -out /etc/nginx/certificate.crt
```

**Note:** Use this command with caution, as it generates a self-signed certificate that may not be trusted by all clients.

## **Step 2: Edit the NGINX Configuration File**

Edit the NGINX configuration file on the Ubuntu VM:

```bash
sudo nano /etc/nginx/sites-enabled/default
```

## **Step 3: Update the Server Block**

Update the server block to reflect the new paths:

```nginx
server {
    listen 8443 ssl;
    server_name 192.168.100.35;

    ssl_certificate /etc/nginx/certificate.crt;
    ssl_certificate_key /etc/nginx/private.key;

    location / {
        proxy_pass https://<argo-external-ip>:443;
        # Other headers
    }
}
```

## **Step 4: Check the NGINX Configuration Syntax and Restart the Service**

Check the NGINX configuration syntax and restart the service:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

This will resolve the certificate loading error and allow NGINX to start correctly. You can then proceed with accessing Argo CD from your Proxmox host.

**Troubleshooting Tips**

- Make sure to replace `<argo-external-ip>` with the actual external IP address of your Argo CD instance.
- Verify that the certificate and private key files are correctly located at `/etc/nginx/certificate.crt` and `/etc/nginx/private.key`, respectively.
- If you encounter any issues with the NGINX configuration, check the error logs for more information.
