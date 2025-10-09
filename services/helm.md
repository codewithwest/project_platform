# Installing Helm

### Step 1: Install Helm

```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh
```

apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
name: default-pool
namespace: metallb-system
spec:
addresses:

- 192.168.1.240-192.168.1.250 # <-- IMPORTANT: Change this to a free range on your network!

---

apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
name: default-l2
namespace: metallb-system
