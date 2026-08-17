#!/usr/bin/env bash
set -euo pipefail
source /etc/novanet/server.env
: "${NOVANET_CONTROL_URL:?set NOVANET_CONTROL_URL}"
: "${NOVANET_SERVER_KEY:?set NOVANET_SERVER_KEY}"
region=${1:-}
curl -fsS --retry 4 --retry-all-errors -X POST "$NOVANET_CONTROL_URL" -H "x-novanet-server-key: $NOVANET_SERVER_KEY" -H 'content-type: application/json' --data "{\"action\":\"servers\",\"region\":\"$region\"}"
