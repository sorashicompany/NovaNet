#!/usr/bin/env bash
set -euo pipefail
source /etc/novanet/server.env
name=${1:?client name required}
subnet=${NOVANET_WG_CLIENT_PREFIX:-10.77.0}
state=/etc/novanet/clients
install -d -m 0700 "$state"
file="$state/$name"
[[ ! -e "$file" ]] || { echo 'client already exists' >&2; exit 1; }
umask 077
priv=$(wg genkey); pub=$(printf '%s' "$priv" | wg pubkey)
last=$(ls "$state" 2>/dev/null | wc -l); octet=$((last+2))
server_pub=$(wg show "${NOVANET_WG_INTERFACE:-wg0}" public-key)
server_ip=${NOVANET_WG_SERVER_IP:-10.77.0.1}
cat >"$file" <<EOF
CLIENT_PRIVATE_KEY=$priv
CLIENT_PUBLIC_KEY=$pub
CLIENT_ADDRESS=${subnet}.${octet}/32
SERVER_PUBLIC_KEY=$server_pub
SERVER_ADDRESS=$server_ip
EOF
wg set "${NOVANET_WG_INTERFACE:-wg0}" peer "$pub" allowed-ips "${subnet}.${octet}/32"
cat >"$file.conf" <<EOF
[Interface]
PrivateKey = $priv
Address = ${subnet}.${octet}/32

[Peer]
PublicKey = $server_pub
AllowedIPs = 0.0.0.0/0
Endpoint = ${NOVANET_ENDPOINT:?set NOVANET_ENDPOINT}
PersistentKeepalive = 25
EOF
chmod 600 "$file" "$file.conf"
cat "$file.conf"
