Here is the cleaned-up version of the Markdown file:

# Setting Up an NGINX Reverse Proxy for a Minikube Service

This guide explains how to configure NGINX as a reverse proxy on a Ubuntu VM to expose a Minikube service, such as the nginx-service, to the network.

## Step 1: Get the Minikube Service's External IP

First, you need the external IP address assigned to your Minikube service by the minikube tunnel process.

- Open a new terminal and run the minikube tunnel command. This command requires sudo privileges and will run continuously, so keep it open.
- Open a second terminal and get the service's external IP address. You may need to wait a few moments for the minikube tunnel process to assign an IP.
- Run `kubectl get services` to get the list of services. Find the nginx-service and note the IP address in the EXTERNAL-IP column.

## Step 2: Install and Start NGINX

Ensure NGINX is installed and running on your Ubuntu VM.

- Update your package list and install NGINX: `sudo apt update` and `sudo apt install nginx`.
- Verify the NGINX service is running: `sudo systemctl status nginx`.
- If a firewall is active on the Ubuntu VM, allow NGINX traffic: `sudo ufw allow 'Nginx Full'`.

## Step 3: Configure NGINX as a Reverse Proxy

Create a new NGINX server block configuration file to handle the proxying.

- Create the new configuration file: `sudo nano /etc/nginx/sites-available/minikube-proxy.conf`.
- Paste the following configuration into the file, replacing `<minikube-tunnel-external-ip>` with the external IP you found in Step 1:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name 192.168.100.35; # Use your Ubuntu VM's IP address

    location / {
        proxy_pass http://<minikube-tunnel-external-ip>:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

- Save and close the file.

## Step 4: Enable the New Server Block

Enable your new configuration and remove the default one to prevent conflicts.

- Remove the default NGINX server block: `sudo rm /etc/nginx/sites-enabled/default`.
- Create a symbolic link to enable your new configuration: `sudo ln -s /etc/nginx/sites-available/minikube-proxy.conf /etc/nginx/sites-enabled/`.

## Step 5: Test and Restart NGINX

Before restarting, test your configuration for any syntax errors.

- Test the configuration: `sudo nginx -t`.
- If the test is successful, restart NGINX to apply the changes: `sudo systemctl restart nginx`.

## Step 6: Test the Reverse Proxy Locally

Confirm that the reverse proxy is working correctly by making a request from within the Ubuntu VM.

- Run the curl command using your Ubuntu VM's IP address: `curl http://192.168.100.35:80`.
- If successful, this command should return the content of your Minikube application, which in this case is the NGINX welcome page.

## Next Steps

Once the reverse proxy is verified to be working on the Ubuntu VM, the final step is to configure iptables rules on your Proxmox host to forward external traffic to the NGINX proxy. This will make your Minikube application accessible from outside the host.
