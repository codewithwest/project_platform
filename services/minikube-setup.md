# Minikube Setup

### Here is the Puppet script that automates the installation of Minikube on an Ubuntu Server running within a Proxmox virtual machine:

```puppet
# Install Minikube on Ubuntu Server

# Update System
exec { 'update-system':
  command     => 'sudo apt update && sudo apt upgrade -y',
  refreshonly => true,
}

# Install Prerequisites
package { 'curl':
  ensure => installed,
}
package { 'wget':
  ensure => installed,
}
package { 'apt-transport-https':
  ensure => installed,
}
package { 'ca-certificates':
  ensure => installed,
}

# Install Docker (Container Runtime)
package { 'docker.io':
  ensure => installed,
}

# Add User to Docker Group
exec { 'add-user-to-docker-group':
  command     => 'sudo usermod -aG docker $USER && newgrp docker',
  refreshonly => true,
}

# Install Kubectl (Kubernetes Command-Line Tool)
package { 'kubectl':
  ensure          => installed,
  provider        => 'snap',
  install_options => ['--classic'],
}

# Install Minikube
exec { 'download-minikube-binary':
  command     => 'curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64',
  refreshonly => true,
}
exec { 'make-executable-and-move':
  command     => 'chmod +x minikube-linux-amd64 && sudo mv minikube-linux-amd64 /usr/local/bin/minikube',
  refreshonly => true,
}

# Verify Installation
exec { 'verify-minikube-installation':
  command     => 'minikube version',
  refreshonly => true,
}

# Start Minikube
exec { 'start-minikube':
  command     => 'minikube start --driver=docker --memory=4096 --cpus=2',
  refreshonly => true,
}

# Check Minikube Status
exec { 'check-minikube-status':
  command     => 'minikube status',
  refreshonly => true,
}
```

### This Puppet script automates the installation of Minikube on an Ubuntu Server running within a Proxmox virtual machine. It performs the following tasks:

---

1. Updates the system and installs necessary tools and dependencies.
2. Installs Docker (Container Runtime) and adds the user to the Docker group.
3. Installs Kubectl (Kubernetes Command-Line Tool) via Snap.
4. Installs Minikube by downloading the binary, making it executable, and moving it to a system-wide path.
5. Verifies the Minikube installation.
6. Starts Minikube with the Docker driver and allocates sufficient resources.
7. Checks the Minikube status.

---

Note that this script assumes that the Puppet agent is running on the Ubuntu Server and has the necessary permissions to execute the commands.

# Accessing the Kubernetes Dashboard

To access the Kubernetes dashboard, you need to set it up as a service on the Ubuntu VM. This will allow you to access the dashboard constantly and prevent it from closing when you exit the terminal.

### Step 1: Stop any running dashboard proxies

Press `Ctrl+C` in the terminal to stop any running dashboard proxies.

### Step 2: Enable the dashboard addon

If the dashboard addon is not already enabled, run the following command:

```sh
minikube addons enable dashboard
```

### Step 3: Start a persistent proxy using kubectl

Run the following command to start a persistent proxy:

```sh
kubectl proxy --address='0.0.0.0' --port=8001 &
```

This command starts a proxy that listens on all network interfaces (`--address='0.0.0.0'`) and sets a consistent, static port for the dashboard (`--port=8001`). The `&` at the end of the command runs it in the background, allowing you to close the terminal without stopping the proxy.

### Step 4: Create a systemd service

Create a systemd service to start the proxy automatically with the VM. Create a new file called `minikube-dashboard.service` in the `/etc/systemd/system` directory:

```sh
sudo nano /etc/systemd/system/minikube-dashboard.service
```

Add the following configuration, replacing `YOUR_USER` and `YOUR_HOME` with your username and home directory:

```ini
[Unit]
Description=Minikube Dashboard Proxy
After=network.target

[Service]
ExecStart=/usr/local/bin/kubectl proxy --address='0.0.0.0' --port=8001
User=YOUR_USER
Environment=KUBECONFIG=/YOUR_HOME/.kube/config
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Save and exit the file.

### Step 5: Reload the systemd daemon, enable, and start the service

Run the following commands to reload the systemd daemon, enable, and start the service:

```sh
sudo systemctl daemon-reload
sudo systemctl enable minikube-dashboard.service
sudo systemctl start minikube-dashboard.service
```

### Step 6: Access the dashboard

You can now access the dashboard by navigating to the following URL in a web browser on your Proxmox host or any machine on the same network:

```
http://YOUR_UBUNTU_VM_IP:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

You will need to authenticate using a token. To retrieve the token, run the following command on your Ubuntu VM:

```sh
kubectl get secret -n kubernetes-dashboard -o=jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='kubernetes-dashboard')].data.token}" | base64 --decode
```

Copy the token and paste it into the dashboard login screen.

# Setting up NGINX as a Reverse Proxy for Minikube Dashboard

Using NGINX as a reverse proxy is a standard and effective way to expose services running inside your Proxmox VM to your network. This approach allows you to route traffic to the Minikube dashboard and other applications via the VM's IP address and a standard port, such as 80 (HTTP) or 443 (HTTPS).

## Benefits of Using NGINX as a Reverse Proxy

- **Security**: NGINX can handle HTTPS encryption, add authentication, and filter malicious requests, protecting your Minikube services.
- **Centralization**: With NGINX, you can manage and route traffic to multiple services running inside your VM, not just the Kubernetes dashboard.
- **Always On**: NGINX can be configured as a systemd service, ensuring it automatically starts on boot and always runs in the background.

## Step 1: Install NGINX on the Ubuntu VM

### Update the package list

```sh
sudo apt update
```

### Install NGINX

```sh
sudo apt install nginx -y
```

### Allow NGINX through the firewall (if using UFW)

```sh
sudo ufw allow 'Nginx Full'
```

## Step 2: Configure the NGINX Reverse Proxy

### Stop the kubectl proxy service (if running)

```sh
sudo systemctl stop minikube-dashboard.service
```

### Create a new NGINX configuration file for your Minikube dashboard proxy

```sh
sudo nano /etc/nginx/sites-available/minikube.conf
```

### Add the following configuration to the file

```nginx
server {
    listen 80;
    server_name YOUR_UBUNTU_VM_IP;

    location / {
        proxy_pass http://localhost:8001/; # Must end with a slash
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Note: `proxy_pass` uses `localhost:8001` because `kubectl proxy` binds to `localhost` by default. The `/dashboard` path is important for accessing the service.

### Create a symbolic link to enable the configuration and remove the default NGINX site

```sh
sudo ln -s /etc/nginx/sites-available/minikube.conf /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
```

### Test the configuration syntax and restart NGINX to apply the changes

```sh
sudo nginx -t
sudo systemctl restart nginx
```

## Step 3: Access the dashboard with NGINX

Now, you can access the Kubernetes dashboard using a simpler URL from your Proxmox host or any machine on the same network: `http://YOUR_UBUNTU_VM_IP/dashboard`.

Note: This setup proxies the insecure `kubectl proxy` service. For a production environment, you should configure NGINX to use HTTPS.

## Optional: Setting up NGINX Proxy Manager

For a more user-friendly and feature-rich experience, you can install NGINX Proxy Manager. It runs in Docker and provides a web interface for managing reverse proxy configurations and SSL certificates with Let's Encrypt.

### Install Docker and Docker Compose (if not already installed)

### Create a `docker-compose.yml` file to define the NGINX Proxy Manager container

### Deploy the container

### Access the web UI and create a new proxy host that forwards traffic to your Minikube dashboard service

# Updating the NGINX Configuration for the Kubernetes Dashboard

To access the Kubernetes dashboard through the NGINX reverse proxy, you need to update the NGINX configuration to point to the correct dashboard URL.

## Step 1: Get the Correct Dashboard URL

Run the following command on your Ubuntu VM to get the full path to the dashboard:

```sh
minikube dashboard --url
```

The output will be similar to this:

```
http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

## Step 2: Edit Your NGINX Configuration

Open the NGINX configuration file for your Minikube proxy:

```sh
sudo nano /etc/nginx/sites-available/minikube.conf
```

Modify the `proxy_pass` directive inside the `location /dashboard` block. It must point to the full path you retrieved in the previous step:

```nginx
server {
    listen 80;
    server_name YOUR_UBUNTU_VM_IP;

    location /dashboard {
        proxy_pass http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Crucial detail: The `proxy_pass` URL must end with a slash (`/`) to ensure NGINX correctly handles path and subpath forwarding.

Save the file and exit (Ctrl + X, Y, Enter).

## Step 3: Test and Restart NGINX

Test the NGINX configuration for syntax errors:

```sh
sudo nginx -t
```

Reload or restart NGINX to apply the new configuration:

```sh
sudo systemctl restart nginx
```

## Step 4: Access the Dashboard

Now, navigate to `http://YOUR_UBUNTU_VM_IP/dashboard` in your web browser. You should be greeted with the Kubernetes dashboard login page.

## Troubleshooting

- **Redirect loop**: If you encounter a redirect loop, it's possible the dashboard itself is redirecting to the root `/` path. This is a known issue for some versions. The most reliable fix is often to use the NGINX configuration that rewrites the path, as described in a previous response.
- **Path rewriting (Alternative)**: For a cleaner URL, you can use the path rewriting configuration. This redirects `http://YOUR_UBUNTU_VM_IP/` directly to the dashboard, so you don't need `/dashboard` in the URL:

```nginx
server {
    listen 80;
    server_name YOUR_UBUNTU_VM_IP;

    location / {
        proxy_pass http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

With this configuration, simply visiting `http://YOUR_UBUNTU_VM_IP/` will take you to the dashboard.
