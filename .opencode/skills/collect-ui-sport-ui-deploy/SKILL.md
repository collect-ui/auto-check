---
name: collect-ui-sport-ui-deploy
description: collect-ui 变更后，构建 collect-ui 与 sport-ui，并部署到 /data/project/auto-check/frontend/collect-ui（含 gzip 校验与可选页面验收）。
---

# Collect UI -> Sport UI -> Auto-check Deploy

用于固定执行以下流程：
1. 在 `/data/project/collect-ui` 构建 collect-ui。
2. 在 `/data/project/sport-ui` 使用 deploy 配置构建 sport-ui。
3. 校验构建产物存在 `.gz` 文件。
4. 将 `sport-ui/build` 部署到 `/data/project/auto-check/frontend/collect-ui`。
5. （可选）用 Playwright 做页面可打开与报错检查。

## 适用场景
- 你改了 `collect-ui` 组件源码（例如 `form-item.tsx`）后，需要让 `sport-ui` 和 `auto-check` 立即生效。
- 你要重复执行“打包+部署+基础验证”并希望流程标准化。

## 固定路径
- Collect UI: `/data/project/collect-ui`
- Sport UI: `/data/project/sport-ui`
- Deploy Dir: `/data/project/auto-check/frontend/collect-ui`

## 执行步骤（手动）
1. `cd /data/project/collect-ui && npm run build`
2. `cd /data/project/sport-ui && NODE_OPTIONS=--max_old_space_size=8192 npx vite build --config vite.config.deploy.js`
3. `rm -rf /data/project/auto-check/frontend/collect-ui/*`
4. `cp -a /data/project/sport-ui/build/. /data/project/auto-check/frontend/collect-ui/`
5. `find /data/project/auto-check/frontend/collect-ui -type f -name '*.gz' | head`

## 一键脚本
- `bash /data/project/auto-check/.opencode/skills/collect-ui-sport-ui-deploy/scripts/build_and_deploy_autocheck.sh`

## 可选验收
- 通过环境变量启用 Playwright 验收：
  - `VERIFY=1 VERIFY_URL='http://127.0.0.1:8015/collect-ui' bash .../build_and_deploy_autocheck.sh`
- 默认不启用页面验收（仅打包部署+gzip校验）。

## 失败排查
1. collect-ui 构建失败：先看 TypeScript/依赖错误。
2. sport-ui 构建失败：检查 `vite.config.deploy.js`、Node 内存参数、依赖软链（`npm ls collect-ui`）。
3. 部署后无效果：确认目标目录是 `/data/project/auto-check/frontend/collect-ui`，并清浏览器缓存。
4. gzip 校验失败：确认 deploy 构建配置含压缩插件且生成 `.gz`。
