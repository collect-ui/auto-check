const { chromium } = require('playwright');

const HOST = 'http://192.168.232.130:8016';
const URL = HOST + '/collect-ui#/collect-ui/framework/travel_org_manage';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1600, height: 900 } });
  const page = await context.newPage();

  const consoleErrors = [];
  const pageErrors = [];
  const apiTraffic = [];

  page.on('console', (msg) => {
    if (msg.type() === 'error') consoleErrors.push(msg.text());
  });
  page.on('pageerror', (err) => pageErrors.push(err.message));

  page.on('request', (req) => {
    const u = req.url();
    if (!u.includes('/template_data/data?service=')) return;
    if (!u.includes('travel_')) return;
    apiTraffic.push({
      type: 'request',
      url: u,
      method: req.method(),
      postData: req.postData() || ''
    });
  });

  page.on('response', async (resp) => {
    const u = resp.url();
    if (!u.includes('/template_data/data?service=')) return;
    if (!u.includes('travel_')) return;

    let body = '';
    try {
      body = await resp.text();
    } catch (e) {
      body = `ERR:${e.message}`;
    }

    apiTraffic.push({
      type: 'response',
      url: u,
      status: resp.status(),
      ok: resp.ok(),
      body
    });
  });

  const loginResp = await context.request.post(HOST + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });

  const loginText = await loginResp.text();

  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(4000);

  const ownerText = '金秋财务＆金佑担保~19907445603';
  const contactText = "财财圈'江西财税同行";

  const ownerLocator = page.locator(`text=${ownerText}`).first();
  const ownerCount = await ownerLocator.count();
  if (ownerCount > 0) {
    await ownerLocator.click({ timeout: 10000 });
    await page.waitForTimeout(2500);
  }

  const contactLocator = page.locator(`text=${contactText}`).first();
  const contactCount = await contactLocator.count();
  if (contactCount > 0) {
    await contactLocator.click({ timeout: 10000 });
    await page.waitForTimeout(3500);
  }

  const bodyText = (await page.locator('body').innerText()).replace(/\s+/g, ' ');
  const has0502InDom = bodyText.includes('2026-05-02');
  const has0420InDom = bodyText.includes('2026-04-20');

  const dateTexts = await page.evaluate(() => {
    const text = document.body?.innerText || '';
    const matches = text.match(/2026-0[45]-\d{2}\s+\d{2}:\d{2}:\d{2}|2026-0[45]-\d{2}/g) || [];
    return Array.from(new Set(matches)).slice(0, 50);
  });

  await page.screenshot({ path: '/tmp/travel_chat_after_click.png', fullPage: true });

  const chatResponses = apiTraffic
    .filter((x) => x.type === 'response' && x.url.includes('service=hrm.travel_chat_record_list'))
    .map((x) => {
      let parsed = null;
      try { parsed = JSON.parse(x.body || '{}'); } catch (_) {}
      const records = parsed?.data?.list || parsed?.list || [];
      const normalized = Array.isArray(records) ? records : [];
      const recSummary = normalized.slice(0, 8).map((r) => ({
        message_time_formatted: r.message_time_formatted,
        analyze_time: r.analyze_time,
        modify_time: r.modify_time,
        message_time: r.message_time,
        content_preview: (r.content || '').slice(0, 30),
        owner_nick_name: r.owner_nick_name,
        contact_nick_name: r.contact_nick_name,
        wx_msg_id: r.wx_msg_id
      }));
      const has0502ByMessageTime = normalized.some((r) => String(r.message_time_formatted || '').startsWith('2026-05-02'));
      const has0502ByAnalyzeTime = normalized.some((r) => String(r.analyze_time || '').startsWith('2026-05-02'));
      return {
        url: x.url,
        status: x.status,
        total: normalized.length,
        has0502ByMessageTime,
        has0502ByAnalyzeTime,
        sample: recSummary
      };
    });

  const chatRequests = apiTraffic
    .filter((x) => x.type === 'request' && x.url.includes('service=hrm.travel_chat_record_list'))
    .map((x) => ({ url: x.url, method: x.method, postData: x.postData }));

  console.log(JSON.stringify({
    loginText,
    ownerCount,
    contactCount,
    has0502InDom,
    has0420InDom,
    dateTexts,
    chatRequests,
    chatResponses,
    consoleErrors,
    pageErrors,
    screenshot: '/tmp/travel_chat_after_click.png'
  }, null, 2));

  await browser.close();
})();
