const { chromium } = require('playwright');

const HOST = 'http://192.168.232.130:8016';
const URL = HOST + '/collect-ui#/collect-ui/framework/travel_org_manage';

function safeJson(text) {
  try { return JSON.parse(text); } catch (e) { return null; }
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1600, height: 900 } });
  const page = await context.newPage();

  const events = [];

  page.on('request', (req) => {
    const u = req.url();
    if (!u.includes('/template_data/data?service=')) return;
    if (!u.includes('travel_')) return;
    events.push({
      kind: 'request',
      url: u,
      method: req.method(),
      postData: req.postData() || ''
    });
  });

  page.on('response', async (res) => {
    const u = res.url();
    if (!u.includes('/template_data/data?service=')) return;
    if (!u.includes('travel_')) return;
    let text = '';
    try {
      text = await res.text();
    } catch (e) {
      text = 'ERR:' + e.message;
    }
    events.push({
      kind: 'response',
      url: u,
      status: res.status(),
      ok: res.ok(),
      body: text
    });
  });

  await context.request.post(HOST + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });

  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(3500);

  const ownerText = '金秋财务＆金佑担保~19907445603';
  const contactText = "财财圈'江西财税同行";

  const owner = page.getByText(ownerText, { exact: false }).first();
  if (await owner.count()) {
    await owner.click();
    await page.waitForTimeout(2000);
  }

  const contact = page.getByText(contactText, { exact: false }).first();
  if (await contact.count()) {
    await contact.click();
    await page.waitForTimeout(3500);
  }

  await page.screenshot({ path: '/tmp/travel_chat_capture.png', fullPage: true });

  const chatReqs = events.filter((e) => e.kind === 'request' && e.url.includes('service=hrm.travel_chat_record_list'));
  const chatResps = events.filter((e) => e.kind === 'response' && e.url.includes('service=hrm.travel_chat_record_list'));

  const parsed = chatResps.map((r, idx) => {
    const j = safeJson(r.body);
    const data = j && j.data;
    const dataType = Array.isArray(data) ? 'array' : typeof data;

    let count = 0;
    let items = [];

    if (Array.isArray(data)) {
      items = data;
      count = data.length;
    } else if (data && Array.isArray(data.list)) {
      items = data.list;
      count = data.list.length;
    } else if (data && typeof data === 'object') {
      const numericKeys = Object.keys(data).filter((k) => /^\d+$/.test(k));
      items = numericKeys.map((k) => data[k]);
      count = items.length;
    }

    const summary = items.slice(0, 6).map((x) => ({
      message_time_formatted: x && x.message_time_formatted,
      analyze_time: x && x.analyze_time,
      modify_time: x && x.modify_time,
      message_time: x && x.message_time,
      owner_nick_name: x && x.owner_nick_name,
      contact_nick_name: x && x.contact_nick_name,
      wx_msg_id: x && x.wx_msg_id,
      content_preview: (x && x.content ? String(x.content) : '').slice(0, 24)
    }));

    const has0502MessageTime = items.some((x) => String((x && x.message_time_formatted) || '').startsWith('2026-05-02'));
    const has0502AnalyzeTime = items.some((x) => String((x && x.analyze_time) || '').startsWith('2026-05-02'));

    return {
      idx,
      status: r.status,
      dataType,
      dataKeys: data && typeof data === 'object' ? Object.keys(data).slice(0, 20) : [],
      count,
      has0502MessageTime,
      has0502AnalyzeTime,
      summary,
      rawHead: r.body.slice(0, 300)
    };
  });

  const domDates = await page.evaluate(() => {
    const text = document.body ? document.body.innerText : '';
    const arr = text.match(/2026-0[45]-\d{2}(?:\s+\d{2}:\d{2}:\d{2})?/g) || [];
    return Array.from(new Set(arr));
  });

  const result = {
    chatReqs,
    chatRespsCount: chatResps.length,
    parsed,
    domDates,
    screenshot: '/tmp/travel_chat_capture.png'
  };

  console.log(JSON.stringify(result, null, 2));

  await browser.close();
})();
