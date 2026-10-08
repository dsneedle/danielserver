# Working agreement

This repository is the declarative and operational source of truth for the
Hetzner server named `lumpi`.

## Safety

- Never commit secrets, bearer tokens, API keys, OAuth credentials, private
  keys, client certificates, raw provider auth files, database contents, logs,
  backups, or public management addresses.
- Use placeholders in examples and document the live secret path instead.
- Keep runtime data and credentials on the server with restrictive ownership.
- Inspect live state before changing manifests. Report and resolve drift rather
  than silently overwriting it.
- Back up the exact live target before deployment and define rollback before a
  service restart or reload.

## Repository conventions

- `inventory/` describes the physical host and intended workload placement.
- `infrastructure/` describes shared Incus primitives and trust domains.
- `services/<name>/` contains the service manifest, deployable configuration,
  and operations notes for one stack.
- `docs/` contains cross-cutting architecture and operating policy.
- Live paths are stated explicitly in each service README.

The checked-in manifests must remain secret-free and suitable for a public
repository. A manifest is authoritative for structure and security policy;
runtime secrets and persistent data are deliberately external.

