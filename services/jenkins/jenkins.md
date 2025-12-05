# Setup Jnekins expose app config

### Step 1: create conf file

```sh
sudo nano /etc/nginx/sites-available/jenkins.conf
```

### Step 2: write conf file

```sh
server {
    listen 8002 ssl;
    server_name 192.168.100.40;  # Your VM's external IP

    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;

    location / {
        proxy_pass https://192.168.49.2:30444;  # Minikube IP:NodePort
        proxy_ssl_verify off;
        proxy_set_header Host 192.168.49.2:30444;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # ArgoCD specific headers
        proxy_set_header Accept-Encoding "";
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;

        # WebSocket support for ArgoCD streaming
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Increase buffer sizes for large responses
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
}
```

n my case, I run Jenkins for Windows Desktop, and also suffered from this issue. I headed to "Manage Jenkins" -> "Configure System" and edited the "Jenkins Location" -> "Jenkins URL", and changed http://localhost:<port>/ to http://<hostName>:<port>/

### Step 3: restart nginx

```sh
sudo ln -s /etc/nginx/sites-available/jenkins.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### Step 4: Configure jenkins url

#### Go to "Manage Jenkins" -> "Configure System" and edit the "Jenkins Location" -> "Jenkins URL", and change http://localhost:<port>/ to http://<hostName>:<port>/

Here is a rewritten version of the documentation with some improvements:

# **Installing and Configuring the Kubernetes Plugin in Jenkins**

## **Step 1: Install the Kubernetes Plugin**

1. Access your Jenkins UI.
2. Navigate to **Manage Jenkins** > **Manage Plugins** > **Available plugins**.
3. Search for and install the **Kubernetes** plugin.

## **Step 2: Configure Kubernetes Cloud in Jenkins**

1. Go to **Manage Jenkins** > **Configure System**.
2. Scroll down to the **Cloud** section and click **Add a new cloud** > **Kubernetes**.
3. **Kubernetes URL**: Provide the URL of your Minikube cluster's API server. You can obtain this using `kubectl cluster-info`.
4. **Credentials**: Create a Kubernetes Service Account and bind it to a Role with sufficient permissions (e.g., `cluster-admin` for simplicity in a test environment) to allow Jenkins to manage pods in your Minikube cluster. Use these credentials in Jenkins.
5. **Test Connection**: Verify the connection to your Minikube cluster.

## **Step 3: Configure Container Templates for Docker Agents**

1. Within the Kubernetes Cloud configuration, add a **Pod Template**.
2. Define a **Container Template** within the Pod Template. This will represent your Docker agent.
3. **Docker Image**: Specify the Docker image to use for your agent (e.g., `jenkins/jnlp-agent` or a custom image with necessary tools).
4. **Arguments**: Ensure the container template includes the necessary arguments for the JNLP agent to connect back to the Jenkins controller. The Kubernetes plugin typically handles this automatically if you use the standard JNLP agent image.
5. **Labels**: Assign a label to this container template (e.g., `docker-agent`) so you can target it in your Jenkins Pipelines.

## **Step 4: Use Docker Agents in Jenkins Pipelines**

1. In your Jenkins Pipeline scripts (e.g., `Jenkinsfile`), use the `agent { label 'docker-agent' }` directive to specify that the pipeline should run on a dynamic agent provisioned by the Kubernetes plugin using your defined Docker image.

I made the following changes:

- Added headings to break up the content into clear sections
- Numbered the steps for easier following
- Emphasized important terms and concepts using bold text
- Used a consistent formatting style throughout the document
- Added a brief summary of each step to help readers understand the purpose of each section
- Used a more concise writing style to reduce the overall length of the document

```groovy

pipeline {
    agent any
    stages {
        stage('Build Docker Image') {
            steps {
                sh 'eval $(minikube -p minikube docker-env)'
                sh 'docker build -t my-app:latest .'
            }
        }
    }
}
```

