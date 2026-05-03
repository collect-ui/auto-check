const { chromium } = require('playwright');

(async () => {
  const host = 'http://127.0.0.1:8016';
  const url = host + '/collect-ui#/collect-ui/framework/tencent_key_apply';

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const consoleErrors = [];
  const pageErrors = [];
  const addResponses = [];

  page.on('console', (msg) => { if (msg.type() === 'error') consoleErrors.push(msg.text()); });
  page.on('pageerror', (err) => pageErrors.push(err.message));
  page.on('response', async (resp) => {
    const u = resp.url();
    if (u.indexOf('service=hrm.tencent_key_agency_key_manual_add') < 0) return;
    let body = '';
    try { body = await resp.text(); } catch (e) { body = 'ERR:' + e.message; }
    addResponses.push({ status: resp.status(), ok: resp.ok(), body });
  });

  await context.request.post(host + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });

  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(2600);

  const uiAccount = 'account-ui-' + Date.now();
  await page.locator('#local_key_panel').getByRole('button', { name: '手动添加' }).first().click();
  await page.waitForTimeout(700);

  const dialog = page.getByRole('dialog', { name: '手动添加旅行社Key台账' });
  await dialog.getByPlaceholder('手动录入账号名称').fill(uiAccount);
  await dialog.getByPlaceholder('手动录入说明（可选）').fill('ui-e2e');
  await dialog.locator('.ant-modal-footer .ant-btn-primary').click();
  await page.waitForTimeout(2800);

  await page.getByRole('button', { name: '刷新状态' }).first().click();
  await page.waitForTimeout(2200);

  const localPanelText = await page.locator('#local_key_panel').innerText();
  const found = localPanelText.indexOf(uiAccount) >= 0;
  const hasAccount1 = localPanelText.indexOf('account-1') >= 0;

  await page.screenshot({ path: '/data/project/auto-check/test/tencent_key_apply/manual-add-ui-ok.png', fullPage: true });

  console.log(JSON.stringify({
    uiAccount,
    found,
    hasAccount1,
    addResponses,
    consoleErrors,
    pageErrors,
    screenshot: '/data/project/auto-check/test/tencent_key_apply/manual-add-ui-ok.png'
  }, null, 2));

  await browser.close();
})();
