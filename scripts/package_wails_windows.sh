#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${1:-dist}"
BASE_DIR="$OUT_DIR/windows-win10-x64"
DESKTOP_DIR="$OUT_DIR/windows-wails-x64"
WAILS_DIR="desktop/wails"

log() {
  printf '[package_wails] %s\n' "$*"
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: command not found: $cmd" >&2
    exit 1
  fi
}

require_cmd bash
require_cmd rsync
require_cmd wails

if [[ ! -x scripts/package_windows.sh ]]; then
  echo "ERROR: missing scripts/package_windows.sh" >&2
  exit 1
fi

log "building backend runtime package"
bash scripts/package_windows.sh --target win10 --out "$OUT_DIR"

log "building Wails desktop shell"
(
  cd "$WAILS_DIR"
  wails build -platform windows/amd64 -webview2 download
)

rm -rf "$DESKTOP_DIR"
mkdir -p "$DESKTOP_DIR"

log "copying runtime files"
rsync -a "$BASE_DIR"/ "$DESKTOP_DIR"/

if [[ -f "$WAILS_DIR/build/bin/AutoCheck.exe" ]]; then
  cp -f "$WAILS_DIR/build/bin/AutoCheck.exe" "$DESKTOP_DIR/AutoCheck.exe"
else
  echo "ERROR: missing Wails output: $WAILS_DIR/build/bin/AutoCheck.exe" >&2
  exit 1
fi

log "desktop package ready: $DESKTOP_DIR"
