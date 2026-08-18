#!/usr/bin/env bash
set -euo pipefail
# Run the existing novanet CLI through a bounded server list. Each endpoint gets a health/start attempt before moving on.
PROFILE=${1:?profile required}
shift || true
MAX=${NOVANET_FAILOVER_ATTEMPTS:-3}
servers_file=${NOVANET_SERVERS_FILE:-$HOME/.config/novanet/servers}
[[ -r "$servers_file" ]] || { echo "No server list: $servers_file" >&2; exit 1; }
attempt=0
while IFS= read -r endpoint; do
  [[ -z "$endpoint" || "$endpoint" == \#* ]] && continue
  attempt=$((attempt+1)); echo "[novanet] trying $endpoint ($attempt/$MAX)" >&2
  if novanet connect --profile "$PROFILE" --server "$endpoint" "$@"; then exit 0; fi
  (( attempt >= MAX )) && break
  sleep $((2 ** (attempt-1)))
done < "$servers_file"
echo '[novanet] all failover servers failed' >&2
exit 1
