const { chromium } = require('playwright');

const HOST = 'http://192.168.232.130:8016';
const URL = HOST + '/collect-ui#/collect-ui/framework/tencent_key_apply';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const responses = [];
  page.on('response', async (resp) => {
    const u = resp.url();
    if (u.indexOf('/template_data/data?service=') < 0) return;
    if (
      u.indexOf('hrm.tencent_key_agency_key_manual_add') < 0 &&
      u.indexOf('hrm.tencent_key_agency_key_list') < 0
    ) return;
    let body = '';
    try {
      body = await resp.text();
    } catch (e) {
      body = 'ERR:' + e.message;
    }
    responses.push({ url: u, status: resp.status(), ok: resp.ok(), body });
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
  await dialog.getByRole('button', { name: /确认添加|确\s*定|提\s*交/ }).last().click();
  await page.waitForTimeout(3200);

  await page.getByRole('button', { name: '刷新状态' }).first().click();
  await page.waitForTimeout(2200);

  const panelText = (await page.locator('#local_key_panel').textContent()) || '';
  const containsAccount = panelText.indexOf(uniqueAccount) >= 0;

  console.log(JSON.stringify({ uniqueAccount, containsAccount, responses }, null, 2));

  await browser.close();
})();
