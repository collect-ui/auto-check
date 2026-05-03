const { chromium } = require('playwright');

(async () => {
  const host = process.env.HOST || 'http://192.168.232.130:8016';
  const url = host + '/collect-ui#/collect-ui/framework/tencent_key_apply';

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const consoleErrors = [];
  const pageErrors = [];
  const reqUrls = [];
  const respUrls = [];

  page.on('console', (msg) => {
    if (msg.type() === 'error') consoleErrors.push(msg.text());
  });
  page.on('pageerror', (err) => pageErrors.push(err.message));
  page.on('request', (req) => {
    if (req.url().includes('service=hrm.tencent_key_quota_sync')) reqUrls.push(req.url());
  });
  page.on('response', (resp) => {
    if (resp.url().includes('service=hrm.tencent_key_quota_sync')) respUrls.push(resp.url() + '|' + resp.status());
  });

  await context.request.post(host + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });

  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(2600);

  const card = page.locator('#local_key_panel .ant-card', { hasText: 'account-1' }).first();
  const syncBtn = card.getByRole('button', { name: /巡\s*检/ }).first();

  const loadingCount = async () => syncBtn.locator('.ant-btn-loading-icon').count();

  const beforeLoading = await loadingCount();
  await syncBtn.click();

  await page.waitForTimeout(300);
  const loading300ms = await loadingCount();

  await page.waitForTimeout(2500);
  const loading2800ms = await loadingCount();

  await page.waitForTimeout(7000);
  const loading9800ms = await loadingCount();

  await page.screenshot({ path: '/data/project/auto-check/test/tencent_key_apply/sync-loading-check.png', fullPage: true });

  console.log(JSON.stringify({
    host,
    quotaSyncRequestCount: reqUrls.length,
    quotaSyncResponseCount: respUrls.length,
    beforeLoading,
    loading300ms,
    loading2800ms,
    loading9800ms,
    consoleErrors,
    pageErrors,
    screenshot: '/data/project/auto-check/test/tencent_key_apply/sync-loading-check.png'
  }, null, 2));

  await browser.close();
})();
