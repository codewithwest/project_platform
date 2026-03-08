Here is the cleaned-up version of the Markdown file:

# Setting up an NGINX Reverse Proxy for a Minikube Service

Configuring NGINX to act as a reverse proxy for a Minikube service allows you to expose the Minikube application to the internet without exposing the VM itself.

## Step 1 Install and Start Nginx

Ensure NGINX is installed and running on your Ubuntu VM.

### Update your package list and install NGINX:

```sh
sudo apt update
sudo apt install nginx -y
```

### Start the NGINX service:

```sh
sudo systemctl start nginx
```

### If a firewall is active on the Ubuntu VM, allow NGINX traffic:

```sh
sudo ufw allow 'Nginx Full
```

## Step 3: Create ssl certificates

```bash
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx-selfsigned.key -out /etc/nginx/ssl/nginx-selfsigned.crt
```

## Step 4: Configure NGINX as a Reverse Proxy

Create a new NGINX server block configuration file to handle the proxying.

### Create the new configuration file:

```sh
sudo nano /etc/nginx/sites-available/minikube-proxy.conf
```

- Paste the following configuration into the file, replacing `<minikube-tunnel-external-ip>` with the external IP you found in Step 1:

```nginx
server {
    listen 8443 ssl;
    server_name 192.168.100.39;

    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;

    location / {
        proxy_pass https://<>service-ip:443/;
        # Other headers
    }
}
```

- Save and close the file.

## Step 5: Enable the New Server Block

Enable your new configuration and remove the default one to prevent conflicts.

### Remove the default NGINX server block:

```sh
sudo rm /etc/nginx/sites-enabled/default
```

### Create a symbolic link to enable your new configuration:

```sh
sudo ln -s /etc/nginx/sites-available/<conf-file-name> /etc/nginx/sites-enabled/
```

## Step 6: Test and Restart NGINX

Before restarting, test your configuration for any syntax errors.

```sh
sudo nginx -t;
sudo systemctl restart nginx;
```

## Step 7: Test the Reverse Proxy Locally

Confirm that the reverse proxy is working correctly by making a request from within the Ubuntu VM.

- Run the curl command using your Ubuntu VM's IP address: `curl http://192.168.100.35:80`.
- If successful, this command should return the content of your Minikube application, which in this case is the NGINX welcome page.
