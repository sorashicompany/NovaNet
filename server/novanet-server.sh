#!/usr/bin/env bash
set -euo pipefail
ENV_FILE=${NOVANET_ENV_FILE:-/etc/novanet/server.env}
[[ -r "$ENV_FILE" ]] || { echo "Missing $ENV_FILE" >&2; exit 1; }
# shellcheck disable=SC1090
source "$ENV_FILE"
ENGINE=${NOVANET_ENGINE:-/usr/local/bin/novanet-engine}
MODE=${NOVANET_MODE:-socks}
LISTEN=${NOVANET_LISTEN:-0.0.0.0:9000}
SOCKS=${NOVANET_SOCKS:-127.0.0.1:1080}
HEALTH=${NOVANET_HEALTH_LISTEN:-127.0.0.1:8787}
LOG=${NOVANET_LOG:-/var/log/novanet-server.log}
mkdir -p "$(dirname "$LOG")"
exec 9>/run/novanet-server.lock
flock -n 9 || exit 0
health(){
  local bind=${HEALTH%:*} port=${HEALTH##*:}
  while true; do
    { printf 'HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nConnection: close\r\n\r\n{"status":"ok","mode":"%s"}\n' "$MODE"; } | nc -l -s "$bind" -p "$port" -q 1 >/dev/null 2>&1 || true
  done
}
command -v "$ENGINE" >/dev/null 2>&1 || { echo "engine not found: $ENGINE" >&2; exit 1; }
health &
health_pid=$!
trap 'kill "$health_pid" 2>/dev/null || true' EXIT
args=(-mode "$MODE" -peer "$NOVANET_PEER" -vk "$NOVANET_VK_HASHES" -password "$NOVANET_PASSWORD" -n "${NOVANET_WORKERS:-9}")
if [[ "$MODE" == socks ]]; then args+=(-socks "$SOCKS"); else args+=(-listen "$LISTEN"); fi
if [[ "${NOVANET_TURN_TCP:-0}" == 1 ]]; then args+=(-turn-tcp); fi
# Restart the engine after an unexpected exit; systemd also supervises this process.
while true; do
  date -Is >>"$LOG"
  "$ENGINE" "${args[@]}" >>"$LOG" 2>&1 || true
  [[ "${NOVANET_AUTO_RESTART:-1}" == 1 ]] || break
  sleep 3
done
