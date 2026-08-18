#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run as root' >&2; exit 1; }
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates curl iproute2 nftables wireguard-tools netcat-openbsd
install -d -m 0755 /opt/novanet /etc/novanet
if command -v novanet-engine >/dev/null 2>&1; then install -m 0755 "$(command -v novanet-engine)" /opt/novanet/novanet-engine; fi
[[ -x /opt/novanet/novanet-engine ]] || { echo 'novanet-engine is required at /opt/novanet/novanet-engine' >&2; exit 1; }
install -m 0755 /opt/novanet/novanet-engine /usr/local/bin/novanet-engine
[[ -f /etc/novanet/server.env ]] || install -m 0600 server/novanet.env.example /etc/novanet/server.env
install -m 0755 server/novanet-server.sh /usr/local/bin/novanet-server
install -m 0755 server/wireguard-provision.sh /usr/local/bin/novanet-wireguard
install -m 0755 server/provision-client.sh /usr/local/bin/novanet-client
install -m 0755 server/register-server.sh /usr/local/bin/novanet-register
install -m 0755 server/heartbeat.sh /usr/local/bin/novanet-heartbeat
install -m 0644 server/systemd/novanet-server.service /etc/systemd/system/novanet-server.service
install -m 0644 server/systemd/novanet-heartbeat.service /etc/systemd/system/novanet-heartbeat.service
install -m 0644 server/systemd/novanet-heartbeat.timer /etc/systemd/system/novanet-heartbeat.timer
sysctl -w net.ipv4.ip_forward=1 >/dev/null
printf 'net.ipv4.ip_forward=1\nnet.ipv6.conf.all.forwarding=1\n' >/etc/sysctl.d/99-novanet.conf
sysctl --system >/dev/null
/usr/local/bin/novanet-wireguard
systemctl daemon-reload
systemctl enable --now novanet-server novanet-heartbeat.timer
printf 'NovaNet installed. Configure /etc/novanet/server.env, then run: novanet-register\n'
