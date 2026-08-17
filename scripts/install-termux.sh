#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

command -v go >/dev/null || { echo 'Install Go first: pkg install golang'; exit 1; }
[ -d "$ROOT/vendor/wdtt-go" ] || "$ROOT/scripts/bootstrap-upstream.sh"

mkdir -p "$PREFIX/bin" "$HOME/.config/novanet"
cp "$ROOT/scripts/novanet" "$PREFIX/bin/novanet"
chmod +x "$PREFIX/bin/novanet"

cd "$ROOT/vendor/wdtt-go"
go build -trimpath -o "$PREFIX/bin/novanet-engine" .

echo 'Installed novanet and novanet-engine.'
echo 'For SOCKS mode: novanet connect --profile NAME --mode socks --listen 127.0.0.1:1080'
