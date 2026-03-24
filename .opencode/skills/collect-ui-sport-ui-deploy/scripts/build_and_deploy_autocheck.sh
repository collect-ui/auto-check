#!/usr/bin/env bash
set -euo pipefail

COLLECT_UI_DIR="/data/project/collect-ui"
SPORT_UI_DIR="/data/project/sport-ui"
DEPLOY_DIR="/data/project/auto-check/frontend/collect-ui"
VERIFY="${VERIFY:-0}"
VERIFY_URL="${VERIFY_URL:-http://127.0.0.1:8015/collect-ui}"

echo "[1/5] Build collect-ui"
cd "$COLLECT_UI_DIR"
npm run build

echo "[2/5] Build sport-ui (deploy config)"
cd "$SPORT_UI_DIR"
NODE_OPTIONS=--max_old_space_size=8192 npx vite build --config vite.config.deploy.js

echo "[3/5] Deploy build to auto-check frontend"
mkdir -p "$DEPLOY_DIR"
rm -rf "$DEPLOY_DIR"/*
cp -a "$SPORT_UI_DIR"/build/. "$DEPLOY_DIR"/

echo "[4/5] Verify gzip artifacts"
GZ_COUNT=$(find "$DEPLOY_DIR" -type f -name '*.gz' | wc -l)
echo "gzip files: $GZ_COUNT"
if [ "$GZ_COUNT" -eq 0 ]; then
  echo "ERROR: no gzip files found in deployed artifacts" >&2
  exit 1
fi

if [ "$VERIFY" = "1" ]; then
  echo "[5/5] Optional browser verify: $VERIFY_URL"
  cd "$SPORT_UI_DIR"
  VERIFY_URL="$VERIFY_URL" node - <<'NODE'
const { chromium } = require('playwright');

(async () => {
  const url = process.env.VERIFY_URL;
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  const consoleErrors = [];
  const pageErrors = [];
  const requestFailed = [];

  page.on('console', (msg) => {
    if (msg.type() === 'error') consoleErrors.push(msg.text());
  });
  page.on('pageerror', (err) => pageErrors.push(String(err)));
  page.on('requestfailed', (req) => {
    requestFailed.push(`${req.method()} ${req.url()} => ${req.failure()?.errorText || 'failed'}`);
  });

  let status = 'no_response';
  try {
    const resp = await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 30000 });
    status = resp ? String(resp.status()) : 'no_response';
  } catch (e) {
    pageErrors.push(`goto error: ${String(e)}`);
  }

  await page.waitForTimeout(5000);
  await browser.close();

  console.log(`verify url: ${url}`);
  console.log(`verify status: ${status}`);
  console.log(`verify console_error_count: ${consoleErrors.length}`);
  console.log(`verify pageerror_count: ${pageErrors.length}`);
  console.log(`verify requestfailed_count: ${requestFailed.length}`);

  if (consoleErrors.length || pageErrors.length || requestFailed.length) {
    if (consoleErrors.length) {
      console.log('verify console_errors:');
      consoleErrors.forEach((x, i) => console.log(`${i + 1}. ${x}`));
    }
    if (pageErrors.length) {
      console.log('verify page_errors:');
      pageErrors.forEach((x, i) => console.log(`${i + 1}. ${x}`));
    }
    if (requestFailed.length) {
      console.log('verify request_failed:');
      requestFailed.forEach((x, i) => console.log(`${i + 1}. ${x}`));
    }
    process.exit(1);
  }
})();
NODE
else
  echo "[5/5] Skip browser verify (set VERIFY=1 to enable)"
fi

echo "done: deployed to $DEPLOY_DIR"
