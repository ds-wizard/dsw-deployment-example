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
	\"blocks\": [
		{
			\"type\": \"header\",
			\"text\": {
				\"type\": \"plain_text\",
				\"text\": \"Grype Security Audit\",
				\"emoji\": true
			}
		},
		{
			\"type\": \"section\",
			\"text\": {
				\"type\": \"mrkdwn\",
				\"text\": \":exclamation: *${COUNT}* critical vulnerabilities in *${IMAGE}*\"
			}
		},
		{
			\"type\": \"actions\",
			\"elements\": [
				{
					\"type\": \"button\",
					\"text\": {
						\"type\": \"plain_text\",
						\"text\": \"Open GitHub Action Run\",
						\"emoji\": true
					},
					\"value\": \"go\",
					\"url\": \"https://github.com/$REPO/actions/runs/$RUN\",
					\"action_id\": \"actionId-0\"
				}
			]
		}
	]
  }" \
  "$WEBHOOK_URL"
