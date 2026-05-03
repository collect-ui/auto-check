const { chromium } = require('playwright');

const HOST = 'http://192.168.232.130:8016';
const URL = HOST + '/collect-ui#/collect-ui/framework/tencent_key_apply';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  await context.request.post(HOST + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });

  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(2500);

  const beforeHint = (await page.locator('text=当前旅行社：').first().textContent().catch(() => '')) || '';

  // 切换到 t1（t115）
  await page.locator('.ant-select').first().click();
  await page.waitForTimeout(400);
  await page.locator('.ant-select-item-option', { hasText: 't1（t115）' }).first().click();
  await page.waitForTimeout(2200);

  const afterHint = (await page.locator('text=当前旅行社：').first().textContent().catch(() => '')) || '';

  await page.getByRole('button', { name: '申请腾讯Key' }).first().click();
  await page.waitForTimeout(500);

  const dialogText = (await page.getByRole('dialog', { name: '申请腾讯Key' }).textContent().catch(() => '')) || '';
  const dialogAccount = ((dialogText.match(/账号名称\s*([^\s]+?)\s*SecretId/) || [])[1]) || '';

  const now = Date.now();
  await page.getByPlaceholder('AKID...').fill('AKID_VSW_' + now);
  await page.getByPlaceholder('请输入腾讯云 SecretKey').fill('SK_VSW_' + now);
  await page.getByPlaceholder('例如：腾讯免费测试号').fill('var-switch-' + now);

  let submitPost = '';
  page.on('request', (req) => {
    if (req.url().includes('service=hrm.tencent_key_submit') && req.method() === 'POST') {
      submitPost = req.postData() || '';
    }
  });

  await page.getByRole('button', { name: /提交申请|确\s*定/ }).last().click();
  await page.waitForTimeout(2200);

  let parsed = {};
  try { parsed = JSON.parse(submitPost || '{}'); } catch (e) { parsed = { parseError: e.message, raw: submitPost }; }

  console.log(JSON.stringify({ beforeHint, afterHint, dialogAccount, submit: parsed }, null, 2));

  await browser.close();
})();
