const { chromium } = require('playwright');

(async () => {
  const host = 'http://127.0.0.1:8016';
  const url = host + '/collect-ui#/collect-ui/framework/tencent_key_apply';

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const consoleErrors = [];
  const pageErrors = [];
  const syncResponses = [];

  page.on('console', (msg) => { if (msg.type() === 'error') consoleErrors.push(msg.text()); });
  page.on('pageerror', (err) => pageErrors.push(err.message));
  page.on('response', async (resp) => {
    const u = resp.url();
    if (u.indexOf('service=hrm.tencent_key_quota_sync') < 0) return;
    let body = '';
    try { body = await resp.text(); } catch (e) { body = 'ERR:' + e.message; }
    syncResponses.push({ status: resp.status(), ok: resp.ok(), body });
  });

  await context.request.post(host + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });

  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(2800);

  const card1 = page.locator('#local_key_panel .ant-card', { hasText: 'account-1' }).first();
  await card1.getByRole('button', { name: /巡\s*检/ }).click();
  await page.waitForTimeout(2200);

  const noRemoteCard = page.locator('#local_key_panel .ant-card').filter({ hasText: 'no-remote-' }).first();
  const noRemoteAccountText = ((await noRemoteCard.innerText()) || '').split('\n')[0] || '';
  await noRemoteCard.getByRole('button', { name: /巡\s*检/ }).click();
  await page.waitForTimeout(2200);

  await page.getByRole('button', { name: '刷新状态' }).first().click();
  await page.waitForTimeout(2200);

  const card1Text = await card1.innerText();
  const noRemoteText = await noRemoteCard.innerText();

  const account1Healthy = card1Text.indexOf('健康正常') >= 0;
  const noRemoteNotFound = noRemoteText.indexOf('远端无记录') >= 0;

  await page.screenshot({ path: '/data/project/auto-check/test/tencent_key_apply/sync-ui-states.png', fullPage: true });

  console.log(JSON.stringify({
    noRemoteAccountText,
    account1Healthy,
    noRemoteNotFound,
    syncResponseCount: syncResponses.length,
    syncResponses,
    consoleErrors,
    pageErrors,
    screenshot: '/data/project/auto-check/test/tencent_key_apply/sync-ui-states.png'
  }, null, 2));

  await browser.close();
})();
