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

### If you have less than 1GB free, we need to be very aggressive with resource limits in the next steps.