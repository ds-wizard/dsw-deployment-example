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
S3_USERNAME="${S3_USERNAME:-GK0123456789abcdef01234567}"
S3_PASSWORD="${S3_PASSWORD:-0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef}"

garage_exec() {
  docker compose exec -T "$GARAGE_SERVICE" /garage "$@"
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
  echo "Assigning single-node Garage layout..."
  garage_exec_quiet layout assign -z "$GARAGE_ZONE" -c "$GARAGE_CAPACITY" "$NODE_ID"
  garage_exec_quiet layout apply --version 1
fi

if ! garage_exec bucket info "$S3_BUCKET" >/dev/null 2>&1; then
  echo "Creating bucket '$S3_BUCKET'..."
  garage_exec_quiet bucket create "$S3_BUCKET"
fi

if ! garage_exec key info "$S3_USERNAME" >/dev/null 2>&1; then
  echo "Importing access key '$S3_USERNAME'..."
  garage_exec_quiet key import "$S3_USERNAME" "$S3_PASSWORD" -n "$GARAGE_KEY_NAME" --yes
fi

echo "Granting bucket permissions..."
garage_exec_quiet bucket allow --read --write --owner "$S3_BUCKET" --key "$S3_USERNAME"

echo "Enabling public website access..."
garage_exec_quiet bucket website --allow "$S3_BUCKET"

echo "Garage bootstrap completed."
echo "S3 endpoint: $S3_URL"
echo "Public website endpoint: http://$S3_BUCKET.web.garage.localhost:9002/"
echo "Bucket: $S3_BUCKET"
echo "Access key: $S3_USERNAME"
