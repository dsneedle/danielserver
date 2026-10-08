#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

find "$repo_root" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 |
  xargs -0 ruby -e 'require "yaml"; ARGV.each { |path| YAML.safe_load(File.read(path), aliases: true); puts "ok #{path}" }'

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  runtime_env="$repo_root/services/ai-gateway/openwebui/app.env"
  created_runtime_env=false
  if [ ! -e "$runtime_env" ]; then
    cp "$runtime_env.example" "$runtime_env"
    created_runtime_env=true
  fi
  cleanup() {
    if [ "$created_runtime_env" = true ]; then
      rm -f "$runtime_env"
    fi
  }
  trap cleanup EXIT HUP INT TERM
  docker compose \
    --project-directory "$repo_root/services/ai-gateway" \
    -f "$repo_root/services/ai-gateway/compose.yaml" \
    -f "$repo_root/services/ai-gateway/compose.override.yaml" \
    config --quiet
  cleanup
  trap - EXIT HUP INT TERM
fi

if rg -n --hidden \
  --glob '!.git/**' \
  --glob '!*.example*' \
  '(BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|gh[opsu]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,})' \
  "$repo_root"; then
  echo "possible secret material detected" >&2
  exit 1
fi
