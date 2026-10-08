# ai-gateway

OpenAI-compatible model gateway and authenticated OpenWebUI stack.

## Live placement

- VM: `services`
- Compose project: `ai-gateway`
- Live directory: `/srv/docker/services/ai-gateway`
- Traefik route: `edge:/etc/traefik/dynamic/60-ai-gateway.yaml`
- Application address: `10.77.20.10`

## Components

- **CLIProxyAPI (CPA)** on `10.77.20.10:8317` provides the model API and
  per-client bearer authentication.
- **OpenWebUI** on `10.77.20.10:8082` uses a dedicated CPA credential and is
  protected by Entra forward-auth at Traefik.
- **Otto Memory** is a CPA-native plugin persisted under
  `cliproxyapi/data/otto-memory.sqlite` and scoped to the dedicated HA/Otto key.

## Public routes

| Host | Client | Transport/authentication |
|---|---|---|
| `ai.service.lti.one` | managed API clients | mTLS plus CPA bearer key |
| `ha-ai.service.lti.one` | Home Assistant/Otto | TLS plus dedicated CPA bearer key |
| `openwebui.service.lti.one` | browser users | TLS plus Entra forward-auth |

Both CPA hosts expose only explicitly listed OpenAI/Anthropic/Gemini-compatible
API paths. All CPA routes retain the Traefik rate limit.

### Home Assistant policy decision

The former static source-IP `/32` allowlist was removed on 2026-10-08. The
residential uplink changes address and repeatedly caused Traefik HTTP 403
responses before CPA. Authentication now relies on the dedicated 64-character
HA/Otto CPA bearer key, while TLS, exact path routing, rate limiting, and
per-client key isolation remain in force. No key was rotated or shared.

## Runtime-only material

Do not commit these live paths or their contents:

- `cliproxyapi/config.yaml` — contains downstream keys and the caller scope;
- `cliproxyapi/auths/` — provider credentials;
- `cliproxyapi/secrets/` — root-only management and client keys;
- `cliproxyapi/data/` and `cliproxyapi/logs/` — mutable state;
- `openwebui/app.env` and `openwebui/data/` — secrets and user data.

Create runtime files from the checked-in examples and provision their values
out of band.

## Validation

From the `services` VM:

```bash
cd /srv/docker/services/ai-gateway
docker compose config --quiet
docker compose ps
```

Expected security behavior:

- allowed CPA path without a key: HTTP 401;
- allowed CPA path with an invalid key: HTTP 401;
- unlisted path: HTTP 404;
- `/v1/models` with the dedicated HA key: HTTP 200 and `gpt-6-luna` present;
- HA `conversation.process` through `conversation.gpt_6_luna`: successful
  response;
- CPA and OpenWebUI containers: healthy.

## Rollback

Before changing a live file, copy it next to itself with a UTC timestamp. To
roll back an ingress-only change, restore the previous
`/etc/traefik/dynamic/60-ai-gateway.yaml`; Traefik watches the directory and
reloads it automatically. Confirm Traefik remains active and rerun the endpoint
checks.
