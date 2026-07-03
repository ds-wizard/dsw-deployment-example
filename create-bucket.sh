#!/bin/sh

set -eu

ENV_FILE="${ENV_FILE:-.env}"

if [ -f "$ENV_FILE" ]; then
  set -a
  . "./$ENV_FILE"
  set +a
fi

GARAGE_SERVICE="${GARAGE_SERVICE:-garage}"
GARAGE_ZONE="${GARAGE_ZONE:-dc1}"
GARAGE_CAPACITY="${GARAGE_CAPACITY:-1G}"
GARAGE_KEY_NAME="${GARAGE_KEY_NAME:-dsw-engine-wizard}"
S3_URL="${S3_URL:-http://host.docker.internal:9000}"
S3_BUCKET="${S3_BUCKET:-engine-wizard}"
PLUGINS_BUCKET="${PLUGINS_BUCKET:-plugins}"
# Garage access key ID must start with GK and contain 24 hex characters after it.
S3_USERNAME="${S3_USERNAME:-GK111111111111111111111111}"
# Garage secret key must be 64 hex characters.
S3_PASSWORD="${S3_PASSWORD:-1111111111111111111111111111111111111111111111111111111111111111}"

garage_exec() {
  if [ -f "$ENV_FILE" ]; then
    docker compose --env-file "$ENV_FILE" exec -T "$GARAGE_SERVICE" /garage "$@"
  else
    docker compose exec -T "$GARAGE_SERVICE" /garage "$@"
  fi
}

compose_ps() {
  if [ -f "$ENV_FILE" ]; then
    docker compose --env-file "$ENV_FILE" ps -q --status running "$GARAGE_SERVICE"
  else
    docker compose ps -q --status running "$GARAGE_SERVICE"
  fi
}

garage_exec_quiet() {
  output_file="$(mktemp)"
  if garage_exec "$@" >"$output_file" 2>&1; then
    rm -f "$output_file"
    return 0
  fi

  cat "$output_file" >&2
  rm -f "$output_file"
  return 1
}

ensure_bucket() {
  bucket_name="$1"
  website_public="${2:-false}"

  if ! garage_exec bucket info "$bucket_name" >/dev/null 2>&1; then
    garage_exec_quiet bucket create "$bucket_name"
  fi

  garage_exec_quiet bucket allow --read --write --owner "$bucket_name" --key "$S3_USERNAME"

  if [ "$website_public" = "true" ]; then
    garage_exec_quiet bucket website --allow "$bucket_name"
  fi
}

if [ -z "$(compose_ps 2>/dev/null)" ]; then
  echo "Garage service '$GARAGE_SERVICE' is not running. Start the stack first with: docker compose up -d" >&2
  exit 1
fi

STATUS="$(garage_exec status 2>/dev/null)"
NODE_ID="$(printf '%s\n' "$STATUS" | awk '/==== HEALTHY NODES ====/{flag=1; next} flag && $1 ~ /^[0-9a-f]+$/ {print $1; exit}')"

if [ -z "$NODE_ID" ]; then
  echo "Unable to determine the Garage node ID from 'garage status'." >&2
  exit 1
fi

if printf '%s\n' "$STATUS" | grep -q "NO ROLE ASSIGNED"; then
  garage_exec_quiet layout assign -z "$GARAGE_ZONE" -c "$GARAGE_CAPACITY" "$NODE_ID"
  garage_exec_quiet layout apply --version 1
fi

if ! garage_exec key info "$S3_USERNAME" >/dev/null 2>&1; then
  garage_exec_quiet key import "$S3_USERNAME" "$S3_PASSWORD" -n "$GARAGE_KEY_NAME" --yes
fi

ensure_bucket "$S3_BUCKET" false
ensure_bucket "$PLUGINS_BUCKET" true

echo "Garage is ready."
