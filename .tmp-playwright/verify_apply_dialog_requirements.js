const { chromium } = require('playwright');

(async () => {
  const host = 'http://192.168.232.130:8016';
  const pageUrl = host + '/collect-ui#/collect-ui/framework/tencent_key_apply';

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const consoleErrors = [];
  const pageErrors = [];
  const submitResponses = [];

  page.on('console', (msg) => {
    if (msg.type() === 'error') consoleErrors.push(msg.text());
  });
  page.on('pageerror', (err) => pageErrors.push(err.message));
  page.on('response', async (resp) => {
    const u = resp.url();
    if (u.indexOf('service=hrm.tencent_key_submit') < 0) return;
    let body = '';
    try { body = await resp.text(); } catch (e) { body = 'ERR:' + e.message; }
    submitResponses.push({ status: resp.status(), ok: resp.ok(), body });
  });

  await context.request.post(host + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });

  await page.goto(pageUrl, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(2500);

  const pageText = await page.locator('body').innerText();
  const hasRegionOnCards = pageText.indexOf('Region：') >= 0;

  await page.getByRole('button', { name: '申请腾讯Key' }).first().click();
  await page.waitForTimeout(600);

  const dialog = page.getByRole('dialog', { name: '申请腾讯Key' });
  const validateBtnVisible = await dialog.getByRole('button', { name: '校验SecretId/SecretKey' }).isVisible().catch(() => false);
  const regionFieldInDialog = await dialog.getByText('Region').count();

  const now = Date.now();
  await dialog.getByPlaceholder('AKID...').fill('AKID_NO_VALIDATE_' + now);
  await dialog.getByPlaceholder('请输入腾讯云 SecretKey').fill('SK_NO_VALIDATE_' + now);
  await dialog.getByPlaceholder('例如：腾讯免费测试号').fill('submit-without-validate-' + now);

  await page.getByRole('button', { name: /提交申请|确\s*定/ }).last().click();
  await page.waitForTimeout(2800);

  console.log(JSON.stringify({
    validateBtnVisible,
    regionFieldInDialog,
    hasRegionOnCards,
    submitResponses,
    consoleErrors,
    pageErrors
  }, null, 2));

  await browser.close();
})();
