# Configuring Ubuntu VM to Access Minikube ClusterIP Services

This guide provides the steps to configure your Ubuntu VM to access Minikube ClusterIP services through a persistent static route, and then use NGINX as an HTTPS reverse proxy.

### Step 1: Get Minikube Network Information

On your Ubuntu VM, run the following commands to find the Minikube virtual machine's IP address and the internal cluster IP range.

```sh
MINIKUBE_IP=$(minikube ip)
CLUSTER_CIDR=$(minikube ssh -- "sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep 'service-cluster-ip-range' | cut -d'=' -f2")
echo "Minikube IP: $MINIKUBE_IP"
echo "Cluster CIDR: $CLUSTER_CIDR"
```

### Step 2: Add a Persistent Static Route

Add a temporary route and then use Netplan to make it permanent. This directs traffic for the cluster IP range to the Minikube VM.

#### Add the Temporary Route

```sh
sudo ip route add <CLUSTER_CIDR> via <MINIKUBE_IP>
```

Replace `<CLUSTER_CIDR>` and `<MINIKUBE_IP>` with the values from the previous step.

#### Create a Netplan Configuration File

1. Find your network interface name: Run `ip a` to identify your primary network interface (e.g., `ens33`).
2. Create a Netplan configuration file at `/etc/netplan/99-minikube-route.yaml`.

```yaml
network:
  version: 2
  ethernets:
    <YOUR_INTERFACE_NAME>:
      routes:
        - to: <CLUSTER_CIDR>
          via: <MINIKUBE_IP>
```

Replace `<YOUR_INTERFACE_NAME>` with the actual interface name, and `<CLUSTER_CIDR>` and `<MINIKUBE_IP>` with the values from the previous step.

#### Apply the Netplan Configuration

```sh
sudo netplan apply
```

This will make the static route persistent across reboots.
