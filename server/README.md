# NovaNet Server

Production-oriented VPS server bootstrap for NovaNet. The server terminates the NovaNet/WDTT transport using the upstream-compatible engine, optionally forwards traffic through WireGuard, and exposes health/config metadata for the control plane.

## Requirements

- Ubuntu/Debian VPS
- public IPv4 (IPv6 optional)
- root access
- UDP/TCP access to the configured listener

## Install

```bash
sudo bash server/install.sh
```

The installer creates `/etc/novanet/server.env`, installs the server binary, configures IP forwarding/NAT, and installs a systemd unit.

## Configuration

Copy `server/novanet.env.example` to `/etc/novanet/server.env` and set at minimum:

- `NOVANET_PEER`
- `NOVANET_PASSWORD`
- `NOVANET_VK_HASHES`
- `NOVANET_LISTEN`
- `NOVANET_MODE`

Secrets are intentionally kept on the VPS and are never required in the Cloudflare Worker.

## Health

```bash
systemctl status novanet-server
curl http://127.0.0.1:8787/health
```

The health endpoint does not expose credentials.
