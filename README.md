<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="left" width="144px" height="144px"/>

# My home K3s cluster

_... managed by Flux and Renovate_ :robot:

<br/>
<br/>
<br/>

<div align="center">

[![k3s](https://img.shields.io/badge/k3s-v1.30.4-blue?style=for-the-badge&logo=kubernetes&logoColor=white)](https://k3s.io/)
[![Renovate](https://img.shields.io/github/actions/workflow/status/AnthonyEnr1quez/k3s-gitops/renovate.yaml?branch=main&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/AnthonyEnr1quez/k3s-gitops/actions/workflows/renovate.yaml)

</div>

## :wrench:&nbsp; Hardware

| Device                          | Hostname | OS Disk Size | Data Disk Size | Ram  | Operating System       | Purpose           |
|---------------------------------|----------|--------------|----------------|------|------------------------|------------------|
| HP ProDesk 600 G2 Mini i5-6500T | gulsun   | 512GB SSD    | -              | 16GB | Kairos - openSUSE Leap | Kubernetes Master |
| HP ProDesk 600 G2 Mini i5-6600T | mina     | 160GB SSD    | 11TB HD (nfs)  | 8GB  | Kairos - openSUSE Leap | Kubernetes Agent  |
| Raspberry Pi 4                  | barzan   | 512GB SSD    | -              | 2GB  | Kairos - openSUSE Leap | Kubernetes Agent  |
| Raspberry Pi 3b+                | diana    | 64GB SD Card | -              | 1GB  | Kairos - openSUSE Leap | Kubernetes Agent  |

---
## :raised_hands:&nbsp; Thanks

### :handshake:&nbsp; People
- [onedr0p](https://github.com/onedr0p)
- [bjw-s](https://github.com/bjw-s)
- [k8s-at-home discord](https://discord.gg/k8s-at-home)

### :notebook:&nbsp; Resources
- [k8s-at-home-search](https://nanne.dev/k8s-at-home-search/)
- [kairos](https://kairos.io/)
- [flux-cluster-template](https://github.com/onedr0p/flux-cluster-template)
