Good catch — let’s not assume anything and keep it clean 👍

Since you chose to keep **Pi-hole** outside **MicroK8s**, you’ve got two solid options:

---

# 🧠 Option A (Recommended): Install Docker

This keeps Pi-hole isolated and easy to manage.

## 🚀 Install Docker (Ubuntu)

```bash
sudo apt update
sudo apt install -y docker.io
```

Enable + start:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Add your user:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## Install Docker Compose plugin

```bash
sudo apt install -y docker-compose-plugin
```

---

## Verify

```bash
docker --version
docker compose version
```

---

## Then run Pi-hole (minimal)

```yaml
version: "3"
services:
  pihole:
    image: pihole/pihole:latest
    network_mode: bridge

    ports:
      - "8081:80"web UI
      - "8443:443"
      - "53:53/tcp"                    - "53:53/udp"
    environment:
      TZ: Africa/Johannesburg
      WEBPASSWORD: admin
    volumes:
      - ./pihole/etc-pihole:/etc/pihole
      - ./pihole/etc-dnsmasq.d:/etc/dnsmasq.d
    restart: unless-stopped
```

# ⚠️ One important note

Before running Pi-hole (Docker or native):

You MUST free port 53:

```bash
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
```

---

# Start PiHole

```bash
docker compose up -d
```
