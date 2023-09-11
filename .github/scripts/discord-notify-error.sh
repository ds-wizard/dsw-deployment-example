#!/bin/sh

WEBHOOK_URL=$1
IMAGE=$2
COUNT=$3
REPO=$4
RUN=$5

VULNERABILITY="vulnerability"

if [ $COUNT -gt "1" ]; then
    VULNERABILITY="vulnerabilities"
fi

curl \
  -sS -X POST \
  -H 'Content-type: application/json' \
  --data "{
		\"content\": \"⚠️ Found **$COUNT** critical $VULNERABILITY in **$IMAGE**: [Security Audit run #$RUN](<https://github.com/$REPO/actions/runs/$RUN>)\",
		\"embeds\": null,
		\"attachments\": []
  	}" \
  "$WEBHOOK_URL"
