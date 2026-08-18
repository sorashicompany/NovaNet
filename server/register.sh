#!/usr/bin/env bash
set -euo pipefail
ENV=/etc/novanet/server.env
[[ -r "$ENV" ]] || { echo "missing $ENV" >&2; exit 1; }
source "$ENV"
: "${NOVANET_CONTROL_URL:?set NOVANET_CONTROL_URL}"
: "${NOVANET_SERVER_KEY:?set NOVANET_SERVER_KEY}"
: "${NOVANET_SERVER_NAME:?set NOVANET_SERVER_NAME}"
: "${NOVANET_ENDPOINT:?set NOVANET_ENDPOINT}"
curl -fsS --retry 5 --retry-all-errors -X POST "$NOVANET_CONTROL_URL" -H "x-novanet-server-key: $NOVANET_SERVER_KEY" -H 'content-type: application/json' --data "$(printf '%s' '{"action":"register"}' )" >/dev/null || true
