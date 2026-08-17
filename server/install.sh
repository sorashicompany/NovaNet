#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run as root' >&2; exit 1; }
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates curl iproute2 nftables wireguard-tools
install -d -m 0755 /opt/novanet /etc/novanet
if command -v novanet-engine >/dev/null 2>&1; then cp "$(command -v novanet-engine)" /opt/novanet/novanet-engine; fi
if [[ ! -x /opt/novanet/novanet-engine ]]; then
  echo 'novanet-engine is required. Build/download the upstream-compatible engine and place it at /opt/novanet/novanet-engine.' >&2
  exit 1
fi
install -m 0755 /opt/novanet/novanet-engine /usr/local/bin/novanet-engine
if [[ ! -f /etc/novanet/server.env ]]; then install -m 0600 server/novanet.env.example /etc/novanet/server.env; fi
install -m 0755 server/novanet-server.sh /usr/local/bin/novanet-server
install -m 0644 server/systemd/novanet-server.service /etc/systemd/system/novanet-server.service
sysctl -w net.ipv4.ip_forward=1
cat >/etc/sysctl.d/99-novanet.conf <<'EOF'
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
EOF
sysctl --system >/dev/null
systemctl daemon-reload
systemctl enable --now novanet-server
printf '\nNovaNet server installed. Edit /etc/novanet/server.env and restart: systemctl restart novanet-server\n'
