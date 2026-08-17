#!/usr/bin/env bash
set -euo pipefail
source /etc/novanet/server.env
: "${NOVANET_CONTROL_URL:?set NOVANET_CONTROL_URL}"
: "${NOVANET_SERVER_KEY:?set NOVANET_SERVER_KEY}"
: "${NOVANET_SERVER_NAME:?set NOVANET_SERVER_NAME}"
: "${NOVANET_ENDPOINT:?set NOVANET_ENDPOINT}"
region=${NOVANET_REGION:-}
url="$NOVANET_CONTROL_URL"
body=$(printf '{"action":"register","server_key":"%s","name":"%s","endpoint":"%s","region":"%s","protocol":"wdtt","public_key":"%s"}' "$NOVANET_SERVER_KEY" "$NOVANET_SERVER_NAME" "$NOVANET_ENDPOINT" "$region" "$(wg show "${NOVANET_WG_INTERFACE:-wg0}" public-key)")
curl -fsS --retry 5 --retry-all-errors -X POST "$url" -H "x-novanet-server-key: $NOVANET_SERVER_KEY" -H 'content-type: application/json' --data "$body"
printf '\n'
