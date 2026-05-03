const { chromium } = require('playwright');

(async () => {
  const host = 'http://192.168.232.130:8016';
  const url = host + '/collect-ui#/collect-ui/framework/tencent_key_apply';

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const consoleErrors = [];
  const pageErrors = [];
  page.on('console', (msg) => { if (msg.type() === 'error') consoleErrors.push(msg.text()); });
  page.on('pageerror', (err) => pageErrors.push(err.message));

  await context.request.post(host + '/template_data/data', {
    data: { service: 'system.login', username: 'admin', password: '123456' }
  });

  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(3000);

  const bodyText = await page.locator('body').innerText();
  const ocrLine = bodyText.split('\n').find((line) => line.includes('OCR调用：')) || '';

  await page.screenshot({ path: '/data/project/auto-check/test/tencent_key_apply/ocr-quota-banner.png', fullPage: true });

  console.log(JSON.stringify({
    ocrLine,
    hasOCRCallText: ocrLine.includes('OCR调用：'),
    hasRemainText: ocrLine.includes('剩余：'),
    consoleErrors,
    pageErrors,
    screenshot: '/data/project/auto-check/test/tencent_key_apply/ocr-quota-banner.png'
  }, null, 2));

  await browser.close();
})();
