#!/usr/bin/env bash
set -euo pipefail
ENV=/etc/novanet/server.env
source "$ENV"
: "${NOVANET_WG_INTERFACE:=wg0}"
: "${NOVANET_WG_ADDRESS:=10.77.0.1/24}"
: "${NOVANET_WG_PORT:=51820}"
install -d -m 0700 /etc/wireguard
if [[ ! -s /etc/wireguard/${NOVANET_WG_INTERFACE}.key ]]; then umask 077; wg genkey > /etc/wireguard/${NOVANET_WG_INTERFACE}.key; fi
priv=$(cat /etc/wireguard/${NOVANET_WG_INTERFACE}.key)
pub=$(printf '%s' "$priv" | wg pubkey)
cat > /etc/wireguard/${NOVANET_WG_INTERFACE}.conf <<EOF
[Interface]
Address = ${NOVANET_WG_ADDRESS}
ListenPort = ${NOVANET_WG_PORT}
PrivateKey = ${priv}
SaveConfig = false
EOF
chmod 600 /etc/wireguard/${NOVANET_WG_INTERFACE}.conf
systemctl enable --now "wg-quick@${NOVANET_WG_INTERFACE}"
printf 'server_public_key=%s\n' "$pub"
printf 'server_address=%s\n' "${NOVANET_WG_ADDRESS%/*}"
