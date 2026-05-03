const { chromium } = require('playwright');

const HOST = 'http://192.168.232.130:8016';
const URL = HOST + '/collect-ui#/collect-ui/framework/tencent_key_apply';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const consoleErrors = [];
  const pageErrors = [];

  page.on('console', (msg) => {
    if (msg.type() === 'error') consoleErrors.push(msg.text());
  });
  page.on('pageerror', (err) => pageErrors.push(err.message));

  const reqBodies = [];
  page.on('request', (req) => {
    const u = req.url();
    if (!u.includes('/template_data/data?service=')) return;
    if (!(
      u.includes('hrm.tencent_key_agency_key_manual_add') ||
      u.includes('hrm.tencent_key_agency_key_disable') ||
      u.includes('hrm.tencent_key_agency_key_enable') ||
      u.includes('hrm.tencent_key_quota_sync')
    )) return;
    reqBodies.push({ url: u, method: req.method(), body: req.postData() || '' });
  });

  await context.request.post(HOST + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });

  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(2200);

  const uniqueAccount = 'manual-card-' + Date.now();

  await page.locator('#local_key_panel').getByRole('button', { name: '手动添加' }).first().click();
  await page.waitForTimeout(700);

  const dialog = page.getByRole('dialog', { name: '手动添加旅行社Key台账' });
  await dialog.getByPlaceholder('手动录入账号名称').fill(uniqueAccount);
  await dialog.getByPlaceholder('手动录入说明（可选）').fill('var-row-check');
  await dialog.getByRole('button', { name: /确认添加|确\s*定|提\s*交/ }).last().click();
  await page.waitForTimeout(2600);

  const localPanel = page.locator('#local_key_panel');
  const targetCard = localPanel.locator('.ant-card', { hasText: uniqueAccount }).first();
  const cardFound = await targetCard.count();

  let beforeStatusBtn = '';
  let afterToggleStatusBtn = '';

  if (cardFound > 0) {
    const statusBtn = targetCard.getByRole('button', { name: /停用|启用/ }).first();
    beforeStatusBtn = ((await statusBtn.textContent()) || '').trim();
    await statusBtn.click();
    await page.waitForTimeout(1800);

    const statusBtn2 = targetCard.getByRole('button', { name: /停用|启用/ }).first();
    afterToggleStatusBtn = ((await statusBtn2.textContent()) || '').trim();

    await statusBtn2.click();
    await page.waitForTimeout(1800);

    const syncBtn = targetCard.getByRole('button', { name: '巡检' }).first();
    await syncBtn.click();
    await page.waitForTimeout(2000);
  }

  const recent = reqBodies.slice(-10);
  const parsed = recent.map((r) => {
    let body = r.body;
    try { body = JSON.parse(r.body || '{}'); } catch (_) {}
    return { url: r.url, method: r.method, body };
  });

  console.log(JSON.stringify({
    uniqueAccount,
    cardFound,
    beforeStatusBtn,
    afterToggleStatusBtn,
    consoleErrors,
    pageErrors,
    requests: parsed
  }, null, 2));

  await browser.close();
})();
