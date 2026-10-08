# Source-of-truth and drift policy

## Git-managed

- host and VM inventory;
- network intent and fixed internal addresses;
- Compose service definitions and pinned image digests;
- reverse-proxy routers, services, middleware selection, and TLS policy;
- example application configuration without credentials;
- persistent path, ownership, validation, and rollback documentation.

## Runtime-managed

- API keys, OAuth credentials, client certificates, and private keys;
- CPA provider auth JSON files;
- OpenWebUI environment secrets;
- databases, uploads, caches, logs, and ACME state;
- short-lived backups made immediately before a deployment;
- public management addressing.

Runtime-managed data must never be copied into Git. Manifests reference its
expected path and permissions only.

## Reconciliation

Before a change:

1. Compare the live file with its checked-in counterpart.
2. Stop if unexplained drift affects the target.
3. Back up the live target on the same filesystem.
4. Apply the smallest manifest change.
5. Validate configuration and service health.
6. Verify the user-facing path end to end.
7. Commit the manifest change and record any intentional deviation.
