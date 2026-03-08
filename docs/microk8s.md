# Setup microk8s


## 1. Install microk8s

```bash
sudo snap install microk8s --classic
```

## 2. Add user to microk8s group

```bash
sudo usermod -a -G microk8s $USER
```

### After this, reload the user groups either via a reboot or by running 

```bash
newgrp microk8s
```

```bash
sudo chown -f -R $USER ~/.kube
```

## 3. Enable microk8s addons

### Enable the internal Registry & Storage:

### You need the registry to store those "valid images" you'll be building, and hostpath for Jenkins to save its data.

```bash
microk8s enable hostpath-storage dns registry
```

## 4. Verify the Nodes:

```bash
microk8s kubectl get nodes
```

### Status should be Ready.

## 5. Check your RAM "Remaining":

```bash
free -h
```

## 6. 🛠️ The "Permanent SSL Fix"

### Since you are on Ubuntu, follow these steps to regenerate a compliant CA:

#### 1. Create a workspace and generate the new CA

We need to add keyUsage specifically.

```bash
mkdir ~/microk8s-ssl-fix && cd ~/microk8s-ssl-fix

# Generate a new private key for the CA
openssl genrsa -out ca.key 2048

# Generate the new CA certificate with the missing extensions
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt \
  -subj "/CN=MicroK8s-Root-CA" \
  -addext "keyUsage=critical,digitalSignature,keyCertSign"
```

#### 2. Inject the new CA into MicroK8s

MicroK8s has a built-in command to refresh its certificates using a custom CA directory.

```bash
sudo microk8s refresh-certs --cert ca.crt
```

**Note**: This will restart the kubelite service. Your cluster will be briefly unreachable.