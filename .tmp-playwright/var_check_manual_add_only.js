const { chromium } = require('playwright');

const HOST = 'http://192.168.232.130:8016';
const URL = HOST + '/collect-ui#/collect-ui/framework/tencent_key_apply';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const reqs = [];
  const resps = [];

  page.on('request', (req) => {
    const u = req.url();
    if (u.indexOf('service=hrm.tencent_key_agency_key_manual_add') >= 0) {
      reqs.push({ method: req.method(), url: u, postData: req.postData() || '' });
    }
  });

  page.on('response', async (resp) => {
    const u = resp.url();
    if (u.indexOf('service=hrm.tencent_key_agency_key_manual_add') >= 0) {
      let body = '';
      try { body = await resp.text(); } catch (e) { body = 'ERR:' + e.message; }
      resps.push({ status: resp.status(), ok: resp.ok(), url: u, body });
    }
  });

  await context.request.post(HOST + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });

  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(2500);

  const uniqueAccount = 'manual-card-' + Date.now();
  await page.locator('#local_key_panel').getByRole('button', { name: '手动添加' }).first().click();
  await page.waitForTimeout(700);

  const dialog = page.getByRole('dialog', { name: '手动添加旅行社Key台账' });
  await dialog.getByPlaceholder('手动录入账号名称').fill(uniqueAccount);
  await dialog.getByPlaceholder('手动录入说明（可选）').fill('var-row-check');
  await dialog.locator('.ant-modal-footer .ant-btn-primary').click();
  await page.waitForTimeout(2600);

  const dialogOpen = await dialog.isVisible().catch(() => false);
  const dialogText = (await dialog.textContent().catch(() => '')) || '';

  await page.screenshot({ path: '/data/project/auto-check/test/tencent_key_apply/manual-add-debug.png', fullPage: true });

  console.log(JSON.stringify({ uniqueAccount, dialogOpen, dialogText, reqs, resps }, null, 2));

  await browser.close();
})();
