# Jenkins + Minikube Kubernetes Cloud (Insecure HTTPS) – Minimal Setup

## 1. Jenkins Kubernetes Cloud
- Install **Kubernetes Plugin** via **Manage Jenkins → Manage Plugins**
- Configure cloud:
  - Name: `minikube-cloud`
  - Kubernetes URL: `https://kubernetes.default.svc.cluster.local`
  - Namespace: `management`
  - Credentials: `Kubernetes Service Account`
  - Connection Timeout: `5`
- Test Connection → Save

---

## 2. Pod Template (docker-builder)
- Name: `docker-builder`
- Label: `docker-builder`
- Container Name: `minikube-tools`
- Docker Image: `jenkins/inbound-agent:latest`
- Use **Raw YAML**:

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    tty: true
    command: [ "jenkins-agent" ]
    env:
      - name: JENKINS_AGENT_INSECURE
        value: "true"
      - name: JENKINS_URL
        value: "https://192.168.100.40:8002/"
    resources:
      requests:
        cpu: "100m"
        memory: "256Mi"
      limits:
        cpu: "500m"
        memory: "512Mi"
