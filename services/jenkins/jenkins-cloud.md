# Jenkins Kubernetes Cloud Configuration

## Overview

Setting up Jenkins's Kubernetes Cloud allows Jenkins to dynamically provision agent pods for builds, eliminating the need for static agents with pre-installed tools.

## Benefits

- **Dynamic provisioning**: Temporary agent pods created per build
- **Resource efficiency**: Pods destroyed after job completion
- **Scalability**: No manual agent management
- **Clean environment**: Fresh environment for each build

## Step 1: Install Kubernetes Plugin

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Install the **Kubernetes Plugin**
3. Restart Jenkins if required

## Step 2: Configure Kubernetes Cloud

1. Go to **Manage Jenkins** → **Manage Nodes and Clouds** → **Configure Clouds**
2. Click **Add a new cloud** → **Kubernetes**
3. Configure the following settings:

| Setting              | Value                                          | Purpose                   |
| -------------------- | ---------------------------------------------- | ------------------------- |
| Name                 | `minikube-cloud`                               | Descriptive cloud name    |
| Kubernetes URL       | `https://kubernetes.default.svc.cluster.local` | Internal K8s API endpoint |
| Kubernetes Namespace | `management`                                   | Jenkins namespace         |
| Credentials          | `Kubernetes Service Account`                   | Auto-detected from pod    |
| Connection Timeout   | `5`                                            | Default timeout           |

4. Click **Test Connection** (should succeed)
5. Click **Save**

## Step 3: Create Pod Template

1. In your `minikube-cloud` configuration, under **Pod Templates**, click **Add Pod Template**
2. Configure:

| Setting        | Value                          | Purpose               |
| -------------- | ------------------------------ | --------------------- |
| Name           | `docker-builder`               | Agent template name   |
| Label          | `docker-builder`               | Label for Jenkinsfile |
| Container Name | `minikube-tools`               | Container identifier  |
| Docker Image   | `jenkins/inbound-agent:latest` | Base Jenkins agent    |

3. Click **Save**

## Step 4: Jenkinsfile Example

```groovy
pipeline {
    agent { label 'docker-builder' }

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'minikube image build -t my-app:latest .'
                // Verify image
                sh 'minikube ssh -- docker images | grep my-app'
            }
        }
    }
}
```
