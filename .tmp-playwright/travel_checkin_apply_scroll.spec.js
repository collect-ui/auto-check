const { test } = require('@playwright/test');

test('inspect scroll', async ({ page }) => {
  const logs = [];
  page.on('console', msg => {
    if (msg.type() === 'error') logs.push({ type: 'console', text: msg.text() });
  });
  page.on('pageerror', err => logs.push({ type: 'pageerror', text: err.message }));

  await page.setViewportSize({ width: 1440, height: 900 });
  await page.goto('http://192.168.232.130:8016/collect-ui/#/collect-ui/travel_checkin_apply', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);

  const data = await page.evaluate(() => {
    const pick = (el, name) => {
      if (!el) return null;
      const cs = getComputedStyle(el);
      return {
        name,
        tag: el.tagName,
        id: el.id,
        className: el.className,
        clientHeight: el.clientHeight,
        scrollHeight: el.scrollHeight,
        offsetHeight: el.offsetHeight,
        overflowY: cs.overflowY,
        overflowX: cs.overflowX,
        position: cs.position,
        minHeight: cs.minHeight,
        height: cs.height,
        boxSizing: cs.boxSizing,
        paddingTop: cs.paddingTop,
        paddingBottom: cs.paddingBottom,
        marginTop: cs.marginTop,
        marginBottom: cs.marginBottom
      };
    };

    const html = document.documentElement;
    const body = document.body;
    const root = document.querySelector('#root');
    const chain = [];
    let node = Array.from(document.querySelectorAll('*')).find(el => (el.textContent || '').includes('申请信息') && (el.textContent || '').includes('已有账号，去登录'));
    while (node) {
      chain.push(pick(node, node.tagName.toLowerCase()));
      node = node.parentElement;
      if (chain.length > 12) break;
    }

    return {
      href: location.href,
      title: document.title,
      innerHeight: window.innerHeight,
      html: pick(html, 'html'),
      body: pick(body, 'body'),
      root: pick(root, '#root'),
      bodyScrollDiff: body.scrollHeight - window.innerHeight,
      htmlScrollDiff: html.scrollHeight - window.innerHeight,
      chain
    };
  });

  console.log(JSON.stringify({ data, logs }, null, 2));
});
