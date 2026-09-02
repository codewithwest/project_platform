# DragonSlur Platform Infrastructure

This document is the source-of-truth checkpoint for the DragonSlur platform infrastructure. GingerOS is an application that will eventually run on this platform; it is not the name of the cluster infrastructure.

## Current State — 2026-09-02

### `node-master`

| Property | Value |
|---|---|
| Hostname | `node-master` |
| OS | Ubuntu 26.04.1 LTS |
| Kernel | `7.0.0-30-generic` |
| Architecture | amd64 |
| CPU | 4 cores |
| RAM | ~7.2 GiB |
| Ethernet | `eno1` |
| MAC | `c8:d9:d2:a6:92:6e` |
| LAN IP | `192.168.100.31/24` |
| Gateway | `192.168.100.1` |
| Network | DHCP |
| Link speed | 100 Mbps full duplex |

The router/fibre equipment is not currently accessible, so a DHCP reservation cannot be configured. The existing DHCP configuration is therefore being retained and Netplan has not been changed.

## K3s

K3s is installed and healthy:

- Version: `v1.36.4+k3s1`
- Role: control-plane/server
- Node: `node-master` — `Ready`
- Container runtime: `containerd://2.3.4-k3s1.36`
- Pod network: `10.42.0.0/16`
- Service network: `10.43.0.0/16`
- `/etc/rancher/k3s/config.yaml`: not present; K3s is currently using its generated systemd service configuration

### Verified system components

- CoreDNS — Running
- Traefik — Running
- Metrics Server — Running
- Local Path Provisioner — Running
- Flannel/CNI — Running

The completed `helm-install-traefik-*` jobs are expected and are not errors.

## Network

Verified routes include:

```text
default via 192.168.100.1 dev eno1
192.168.100.0/24 dev eno1 src 192.168.100.31
10.42.0.0/24 dev cni0 src 10.42.0.1
```

DNS is currently supplied by the LAN gateway (`192.168.100.1`) and an IPv6 link-local resolver.

The Ethernet connection is negotiating at 100 Mbps full duplex. This is acceptable for initial platform setup, but the physical cable/switch/router path should later be checked because distributed storage and database replication benefit from 1 Gbps or better.

## Storage

The machine has one physical disk:

```text
/dev/sda
├── sda1
├── sda2                 ext4  /boot
└── sda3                 LVM2 PV
    └── ubuntu-vg
        └── ubuntu-lv    ext4  /
```

Current LVM state:

```text
VG:       ubuntu-vg
Size:     <236.47 GiB
Free:     <136.47 GiB
LVs:      1
```

Root filesystem:

```text
Size:      ~98 GiB
Used:      ~8.8 GiB
Available: ~85 GiB
Use:       ~10%
```

**The ~136.47 GiB free LVM space is intentionally untouched.** No new LV, filesystem, partition, or mount has been created for it yet.

## Storage Prerequisites

The following prerequisites have been verified:

- `open-iscsi` installed
- `nfs-common` installed
- `iscsid` enabled and active
- `iscsiadm` available at `/usr/sbin/iscsiadm`
- `iscsi_tcp` kernel module loaded

Longhorn has **not** been installed.

## Storage Architecture Decision

The platform currently has only one physical K3s node and one physical disk. Longhorn replication at this stage would not provide physical redundancy because replicas would reside on the same machine/disk.

Therefore:

1. Preserve the ~136 GiB free LVM space until the storage layout is finalized.
2. Do not format or allocate that space blindly.
3. Bring additional physical nodes online before relying on distributed storage replication.
4. Evaluate Longhorn once suitable additional nodes/disks are available.
5. Establish persistent storage before deploying stateful platform services such as PostgreSQL and Redis.
6. Deploy GingerOS on top of the DragonSlur platform after the platform foundation is stable.

## Planned Platform Topology

```text
                         DragonSlur Platform
                                  |
                              K3s cluster
                                  |
             +--------------------+--------------------+
             |                    |                    |
        node-master        node-compute-1       node-compute-2
             |
             +---------------- node-utility-1
             |
             +---------------- node-utility-2
                                  |
                         Persistent Storage
                                  |
                     PostgreSQL / Redis / Apps
                                  |
                              GingerOS
```

The additional nodes are planned but have **not** been joined or modified yet.

## Progress Checklist

- [x] Ubuntu installed
- [x] Hostname set to `node-master`
- [x] LAN connectivity verified
- [x] DHCP address `192.168.100.31` verified
- [x] Swap disabled
- [x] Previous MicroK8s installation removed
- [x] K3s installed
- [x] K3s server running
- [x] `node-master` Ready
- [x] CoreDNS running
- [x] Traefik running
- [x] Metrics Server running
- [x] Flannel running
- [x] Local Path Provisioner running
- [x] `open-iscsi` installed
- [x] `nfs-common` installed
- [x] `iscsid` enabled and running
- [x] `iscsi_tcp` loaded
- [x] Disk/LVM layout inspected
- [x] ~136 GiB free LVM preserved
- [ ] Finalize persistent-storage layout
- [ ] Install/configure Longhorn when appropriate
- [ ] Install CloudNativePG
- [ ] Deploy PostgreSQL
- [ ] Install Redis
- [ ] Add compute nodes
- [ ] Add utility nodes
- [ ] Deploy platform applications
- [ ] Deploy GingerOS

## Next Checkpoint

The DragonSlur platform foundation on `node-master` is healthy. The next infrastructure change should be the deliberate persistent-storage layout decision. Until that decision is made, the free LVM space must remain untouched.
