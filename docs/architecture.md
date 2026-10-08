# Server architecture

## Physical host

`lumpi` is a Hetzner bare-metal server running Debian 13. It has a 6-core,
12-thread Intel Core i7-8700, 64 GiB RAM, mirrored boot/root devices, and a ZFS
pool for Incus. Public management addressing is intentionally not stored here.

Storage is split into:

- Linux software RAID1 for `/boot`, `/`, and swap;
- ZFS pool `incus-pool` for Incus images and virtual-machine volumes.

## Virtualization

Incus 6.0 LTS runs virtual machines rather than system containers. Workloads
are separated by role and trust domain. Docker is nested only inside workload
VMs that need it.

| VM | Role | CPU | Memory | Service address |
|---|---|---:|---:|---|
| `edge` | Public Traefik ingress | 2 | 2 GiB | `10.77.10.10`, management `10.77.50.10` |
| `services` | Shared Docker services | 4 | 10 GiB | `10.77.20.10`, management `10.77.50.20` |
| `identity` | Entra/oauth2-proxy | 1 | 1 GiB | `10.77.30.10`, management `10.77.50.30` |
| `grcviewer` | Isolated GRCviewer | 2 | 3 GiB | `10.77.20.11`, management `10.77.50.21` |
| `docker-test` | Integration testing | 2 | 2 GiB | `10.77.20.91`, management `10.77.50.91` |
| `hello-native` | Native routing probe | 1 | 1 GiB | `10.77.20.90`, management `10.77.50.90` |

The detailed inventory is in [`infrastructure/incus/instances.yaml`](../infrastructure/incus/instances.yaml).

## Network trust domains

```text
Internet
   |
   v
edge / Traefik
   | net-edge and routed policy
   +--> net-apps       application backends
   +--> net-core       identity and DanielOS core
   +--> net-automation agents and automation

WireGuard / administration
   |
   +--> net-management management interfaces only
```

The `10.77.0.0/16` space is split into non-NAT Incus bridges. The host routes
between trust domains under explicit firewall policy. Public HTTP(S) terminates
only at `edge`; application VMs do not bind directly to public interfaces.

## Ingress and identity

Traefik on `edge` owns ports 80 and 443, obtains wildcard certificates through
Hetzner DNS, and watches `/etc/traefik/dynamic`. Identity-aware web applications
use the native `identity` VM through forward-auth middlewares. Machine APIs use
service-specific authentication such as mTLS and CPA bearer keys.

## Service placement

The `services` VM stores Compose projects below `/srv/docker/services`.
Currently observed stacks include `ai-gateway`, Kimai, Stirling PDF,
Kleinanzeigen, and Omada MCP. Each stack should gain its own directory here as
it is brought under manifest management.

`ai-gateway` is the first fully captured stack. See
[`services/ai-gateway/README.md`](../services/ai-gateway/README.md).
