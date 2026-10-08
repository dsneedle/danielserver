# danielserver

Secret-free infrastructure documentation and service manifests for the
Hetzner bare-metal server `lumpi`.

The repository mirrors the live hierarchy:

```text
lumpi (Debian bare metal)
├── Incus + ZFS
│   ├── edge          public Traefik ingress
│   ├── services      shared Docker application stacks
│   ├── identity      Entra/oauth2-proxy identity gateway
│   ├── grcviewer     isolated application VM
│   ├── docker-test   integration test VM
│   └── hello-native  native edge-path test VM
└── Trust-domain bridges
    ├── net-edge
    ├── net-apps
    ├── net-core
    ├── net-automation
    └── net-management
```

## Repository map

- [`docs/architecture.md`](docs/architecture.md) — physical and logical design
- [`inventory/hosts/lumpi.yaml`](inventory/hosts/lumpi.yaml) — host inventory
- [`infrastructure/incus/`](infrastructure/incus/) — networks and VM placement
- [`services/ai-gateway/`](services/ai-gateway/) — CPA/OpenWebUI stack and ingress

## Source-of-truth boundary

Git contains intended structure, pinned images, routes, mounts, and security
policy. It does not contain secrets or mutable state. See
[`docs/source-of-truth.md`](docs/source-of-truth.md).

The initial inventory was reconciled against live state on 2026-10-08.
