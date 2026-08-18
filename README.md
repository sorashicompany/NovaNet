# NovaNet — Termux

```bash
pkg update -y
pkg install -y git golang python curl

git clone https://github.com/sorashicompany/NovaNet.git
cd NovaNet
bash scripts/bootstrap-upstream.sh
bash scripts/install-termux.sh
```

Запуск — просто вставь ссылку:

```bash
novanet 'wdtt://IP:DTLS_PORT:WG_PORT:LOCAL_PORT:PASSWORD:VK_HASH'
```

По умолчанию SOCKS5: `127.0.0.1:1080`.

Другой режим:

```bash
novanet 'wdtt://...' --mode vpn
```

Для qWDTT также:

```bash
novanet 'qwdtt://config?...'
```
