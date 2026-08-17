# NovaNet Termux

Termux-клиент NovaNet для Linux/Android, совместимый с протоколом WDTT/qWDTT и рассчитанный на работу без Android `VpnService`.

## Что уже заложено

- CLI для Termux: `vpn`, `socks`, `rawtun`-режимы.
- Совместимый формат `wdtt://` / `qwdtt://`.
- Профили и подписки через Supabase.
- Edge API в Supabase для выдачи профилей без service-role ключа на клиенте.
- Cloudflare Worker как edge-cache/API gateway перед Supabase.
- Bootstrap, который подтягивает GPLv3 Go-клиент WDTT из закреплённого upstream commit.
- Системный WireGuard остаётся опциональным: Termux не требует Android `VpnService`.

## Архитектура

```text
Termux
  │
  ├── novanet CLI
  │     └── WDTT Go engine
  │            └── VK TURN → VPS
  │
  └── HTTPS subscription
          │
          ▼
     Cloudflare Worker
          │
          ▼
     Supabase Edge Function
          │
          ▼
       Postgres/RLS
```

Оригинальный Android-клиент реализует WireGuard + TURN/VK транспорт, профили, SOCKS/raw-tun, captcha/VK account режимы и серверный WDTT. NovaNet переносит именно транспортный слой в Termux, а Android UI заменяет на CLI. Это сохраняет совместимость с `wdtt-server`.

## Установка в Termux

```bash
pkg update
pkg install -y git curl wget golang wireguard-tools

git clone https://github.com/sorashicompany/NovaNet.git
cd NovaNet
./scripts/bootstrap-upstream.sh
./scripts/install-termux.sh
```

После bootstrap бинарь `novanet` будет собран из upstream WDTT Go engine с Termux-обвязкой.

## Конфигурация

```bash
export NOVANET_SUBSCRIPTION_URL=https://YOUR-WORKER.workers.dev/subscription
novanet profile import 'wdtt://SERVER:56000:56001:9000:PASSWORD:VK_HASH'
novanet profile list
novanet ping --profile NAME
novanet connect --profile NAME --mode socks --listen 127.0.0.1:1080
```

Для full-tunnel на Android/Termux потребуется root и TUN/WireGuard permissions. В unrooted Termux используйте SOCKS5 режим.

## Supabase

Используется существующий проект `Nexora` как backend. NovaNet не должен хранить service-role/secret key на устройстве. Публичный клиент получает только publishable key или обращается к Cloudflare Worker.

Схема NovaNet добавляется отдельной migration и не меняет существующие таблицы музыкальной/социальной части проекта.

## Cloudflare

Worker выполняет edge-кеширование подписки и передаёт запрос в Supabase Edge Function. Секреты задаются через Wrangler secrets, а не коммитятся в Git.

## Лицензия

GPL-3.0. NovaNet использует совместимый с GPLv3 upstream WDTT engine; производные изменения должны сохранять требования GPLv3.

## Upstream

Reference: `SpaceNeuroX/proxy-turn-vk-android`, commit `854a72fe1b808c014711342e7fccf3613f16b6ff`.
