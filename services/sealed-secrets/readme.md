# setup

KUBESEAL_VERSION="0.36.0"

# Download the tarball

curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"

# Extract the binary

tar -xvzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal

````

# Install it to your local bin

```sh
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
````

# Verify the installation

```sh
kubeseal --version
```

# Encrypt the secret

```sh
kubeseal --controller-name=sealed-secrets \
 --controller-namespace=management \
 --format yaml < unsealed-secret.yaml > sealed-secret.yaml
```

# Decrypt the secret

```sh
kubeseal --controller-name=sealed-secrets \
 --controller-namespace=management \
 --format yaml < sealed-secret.yaml > unsealed-secret.yaml
```
