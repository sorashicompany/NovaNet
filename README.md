# NovaNet — установка

## Termux

```bash
pkg update -y
pkg install -y git curl wget golang python wireguard-tools

git clone https://github.com/sorashicompany/NovaNet.git
cd NovaNet
bash scripts/bootstrap-upstream.sh
bash scripts/install-termux.sh
```

Проверка:

```bash
novanet doctor
novanet profile list
```

Подключение через SOCKS5:

```bash
novanet connect --profile NAME --mode socks --listen 127.0.0.1:1080
```

Для TUN/WireGuard на Android требуются соответствующие права. Без root используйте SOCKS5.

## VPS

Ubuntu/Debian с root-доступом и открытыми TCP/UDP портами.

```bash
apt update
apt install -y git

git clone https://github.com/sorashicompany/NovaNet.git
cd NovaNet
bash server/install.sh
```

Настройте параметры:

```bash
chmod 600 /etc/novanet/server.env
nano /etc/novanet/server.env
systemctl restart novanet-server
```

Проверка:

```bash
systemctl status novanet-server
curl http://127.0.0.1:8787/health
```

Heartbeat:

```bash
install -m 0755 server/heartbeat.sh /usr/local/bin/novanet-heartbeat
install -m 0644 server/systemd/novanet-heartbeat.service /etc/systemd/system/
install -m 0644 server/systemd/novanet-heartbeat.timer /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now novanet-heartbeat.timer
```

## Cloudflare / Supabase

Создайте Edge Function `novanet-server-control`, задайте секрет `NOVANET_CONTROL_SECRET`, а URL функции укажите в `/etc/novanet/server.env` как `NOVANET_CONTROL_URL`.

Service-role ключ храните только в Supabase Edge Function. Не помещайте его в Termux или VPS-конфигурацию.
