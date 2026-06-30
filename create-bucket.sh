#!/bin/sh

set -eu

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

GARAGE_SERVICE="${GARAGE_SERVICE:-garage}"
GARAGE_ZONE="${GARAGE_ZONE:-dc1}"
GARAGE_CAPACITY="${GARAGE_CAPACITY:-1G}"
GARAGE_KEY_NAME="${GARAGE_KEY_NAME:-dsw-engine-wizard}"
S3_URL="${S3_URL:-http://host.docker.internal:9000}"
S3_BUCKET="${S3_BUCKET:-engine-wizard}"
S3_USERNAME="${S3_USERNAME:-garage}"
S3_PASSWORD="${S3_PASSWORD:-garagePassword}"

garage_exec() {
  docker compose exec -T "$GARAGE_SERVICE" /garage "$@"
}

if [ -z "$(docker compose ps -q --status running "$GARAGE_SERVICE" 2>/dev/null)" ]; then
  echo "Garage service '$GARAGE_SERVICE' is not running. Start the stack first with: docker compose up -d" >&2
  exit 1
fi

STATUS="$(garage_exec status)"
NODE_ID="$(printf '%s\n' "$STATUS" | awk '/==== HEALTHY NODES ====/{flag=1; next} flag && $1 ~ /^[0-9a-f]+$/ {print $1; exit}')"

if [ -z "$NODE_ID" ]; then
  echo "Unable to determine the Garage node ID from 'garage status'." >&2
  exit 1
fi

if printf '%s\n' "$STATUS" | grep -q "NO ROLE ASSIGNED"; then
  garage_exec layout assign -z "$GARAGE_ZONE" -c "$GARAGE_CAPACITY" "$NODE_ID" >/dev/null
  garage_exec layout apply --version 1 >/dev/null
fi

if ! garage_exec bucket info "$S3_BUCKET" >/dev/null 2>&1; then
  garage_exec bucket create "$S3_BUCKET" >/dev/null
fi

if ! garage_exec key info "$S3_USERNAME" >/dev/null 2>&1; then
  garage_exec key import "$S3_USERNAME" "$S3_PASSWORD" -n "$GARAGE_KEY_NAME" --yes >/dev/null
fi

garage_exec bucket allow --read --write --owner "$S3_BUCKET" --key "$S3_USERNAME" >/dev/null

garage_exec bucket website --allow "$S3_BUCKET" >/dev/null

echo "Garage is ready."
