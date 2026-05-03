const { chromium } = require('playwright');

const HOST = 'http://192.168.232.130:8016';
const URL = HOST + '/collect-ui#/collect-ui/framework/tencent_key_apply';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const consoleErrors = [];
  const pageErrors = [];
  const reqLogs = [];

  page.on('console', (msg) => {
    if (msg.type() === 'error') consoleErrors.push(msg.text());
  });
  page.on('pageerror', (err) => pageErrors.push(err.message));
  page.on('response', async (resp) => {
    const u = resp.url();
    if (!u.includes('/template_data/data')) return;
    if (!(
      u.includes('service=hrm.tencent_key_submit') ||
      u.includes('service=hrm.tencent_key_remote_request_list') ||
      u.includes('service=hrm.tencent_key_agency_key_list') ||
      u.includes('service=hrm.travel_agency_accessible_list') ||
      u.includes('service=hrm.tencent_key_current_agency')
    )) return;
    let body = '';
    try {
      body = await resp.text();
    } catch (e) {
      body = 'ERR:' + e.message;
    }
    reqLogs.push({ url: u, status: resp.status(), ok: resp.ok(), body });
  });

  const loginResp = await context.request.post(HOST + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });
  const loginJson = await loginResp.json();
  if (!loginJson.success) {
    console.log(JSON.stringify({ ok: false, step: 'login', loginJson }, null, 2));
    await browser.close();
    return;
  }

  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(2500);

  const title = await page.getByText('腾讯 Key 申请与旅行社台账').first().isVisible().catch(() => false);

  const hintText = (await page.locator('text=当前旅行社：').first().textContent().catch(() => '')) || '';
  const hintMatch = hintText.match(/预生成账号：([^\s|｜]+)/);
  const generatedByHint = hintMatch ? hintMatch[1] : '';

  await page.getByRole('button', { name: '申请腾讯Key' }).first().click();
  await page.waitForTimeout(500);

  const dialogText = (await page.getByRole('dialog', { name: '申请腾讯Key' }).textContent().catch(() => '')) || '';
  const dialogMatch = dialogText.match(/账号名称\s*([^\s]+?)\s*SecretId/);
  const generatedByDialog = dialogMatch ? dialogMatch[1] : '';

  const now = Date.now();
  await page.getByPlaceholder('AKID...').fill('AKID_VCHK_' + now);
  await page.getByPlaceholder('请输入腾讯云 SecretKey').fill('SK_VCHK_' + now);
  await page.getByPlaceholder('例如：腾讯免费测试号').fill('var-check-' + now);

  let submitReqPostData = '';
  page.on('request', (req) => {
    const u = req.url();
    if (u.includes('service=hrm.tencent_key_submit') && req.method() === 'POST') {
      submitReqPostData = req.postData() || '';
    }
  });

  const submitBtn = page.getByRole('button', { name: /提交申请|确\s*定/ }).last();
  await submitBtn.click();
  await page.waitForTimeout(2200);

  await page.getByRole('button', { name: '刷新状态' }).first().click();
  await page.waitForTimeout(2200);

  const remoteCards = page.locator('#remote_request_panel .ant-card');
  const remoteCount = await remoteCards.count();

  let submitParsed = {};
  try {
    submitParsed = JSON.parse(submitReqPostData || '{}');
  } catch (e) {
    submitParsed = { parseError: e.message, raw: submitReqPostData };
  }

  console.log(JSON.stringify({
    ok: true,
    title,
    hintText,
    generatedByHint,
    generatedByDialog,
    submitParsed,
    remoteCount,
    consoleErrors,
    pageErrors,
    reqLogs: reqLogs.slice(-12)
  }, null, 2));

  await browser.close();
})();
