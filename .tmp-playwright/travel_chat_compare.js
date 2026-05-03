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

  const reqs = [];
  const resps = [];

  page.on('request', (req) => {
    const u = req.url();
    if (u.indexOf('/template_data/data?service=') < 0) return;
    if (u.indexOf('travel_') < 0) return;
    reqs.push({ url: u, postData: req.postData() || '' });
  });

  page.on('response', async (res) => {
    const u = res.url();
    if (u.indexOf('/template_data/data?service=') < 0) return;
    if (u.indexOf('travel_') < 0) return;
    let text = '';
    try { text = await res.text(); } catch (e) { text = 'ERR:' + e.message; }
    resps.push({ url: u, status: res.status(), body: text });
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
    await page.waitForTimeout(2500);
  }

  const contact = page.getByText(contactText, { exact: false }).first();
  if (await contact.count()) {
    await contact.click();
    await page.waitForTimeout(3500);
  }

  const contactReq = reqs.filter(r => r.url.indexOf('service=hrm.travel_chat_contact_list') >= 0).slice(-1)[0];
  const contactRespRaw = resps.filter(r => r.url.indexOf('service=hrm.travel_chat_contact_list') >= 0).slice(-1)[0];
  const chatReq = reqs.filter(r => r.url.indexOf('service=hrm.travel_chat_record_list') >= 0).slice(-1)[0];
  const chatRespRaw = resps.filter(r => r.url.indexOf('service=hrm.travel_chat_record_list') >= 0).slice(-1)[0];

  const contactReqJson = contactReq ? safeJson(contactReq.postData) : null;
  const chatReqJson = chatReq ? safeJson(chatReq.postData) : null;
  const contactRespJson = contactRespRaw ? safeJson(contactRespRaw.body) : null;
  const chatRespJson = chatRespRaw ? safeJson(chatRespRaw.body) : null;

  const contactData = (contactRespJson && Array.isArray(contactRespJson.data)) ? contactRespJson.data : [];
  const chosenContact = contactData.find((x) => {
    const name = String((x && (x.nick_name || x.contact_nick_name)) || '');
    return name.indexOf("财财圈'江西财税同行") >= 0;
  });

  const chatData = (chatRespJson && Array.isArray(chatRespJson.data)) ? chatRespJson.data : [];
  const firstMsg = chatData.length > 0 ? chatData[0] : null;
  const lastMsg = chatData.length > 0 ? chatData[chatData.length - 1] : null;

  const topDatesInChat = Array.from(new Set(chatData.map(x => (x && x.message_time_formatted) || '').filter(Boolean).map(x => String(x).slice(0, 10)))).slice(-10);
  const has0502ByMsgTime = chatData.some(x => String((x && x.message_time_formatted) || '').indexOf('2026-05-02') === 0);
  const has0502ByAnalyze = chatData.some(x => String((x && x.analyze_time) || '').indexOf('2026-05-02') === 0);

  console.log(JSON.stringify({
    contactReqJson,
    chatReqJson,
    chosenContact: chosenContact ? {
      contact_id: chosenContact.contact_id,
      employee_id: chosenContact.employee_id,
      owner_nick_name: chosenContact.owner_nick_name,
      contact_nick_name: chosenContact.contact_nick_name,
      nick_name: chosenContact.nick_name,
      message_time_formatted: chosenContact.message_time_formatted,
      analyze_time: chosenContact.analyze_time,
      modify_time: chosenContact.modify_time,
      content_preview: String(chosenContact.content || '').slice(0, 40)
    } : null,
    chatCount: chatData.length,
    has0502ByMsgTime,
    has0502ByAnalyze,
    firstMsg: firstMsg ? {
      message_time_formatted: firstMsg.message_time_formatted,
      analyze_time: firstMsg.analyze_time,
      modify_time: firstMsg.modify_time,
      contact_nick_name: firstMsg.contact_nick_name,
      owner_nick_name: firstMsg.owner_nick_name,
      wx_msg_id: firstMsg.wx_msg_id
    } : null,
    lastMsg: lastMsg ? {
      message_time_formatted: lastMsg.message_time_formatted,
      analyze_time: lastMsg.analyze_time,
      modify_time: lastMsg.modify_time,
      contact_nick_name: lastMsg.contact_nick_name,
      owner_nick_name: lastMsg.owner_nick_name,
      wx_msg_id: lastMsg.wx_msg_id
    } : null,
    topDatesInChat
  }, null, 2));

  await browser.close();
})();
