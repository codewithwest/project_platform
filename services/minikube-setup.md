# Minikube Setup

### Use Puppet to Install Minikube:

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

# Enable the dashboard addon
exec { 'enable-dashboard':
  command     => 'minikube addons enable dashboard',
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

### Step 1: Create a systemd service

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

# Setting up NGINX as a Reverse Proxy for Minikube Dashboard

Using NGINX as a reverse proxy is a standard and effective way to expose services running inside your Proxmox VM to your network. This approach allows you to route traffic to the Minikube dashboard and other applications via the VM's IP address and a standard port, such as 80 (HTTP) or 443 (HTTPS).

## Benefits of Using NGINX as a Reverse Proxy

- **Security**: NGINX can handle HTTPS encryption, add authentication, and filter malicious requests, protecting your Minikube services.
- **Centralization**: With NGINX, you can manage and route traffic to multiple services running inside your VM, not just the Kubernetes dashboard.
- **Always On**: NGINX can be configured as a systemd service, ensuring it automatically starts on boot and always runs in the background.

## Step 1: Install NGINX on the Ubuntu VM

Ensure NGINX is installed and running on your Ubuntu VM.
If not installed, you can follow the instructions here: [NGINX Installation Guide](./ngix-service.md)

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
server {
    listen 8001;
    server_name 192.168.100.39;

    location / {
	proxy_pass http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/; # Must end with a slash
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
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

You can now access the Minikube dashboard using the IP address of your Ubuntu VM and the port 8001. For example,
`http://<proxmox-vm-ip>:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/`.
