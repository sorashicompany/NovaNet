#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
need_cmd(){ command -v "$1" >/dev/null 2>&1 || { echo "Missing $1. Install with: pkg install $2" >&2; exit 1; }; }
need_cmd go golang
need_cmd python python
need_cmd curl curl
test -d "${PREFIX:-}" || { echo 'This installer is intended for Termux.' >&2; exit 1; }
[ -d "$ROOT/vendor/wdtt-go" ] || "$ROOT/scripts/bootstrap-upstream.sh"
mkdir -p "$PREFIX/bin" "$HOME/.config/novanet" "$HOME/.cache/novanet"
install -m 0755 "$ROOT/scripts/novanet" "$PREFIX/bin/novanet"
install -m 0755 "$ROOT/scripts/novanet-watchdog" "$PREFIX/bin/novanet-watchdog"
cd "$ROOT/vendor/wdtt-go"
go mod download
go build -trimpath -buildvcs=false -ldflags='-s -w' -o "$PREFIX/bin/novanet-engine.tmp" .
mv -f "$PREFIX/bin/novanet-engine.tmp" "$PREFIX/bin/novanet-engine"
chmod 0755 "$PREFIX/bin/novanet-engine"
printf 'upstream_commit=%s\ninstalled_at=%s\n' "$(cat UPSTREAM_COMMIT 2>/dev/null || echo unknown)" "$(date -Iseconds)" > "$HOME/.config/novanet/install.info"
echo 'NovaNet Termux installed.'
echo 'Run: novanet doctor'
echo 'Run: novanet check --profile NAME'
echo 'Run: novanet connect --profile NAME --mode socks --listen 127.0.0.1:1080'
