#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM_COMMIT="854a72fe1b808c014711342e7fccf3613f16b6ff"
UPSTREAM="https://github.com/SpaceNeuroX/proxy-turn-vk-android/archive/${UPSTREAM_COMMIT}.tar.gz"
CACHE="$ROOT/.cache/upstream"
SRC="$ROOT/.cache/upstream/src"

mkdir -p "$CACHE"
if [ ! -d "$SRC/go_client" ]; then
  rm -rf "$SRC" "$CACHE/upstream.tar.gz"
  curl -fL "$UPSTREAM" -o "$CACHE/upstream.tar.gz"
  mkdir -p "$SRC"
  tar -xzf "$CACHE/upstream.tar.gz" -C "$SRC" --strip-components=1
fi

rm -rf "$ROOT/vendor/wdtt-go"
mkdir -p "$ROOT/vendor"
cp -a "$SRC/go_client" "$ROOT/vendor/wdtt-go"
cp "$SRC/go_client/go.mod" "$ROOT/vendor/wdtt-go/go.mod"
[ -f "$SRC/go_client/go.sum" ] && cp "$SRC/go_client/go.sum" "$ROOT/vendor/wdtt-go/go.sum" || true

printf '%s\n' "$UPSTREAM_COMMIT" > "$ROOT/vendor/wdtt-go/UPSTREAM_COMMIT"
echo "WDTT Go engine vendored at $ROOT/vendor/wdtt-go"
