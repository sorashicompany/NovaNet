#!/usr/bin/env bash
set -euo pipefail
source /etc/novanet/server.env
: "${NOVANET_CONTROL_URL:?set NOVANET_CONTROL_URL}"
: "${NOVANET_SERVER_KEY:?set NOVANET_SERVER_KEY}"
load=$(awk '{print int($1)}' /proc/loadavg 2>/dev/null || echo 0)
mem=$(awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{if(t) print int((t-a)*100/t); else print 0}' /proc/meminfo)
clients=0
traffic=0
curl -fsS --retry 3 --retry-all-errors -X POST "$NOVANET_CONTROL_URL" -H "x-novanet-server-key: $NOVANET_SERVER_KEY" -H 'content-type: application/json' --data "{\"action\":\"heartbeat\",\"server_key\":\"$NOVANET_SERVER_KEY\",\"load\":$load,\"clients\":$clients,\"traffic_bytes\":$traffic,\"healthy\":true,\"metadata\":{\"memory_percent\":$mem}}" >/dev/null
