#!/usr/bin/env bash
set -euo pipefail

TARGET="all"
OUT_DIR="dist"
GO120_BIN=""
GO_BIN="${GO_BIN:-go}"

usage() {
  cat <<'USAGE'
Usage:
  scripts/package_windows.sh [--target win10|win7|all] [--go120 /path/to/go] [--out dist]

Options:
  --target   Build target. Default: all
  --go120    Go 1.20 binary path/command, required for win7/all target
  --out      Output root directory. Default: dist
  -h, --help Show help

Examples:
  scripts/package_windows.sh --target win10 --out dist
  scripts/package_windows.sh --target win7 --go120 /opt/go1.20.14/bin/go --out dist
  scripts/package_windows.sh --target all --go120 go1.20.14 --out dist
USAGE
}

log() {
  printf '[package_windows] %s\n' "$*"
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: command not found: $cmd" >&2
    exit 1
  fi
}

validate_go120() {
  if [[ -z "$GO120_BIN" ]]; then
    echo "ERROR: --go120 is required when target is win7 or all" >&2
    exit 1
  fi

  if ! command -v "$GO120_BIN" >/dev/null 2>&1; then
    echo "ERROR: --go120 not executable/available: $GO120_BIN" >&2
    exit 1
  fi

  local ver
  ver="$($GO120_BIN version 2>/dev/null || true)"
  if [[ "$ver" != *"go1.20"* ]]; then
    echo "ERROR: --go120 must be Go 1.20.x, got: $ver" >&2
    exit 1
  fi
}

copy_runtime_assets() {
  local dest="$1"
  local dirs=(conf collect frontend database static file_data)
  for d in "${dirs[@]}"; do
    if [[ -d "$d" ]]; then
      cp -a "$d" "$dest/"
    else
      log "skip missing runtime dir: $d"
    fi
  done
}

write_start_bat() {
  local dest="$1"
  cat > "$dest/start.bat" <<'BAT'
@echo off
setlocal
cd /d %~dp0
echo Starting auto-check server...
main.exe
pause
BAT
}

build_package() {
  local label="$1"
  local go_cmd="$2"
  local dest="$OUT_DIR/windows-${label}-x64"
  local extra_build_args=()
  local modfile=""

  rm -rf "$dest"
  mkdir -p "$dest"

  if [[ "$label" == "win7" ]]; then
    modfile="$OUT_DIR/.go-win7.mod"
    cp -f go.mod "$modfile"
    sed -i 's/^go .*/go 1.20/' "$modfile"
    # Keep Win7 build isolated: pin modules that pull Go 1.21+ stdlib APIs.
    cat >> "$modfile" <<'MOD'

replace github.com/pelletier/go-toml/v2 => github.com/pelletier/go-toml/v2 v2.2.0
replace google.golang.org/protobuf => google.golang.org/protobuf v1.33.0
replace github.com/gorilla/sessions => github.com/gorilla/sessions v1.2.2
MOD
    extra_build_args=(-modfile="$modfile")
    GOSUMDB="${WIN7_GOSUMDB:-sum.golang.org}" "$go_cmd" mod download -modfile="$modfile" all
  fi

  log "building windows-${label}-x64 with: $go_cmd"
  GOOS=windows GOARCH=amd64 CGO_ENABLED=0 "$go_cmd" build "${extra_build_args[@]}" -ldflags='-s -w' -o "$dest/main.exe" -v main.go

  copy_runtime_assets "$dest"
  write_start_bat "$dest"

  if command -v file >/dev/null 2>&1; then
    file "$dest/main.exe" || true
  fi

  log "done: $dest"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --go120)
      GO120_BIN="${2:-}"
      shift 2
      ;;
    --out)
      OUT_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

case "$TARGET" in
  win10|win7|all)
    ;;
  *)
    echo "ERROR: --target must be one of win10|win7|all" >&2
    exit 1
    ;;
esac

require_cmd "$GO_BIN"
mkdir -p "$OUT_DIR"

if [[ "$TARGET" == "win10" || "$TARGET" == "all" ]]; then
  build_package "win10" "$GO_BIN"
fi

if [[ "$TARGET" == "win7" || "$TARGET" == "all" ]]; then
  validate_go120
  build_package "win7" "$GO120_BIN"
fi

log "all requested targets finished"
