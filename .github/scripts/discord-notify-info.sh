#!/bin/sh

WEBHOOK_URL=$1
IMAGE=$2
REPO=$3
RUN=$4

curl \
  -sS -X POST \
  -H 'Content-type: application/json' \
  --data "{
		\"content\": \"✅ No critical vulnerabilities found in **$IMAGE**: [Security Audit run #$RUN](<https://github.com/$REPO/actions/runs/$RUN>)\",
		\"embeds\": null,
		\"attachments\": []
  	}" \
  "$WEBHOOK_URL"
