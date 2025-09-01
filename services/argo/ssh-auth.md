# **Using a Private Git Repository with Argo CD**

## **Step 1: Generate an SSH key on your Ubuntu VM**

1. Access your Ubuntu VM via SSH or the Proxmox console.
2. Generate the SSH key pair using `ssh-keygen`:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/argocd-repo-key -C "argocd-key-for-github"
```

**Note:** Set a blank passphrase by pressing Enter twice when prompted.

## **Step 2: Add the public key to GitHub**

1. Display the public key's content in your terminal:

```bash
cat ~/.ssh/argocd-repo-key.pub
```

2. Copy the entire output, including `ssh-rsa` at the beginning and your email at the end.
3. Log in to your GitHub account in a web browser.
4. Navigate to Settings > SSH and GPG keys.
5. Click New SSH key or Add SSH key.
6. Provide a descriptive Title (e.g., "Argo CD on Proxmox").
7. Paste your public key into the "Key" field.
8. Click Add SSH key to save it.

## **Step 3: Create a Kubernetes Secret**

1. Execute the following command on your Ubuntu VM to create the secret:

```bash
kubectl create secret generic repo-secret-codewithwest \
  --from-literal=name=codewithwest \
  --from-literal=url=git@github.com:codewithwest/project_platform.git \
  --from-literal=type=git \
  --from-file=sshPrivateKey=/home/west/.ssh/argocd-repo-key \
  --labels=argocd.argoproj.io/secret-type=repository \
  -n management
```

## **Step 4: Patch the Argo CD repo server deployment**

1. Create a YAML patch file named `repo-server-patch.yaml` with the following content:

```yaml
spec:
  template:
    spec:
      volumes:
        - name: ssh-known-hosts
          configMap:
            name: argocd-ssh-known-hosts-cm
        - name: repo-credentials
          secret:
            secretName: argocd-repo-key-secret
      containers:
        - name: argocd-repo-server
          volumeMounts:
            - name: ssh-known-hosts
              mountPath: /etc/ssh/ssh_known_hosts
              subPath: ssh_known_hosts
            - name: repo-credentials
              mountPath: /home/argocd/.ssh
```

2. Apply the patch to your deployment:

```bash
kubectl patch deployment argocd-repo-server -n argocd --patch "$(cat repo-server-patch.yaml)"
```

3. Restart the deployment to ensure the new secret volume is mounted correctly:

```bash
kubectl rollout restart deployment argocd-repo-server -n management
```

## **Step 5: Verify the setup in Argo CD**

1. Log in to the Argo CD UI or run the CLI command from your Ubuntu VM.
2. Check the repository list in the UI (Settings > Repositories) or via the CLI (`argocd repo list`). The private repository should now show a Successful connection status.
