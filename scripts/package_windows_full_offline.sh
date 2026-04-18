#!/usr/bin/env bash
set -euo pipefail

TARGET="win7"
OUT_DIR="dist"
GO120_BIN=""
GO_BIN="${GO_BIN:-go}"
PYTHON_RUNTIME_DIR=""
TO_TEXT_DIR="/data/project/to_text"
MODEL_DIR=""
SITE_PACKAGES_DIR=""
WITH_TAR="false"

usage() {
  cat <<'USAGE'
Usage:
  scripts/package_windows_full_offline.sh \
    --target win7|win10 \
    --python-runtime /abs/path/windows-python-runtime \
    [--site-packages /abs/path/site-packages] \
    [--to-text-dir /abs/path/to_text] \
    [--model-dir /abs/path/model-dir] \
    [--go120 /path/to/go1.20] \
    [--out dist] \
    [--with-tar]

Notes:
  - This script builds a FULL offline package for new Windows machines.
  - It always includes:
      1) Go server package (main.exe + collect/conf/frontend/etc.)
      2) Python runtime directory
      3) to_text app scripts
      4) model directory
  - For win7 target, --go120 is required.
  - --python-runtime should contain python.exe.
  - --site-packages is optional. If provided, it will be copied into:
      ai/python/Lib/site-packages
  - --model-dir default: <to-text-dir>/models

Examples:
  scripts/package_windows_full_offline.sh \
    --target win7 \
    --go120 /opt/go1.20.14/bin/go \
    --python-runtime /data/runtime/python-3.10.11-embed-amd64 \
    --site-packages /data/runtime/python-site-packages \
    --to-text-dir /data/project/to_text \
    --model-dir /data/models/faster-whisper-small \
    --out dist \
    --with-tar
USAGE
}

log() {
  printf '[package_windows_full] %s\n' "$*"
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
    echo "ERROR: --go120 is required when target is win7" >&2
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

copy_filtered_to_text() {
  local src="$1"
  local dest="$2"
  mkdir -p "$dest"

  cp -a "$src/transcribe_http_to_text.py" "$dest/"
  [[ -f "$src/README.md" ]] && cp -a "$src/README.md" "$dest/"

  if [[ -d "$src/models" ]]; then
    cp -a "$src/models" "$dest/"
  fi
}

write_start_all_bat() {
  local dest="$1"
  cat > "$dest/start_all.bat" <<'BAT'
@echo off
setlocal
cd /d %~dp0

set APP_HOME=%cd%
set AI_HOME=%APP_HOME%\ai
set PY_HOME=%AI_HOME%\python
set APP_SCRIPT=%AI_HOME%\app\transcribe_http_to_text.py
set PID_FILE=%AI_HOME%\transcribe_http_to_text.pid
set LOG_FILE=%AI_HOME%\transcribe_http_to_text.log

set NO_PROXY=127.0.0.1,localhost
set no_proxy=127.0.0.1,localhost
set DISABLE_MODEL_SOURCE_CHECK=True
set PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK=True
set PYTHONUTF8=1

if not exist "%PY_HOME%\python.exe" (
  echo [ERROR] python runtime missing: %PY_HOME%\python.exe
  pause
  exit /b 1
)

if not exist "%APP_SCRIPT%" (
  echo [ERROR] transcribe script missing: %APP_SCRIPT%
  pause
  exit /b 1
)

echo Starting local transcribe service on 127.0.0.1:8014 ...
"%PY_HOME%\python.exe" "%APP_SCRIPT%" start --host 0.0.0.0 --port 8014 --model small --model-dir "%AI_HOME%\app" --device cpu --compute-type int8 --language zh --image-ocr-provider pytesseract --pid-file "%PID_FILE%" --log-file "%LOG_FILE%"

echo Waiting transcribe service warmup...
timeout /t 2 /nobreak >nul
"%PY_HOME%\python.exe" "%APP_SCRIPT%" status --pid-file "%PID_FILE%"

echo Starting auto-check server...
main.exe
BAT
}

write_stop_all_bat() {
  local dest="$1"
  cat > "$dest/stop_all.bat" <<'BAT'
@echo off
setlocal
cd /d %~dp0

set APP_HOME=%cd%
set AI_HOME=%APP_HOME%\ai
set PY_HOME=%AI_HOME%\python
set APP_SCRIPT=%AI_HOME%\app\transcribe_http_to_text.py
set PID_FILE=%AI_HOME%\transcribe_http_to_text.pid

if exist "%PY_HOME%\python.exe" (
  if exist "%APP_SCRIPT%" (
    "%PY_HOME%\python.exe" "%APP_SCRIPT%" stop --pid-file "%PID_FILE%"
  )
)

echo Done.
pause
BAT
}

write_full_readme() {
  local dest="$1"
  cat > "$dest/README_FULL_OFFLINE.txt" <<'TXT'
Full Offline Package
====================

This directory is built for fresh Windows machines without preinstalled Python.

Start order:
1) Run start_all.bat
   - starts local transcribe service on 127.0.0.1:8014
   - starts main.exe (auto-check)

Stop transcribe service:
- run stop_all.bat

Layout:
- main.exe                  Go server
- conf/collect/frontend/... runtime assets
- ai/python/               embedded Python runtime (must include python.exe)
- ai/app/                  transcribe_http_to_text.py + models
- ai/transcribe_http_to_text.log
- ai/transcribe_http_to_text.pid

Troubleshooting:
- If transcribe service fails, check ai/transcribe_http_to_text.log
- Ensure ai/app/models exists and contains model files
- Ensure ai/python/Lib/site-packages contains required packages:
  faster_whisper, ctranslate2, av, numpy, etc.
TXT
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
    --python-runtime)
      PYTHON_RUNTIME_DIR="${2:-}"
      shift 2
      ;;
    --to-text-dir)
      TO_TEXT_DIR="${2:-}"
      shift 2
      ;;
    --model-dir)
      MODEL_DIR="${2:-}"
      shift 2
      ;;
    --site-packages)
      SITE_PACKAGES_DIR="${2:-}"
      shift 2
      ;;
    --with-tar)
      WITH_TAR="true"
      shift
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
  win10|win7)
    ;;
  *)
    echo "ERROR: --target must be one of win10|win7" >&2
    exit 1
    ;;
esac

if [[ -z "$PYTHON_RUNTIME_DIR" ]]; then
  echo "ERROR: --python-runtime is required" >&2
  exit 1
fi

if [[ ! -d "$PYTHON_RUNTIME_DIR" ]]; then
  echo "ERROR: python runtime dir not found: $PYTHON_RUNTIME_DIR" >&2
  exit 1
fi

if [[ ! -f "$PYTHON_RUNTIME_DIR/python.exe" ]]; then
  echo "ERROR: python runtime must contain python.exe: $PYTHON_RUNTIME_DIR" >&2
  exit 1
fi

if [[ ! -d "$TO_TEXT_DIR" ]]; then
  echo "ERROR: to_text dir not found: $TO_TEXT_DIR" >&2
  exit 1
fi

if [[ -z "$MODEL_DIR" ]]; then
  MODEL_DIR="$TO_TEXT_DIR/models"
fi

if [[ ! -d "$MODEL_DIR" ]]; then
  echo "ERROR: model dir not found: $MODEL_DIR" >&2
  exit 1
fi

require_cmd "$GO_BIN"
mkdir -p "$OUT_DIR"

if [[ "$TARGET" == "win7" ]]; then
  validate_go120
fi

log "building base windows package first"
if [[ "$TARGET" == "win7" ]]; then
  bash scripts/package_windows.sh --target win7 --go120 "$GO120_BIN" --out "$OUT_DIR"
else
  bash scripts/package_windows.sh --target win10 --out "$OUT_DIR"
fi

base_dir="$OUT_DIR/windows-${TARGET}-x64"
full_dir="$OUT_DIR/windows-${TARGET}-x64-full"
rm -rf "$full_dir"
cp -a "$base_dir" "$full_dir"

log "copying python runtime"
mkdir -p "$full_dir/ai"
cp -a "$PYTHON_RUNTIME_DIR" "$full_dir/ai/python"

if [[ -n "$SITE_PACKAGES_DIR" ]]; then
  if [[ ! -d "$SITE_PACKAGES_DIR" ]]; then
    echo "ERROR: --site-packages dir not found: $SITE_PACKAGES_DIR" >&2
    exit 1
  fi
  log "copying site-packages"
  mkdir -p "$full_dir/ai/python/Lib"
  rm -rf "$full_dir/ai/python/Lib/site-packages"
  cp -a "$SITE_PACKAGES_DIR" "$full_dir/ai/python/Lib/site-packages"
fi

log "copying transcribe app and models"
copy_filtered_to_text "$TO_TEXT_DIR" "$full_dir/ai/app"
rm -rf "$full_dir/ai/app/models"
cp -a "$MODEL_DIR" "$full_dir/ai/app/models"

write_start_all_bat "$full_dir"
write_stop_all_bat "$full_dir"
write_full_readme "$full_dir"

if [[ "$WITH_TAR" == "true" ]]; then
  tar_name="$OUT_DIR/auto-check-${TARGET}-x64-full-$(date +%Y%m%d).tar.gz"
  log "creating tar: $tar_name"
  tar -czf "$tar_name" -C "$OUT_DIR" "windows-${TARGET}-x64-full"
  sha256sum "$tar_name" | tee "$tar_name.sha256"
fi

log "done: $full_dir"
du -sh "$full_dir" || true
