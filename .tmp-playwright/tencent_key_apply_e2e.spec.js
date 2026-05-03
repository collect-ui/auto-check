const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const TARGET_URL = 'http://192.168.232.130:8016/collect-ui#/collect-ui/framework/tencent_key_apply';
const LOGIN_API = 'http://192.168.232.130:8016/template_data/data';
const LOGIN_CREDENTIAL = { username: 'admin', password: '123456' };

function nowStamp() {
  const d = new Date();
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}${p(d.getMonth() + 1)}${p(d.getDate())}-${p(d.getHours())}${p(d.getMinutes())}${p(d.getSeconds())}`;
}

async function isMainPage(page) {
  const titleVisible = await page.getByText('腾讯 Key 申请与旅行社台账').first().isVisible().catch(() => false);
  if (titleVisible) return true;
  const leftVisible = await page.getByText('远程申请状态').first().isVisible().catch(() => false);
  const rightVisible = await page.getByText('旅行社本地 Key 台账').first().isVisible().catch(() => false);
  return leftVisible && rightVisible;
}

async function waitApplyEnabled(page, timeoutMs = 12000) {
  const btn = page.getByRole('button', { name: '申请腾讯Key' }).first();
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    const visible = await btn.isVisible().catch(() => false);
    const enabled = visible ? await btn.isEnabled().catch(() => false) : false;
    if (enabled) return true;
    await page.waitForTimeout(500);
  }
  return false;
}

async function tryPickAgency(page) {
  const applyBtn = page.getByRole('button', { name: '申请腾讯Key' }).first();
  if (await applyBtn.isEnabled().catch(() => false)) return true;

  const select = page.locator('.ant-select').first();
  const canOpenSelect = await select.isVisible().catch(() => false);
  if (!canOpenSelect) return false;

  await select.click().catch(() => {});
  await page.waitForTimeout(500);
  const firstOption = page.locator('.ant-select-item-option').first();
  const hasOption = await firstOption.count();
  if (hasOption > 0) {
    await firstOption.click().catch(() => {});
    await page.waitForTimeout(1200);
    return await waitApplyEnabled(page, 6000);
  }
  return false;
}

async function ensureLoginAndOpen(page) {
  const loginResp = await page.context().request.post(LOGIN_API, {
    data: {
      service: 'system.login',
      username: LOGIN_CREDENTIAL.username,
      password: LOGIN_CREDENTIAL.password
    }
  });

  let loginOk = false;
  try {
    const loginJson = await loginResp.json();
    loginOk = !!(loginJson && loginJson.success);
  } catch (e) {
    loginOk = false;
  }
  if (!loginOk) {
    return { success: false, credential: `${LOGIN_CREDENTIAL.username}/${LOGIN_CREDENTIAL.password}`, applyEnabled: false };
  }

  await page.goto(TARGET_URL, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(2200);

  if (await isMainPage(page)) {
    const enabled = (await waitApplyEnabled(page, 8000)) || (await tryPickAgency(page));
    if (enabled) {
      return { success: true, credential: `${LOGIN_CREDENTIAL.username}/${LOGIN_CREDENTIAL.password}`, applyEnabled: true };
    }
  }
  return { success: false, credential: `${LOGIN_CREDENTIAL.username}/${LOGIN_CREDENTIAL.password}`, applyEnabled: false };
}

test('tencent_key_apply full flow', async ({ page }) => {
  test.setTimeout(240000);

  const reportDir = '/data/project/auto-check/test/tencent_key_apply';
  fs.mkdirSync(reportDir, { recursive: true });
  const stamp = nowStamp();

  const consoleErrors = [];
  const pageErrors = [];
  const failedRequests = [];
  const submitResponses = [];

  page.on('console', (msg) => {
    if (msg.type() === 'error') {
      consoleErrors.push({ text: msg.text() });
    }
  });

  page.on('pageerror', (err) => {
    pageErrors.push({ message: err.message });
  });

  page.on('requestfailed', (req) => {
    failedRequests.push({
      url: req.url(),
      method: req.method(),
      failure: req.failure() ? req.failure().errorText : 'unknown'
    });
  });

  page.on('response', async (resp) => {
    const url = resp.url();
    if (!url.includes('service=hrm.tencent_key_submit')) return;

    const item = {
      url,
      status: resp.status(),
      ok: resp.ok(),
      body: ''
    };
    try {
      item.body = await resp.text();
    } catch (e) {
      item.body = `read body failed: ${e.message}`;
    }
    submitResponses.push(item);
  });

  await page.setViewportSize({ width: 1440, height: 900 });

  const loginResult = await ensureLoginAndOpen(page);
  expect(loginResult.success).toBeTruthy();
  expect(loginResult.applyEnabled).toBeTruthy();

  await expect(page.getByText('远程申请状态')).toBeVisible();
  await expect(page.getByText('旅行社本地 Key 台账')).toBeVisible();

  const remoteRowsBefore = await page.locator('#remote_request_panel .ag-center-cols-container .ag-row').count();
  const localRowsBefore = await page.locator('#local_key_panel .ag-center-cols-container .ag-row').count();

  await page.getByRole('button', { name: '申请腾讯Key' }).first().click();
  await expect(page.getByRole('dialog', { name: '申请腾讯Key' })).toBeVisible();

  const dialog = page.getByRole('dialog', { name: '申请腾讯Key' });
  const dialogText = (await dialog.textContent()) || '';
  const accountMatch = dialogText.match(/预生成账号：([^\s|｜]+)/);
  const accountName = accountMatch ? accountMatch[1].trim() : '';

  const suffix = Date.now();
  await dialog.getByPlaceholder('AKID...').fill(`AKID_E2E_${suffix}`);
  await dialog.getByPlaceholder('请输入腾讯云 SecretKey').fill(`SK_E2E_${suffix}`);
  await dialog.getByPlaceholder('例如：腾讯免费测试号').fill(`e2e-auto-${stamp}`);

  const submitBtn = page.getByRole('button', { name: /确\s*定/ }).last();
  await expect(submitBtn).toBeVisible();
  await submitBtn.click();
  await page.waitForTimeout(2800);

  const successMsg = await page.getByText('申请已提交').first().isVisible().catch(() => false);
  const dialogStillOpen = await page.getByRole('dialog', { name: '申请腾讯Key' }).isVisible().catch(() => false);

  // 触发一次刷新，确保表格展示最新
  await page.getByRole('button', { name: '刷新状态' }).first().click();
  await page.waitForTimeout(2200);

  const remoteRowsAfter = await page.locator('#remote_request_panel .ag-center-cols-container .ag-row').count();
  const localRowsAfter = await page.locator('#local_key_panel .ag-center-cols-container .ag-row').count();

  let createdAccountVisible = false;
  if (accountName) {
    createdAccountVisible = await page.locator('#remote_request_panel .ag-cell-value', { hasText: accountName }).first().isVisible().catch(() => false);
  }

  const screenshotPath = path.join(reportDir, `${stamp}-tencent-key-apply.png`);
  await page.screenshot({ path: screenshotPath, fullPage: true });

  const report = {
    pageUrl: TARGET_URL,
    loginSuccess: loginResult.success,
    loginCredentialUsed: loginResult.credential,
    accountName,
    applyResult: {
      successMsg,
      dialogStillOpen,
      submitResponses
    },
    layoutCheck: {
      hasRemotePanel: await page.getByText('远程申请状态').first().isVisible().catch(() => false),
      hasLocalPanel: await page.getByText('旅行社本地 Key 台账').first().isVisible().catch(() => false)
    },
    rows: {
      remoteBefore: remoteRowsBefore,
      remoteAfter: remoteRowsAfter,
      localBefore: localRowsBefore,
      localAfter: localRowsAfter,
      createdAccountVisible
    },
    consoleErrors,
    pageErrors,
    failedRequests,
    screenshotPath,
    ts: new Date().toISOString()
  };

  const reportPath = path.join(reportDir, `${stamp}-report.json`);
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));

  console.log(JSON.stringify(report, null, 2));
});
