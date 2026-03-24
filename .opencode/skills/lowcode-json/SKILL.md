---
name: lowcode-json
description: 完整手册：低代码页面 JSON 的高频组件配置、联动规则、排错流程与源码核查规范。
---

## Purpose
- 让大模型在 `collect/frontend/page_data/**/*.json` 的改动中，快速做对常见组件与动作链配置。
- 降低“猜配置”导致的反复回归，改为“按文档+源码确认后再落地”。

## Scope
- 主要目标：`collect/frontend/page_data/**/*.json`
- 关联核查：`collect/**/*.yml`、`collect/**/*.sql`（仅用于确认接口参数与数据 shape）

## Source Of Truth (拿不准先看这里)
1. 组件文档：`/data/project/collect-ui/docs/readme/components/*.md`
2. 组件源码：`/data/project/collect-ui/src/components/*/*.tsx`
3. 低代码配置：`collect/frontend/page_data/**/*.json`
4. 服务编排：`collect/**/*.yml`
5. Ajax 动作源码：`/data/project/collect-ui/src/action/ajax.tsx`

## Mandatory Workflow
1. 定位页面 JSON：找到 `initStore`、`actionGroupDefine`、目标组件节点。
2. 确认组件能力：先读对应 docs，再看组件源码（特别是 props 实现）。
3. 小步改动：一次只改一个行为链（渲染/提交/reload）。
4. 静态校验：JSON 结构、表达式、group 名称、字段名一致性。
5. 联动复核：检查“触发 -> 请求 -> adapt -> 展示/提交”的闭环。

## Ajax 参数拼接规则（基于 `collect-ui/src/action/ajax.tsx`）
- 模块定位：`ajax` 是低代码请求的核心模块，搜索/新增/编辑/删除都依赖它。
- 源码位置：`/data/project/collect-ui/src/action/ajax.tsx`
- 核心能力：变量解析、参数拼接、GET/POST 分流、下载处理、结果适配、成功/失败回调。

### 参数说明（高频）
- `api` / `url`：请求地址，支持 `post:/template_data/data?...`；`url` 是 `api` 别名。
- `appendFields`：从 store 拼字段（通常用于 `page/size/count/pagination`）。
- `appendFormFields`：从表单拼字段（`store.getFormValue(formName)`，通常用于 `search`、编辑表单值）。
- `data`：附加参数，支持对象或表达式字符串（通常放上下文字段，如 `agency_id`）。
- `adapt`：响应字段写回 store（如 `list/count`）。
- `onSuccess` / `onError`：请求成功/失败后的动作链。
- `start` / `end`：请求前后更新状态（如 loading）。
- `showResultMsg`：成功后弹消息。
- `download` / `downloadingPercent`：文件下载与进度更新。

- 请求入参拼接顺序固定为：
  1. `appendFields`
  2. `appendFormFields`
  3. `api.data`
  4. `data`
- 同名字段后者覆盖前者（例如 `search` 可由表单值覆盖 store 值）。
- 搜索场景推荐混用：
  - `appendFields`：分页状态（`page/size`）
  - `appendFormFields`：搜索表单值（`search`）
- 推荐配置模板：
```json
{
  "tag": "ajax",
  "api": "post:/template_data/data?service=xxx.list",
  "appendFields": "${searchState}",
  "appendFormFields": "search-form",
  "adapt": {
    "list": "${data}",
    "count": "${count}"
  }
}
```

### 搜索推荐写法
- 搜索输入组件：`isSearch: true`，回车触发 `onSearchAction`。
- `onSearchAction`：先 `update-store`（写 `search`、重置 `page=1`），再 `reload-init-action`。
- 请求层：`appendFields + appendFormFields` 混用，避免“分页有值但搜索词丢失”。

### 常见坑
- 只写 `appendFields`，但搜索输入未同步到 store：后台收不到搜索词。
- 只写 `appendFormFields`，但分页状态在 store：翻页参数丢失。
- `data` 里覆写了同名字段，导致以为用的是表单值，实际被覆盖。

## Action Group Contract（必须写清楚）
- 每个 `actionGroupDefine.<group>` 都要声明三件事：
  - `trigger`：由哪个用户动作触发（点击、翻页、弹窗提交后等）。
  - `input`：依赖哪些 store 字段（如 `currentAgency.agency_id`）。
  - `output`：`adapt` 产出哪些字段，给谁消费。
- 一个 group 只做一件事：
  - 列表查询 group 只维护列表和总数。
  - 下拉查询 group 只维护下拉 options。
- 必须写 `enable` 前置条件，尤其是依赖选中主键时（例如 `currentAgency.agency_id`）。
- 禁止在一个 group 里顺手更新多个无关数据域，避免串线。

## High-Frequency Patterns

### 1) `layout-fit` 页面骨架
适用：列表+详情、左右分栏、管理页。

推荐结构：
- `initStore`：统一声明页面状态（当前选中、搜索表单、选择集、弹窗开关）。
- `children`：左侧 `listview`，右侧 `table` + toolbar + dialog。
- `actionGroupDefine`：把列表查询、下拉加载分组管理，不要把长链 action 全写在按钮里。

禁止：
- 在多个地方重复维护同一状态字段。
- 将高频输入事件直接绑定 reload，导致接口循环触发。

### 2) `listview` 联动（重点）
适用：左侧组织/项目/分类切换。

必备组合：
- `keyField` 与数据主键一致。
- `itemData` 与实际数组字段一致。
- `rowClickAction` 中同步更新：`currentX`、`selection`、关联查询条件。
- 切换后只触发必要 group：如 `relationList`、`supervisorList`。

禁止：
- `keyField`、`selection`、`current` 使用不同主键。
- group 串线（例如在 A 组链路里误刷新 B 组）。

### 3) `table` 列配置
适用：成员列表、管理列表。

推荐：
- 普通文本：`field + headerName`。
- 角色/状态：优先 `cellRender`（支持图标+文字），其次 `valueFormatter`。
- 操作列：按钮 + `confirm` + 成功后 `reload-init-action`。

角色图标示例：
```json
{
  "headerName": "角色",
  "field": "role_type",
  "cellRender": [
    {
      "tag": "icon",
      "icon": "${row.role_type==='supervisor'?'SafetyCertificateFilled':'TeamOutlined'}"
    },
    {
      "tag": "span",
      "children": "${row.role_type==='supervisor'?'主管':'销售'}"
    }
  ]
}
```

### 4) `form` 与提交
适用：新增/编辑弹窗。

推荐：
- 表单提交优先 `appendFormFields`。
- 非表单参数（如 `agency_id`、分页）放 `data` 或 `appendFields`。
- 编辑时用 `update-form` 回填，新增时先 `reset-form`。
- 动态显隐用 `visible` + `getFormValue(...)`。

禁止：
- 先把表单全量同步到 store 再发请求（容易出中间态问题）。

### 5) `select`（重点）
适用：角色选择、主管选择。

推荐（最稳）：
- `options` 统一适配为 `[{label, value}]`。
- 在 `actionGroupDefine` 的 `adapt` 中完成 shape 转换。

示例：
```json
"adapt": {
  "supervisorList": "${data.map(item=>({value:item.user_id,label:(item.nick+'（'+item.username+'）')}))}"
}
```

然后：
```json
{
  "tag": "select",
  "options": "${supervisorList}"
}
```

注意：
- `fieldNames` 仅在确实需要保留非标准结构时使用。
- `optionRender` 前先确认组件实现传入的数据上下文，不要默认可用 `row.xxx`。
- 下拉数据源如果来自列表接口，默认在请求侧关闭分页统计：
  - `pagination: false`
  - `count: false`
  - 然后在 `adapt` 转成 `[{label,value}]` 再给 `options`。

### 6) `input`（重点）
适用：备注、描述、搜索框。

文本域必须：
```json
{
  "tag": "input",
  "isTextarea": true,
  "rows": 3
}
```

不要写：
- `type: "textarea"`（与组件实现不一致）。

### 7) Dialog 提交时序（新增）
适用：新增/编辑弹窗（含 `confirmAndContinue`）。

推荐顺序：
1. `submit-form`
2. `ajax`（`appendFormFields`）
3. `reload-init-action`（刷新列表/下拉）
4. `reset-form`（仅连续新增场景）
5. `update-store` 关闭弹窗（非连续新增）

连续新增约束：
- `confirmAndContinue=true` 时，提交成功后不关弹窗，走 `reset-form`。
- 非连续新增时，提交成功后关闭弹窗并刷新列表。

## Service-Flow Coordination (与后端配置协同)

### 1) 返回值落盘必须显式保存
- `service2field` 调用后，若下游要复用关键字段（如 `user_id`），必须 `save_field`。
- 下游保存关系时，用返回字段而不是上游临时字段。

### 2) 动态角色映射
- 前端传 `role_type`（如 `sales`/`supervisor`）。
- 使用 `field2array` 转为 `role_id_list` 再传给用户创建流。

示例：
```yaml
- key: field2array
  field: "[role_type]"
  save_field: role_id_list
```

## JSON -> YML -> SQL 参数链核验（新增）
- JSON 请求参数名要与 yml `params` 一致（拼写、大小写、嵌套路径）。
- yml 的 service 调用参数要与下游 service 入参一致。
- SQL 过滤字段要与 yml 传入字段一致（例如 `agency_id`、`role_type`、`search`）。
- 表单字段用于提交时，优先 `appendFormFields`，额外上下文字段放 `data` 或 `appendFields`。
- 关键 ID（如 `user_id`）跨服务传递时，必须核验来源字段是否为“实际返回值”。

## Error Library (本次会话沉淀)

1. 关系表 `user_id` 与用户表不一致
- 原因：创建用户流内部重新生成了 `user_id`，关系保存仍使用上游旧值。
- 规避：`create_user_flow` 结果 `save_field`，关系保存使用返回值。

2. 直属主管下拉“没数据”
- 原因：`select` 渲染配置与组件实际实现不匹配。
- 规避：统一改为标准 `label/value` 选项，简化 select 配置。

3. 角色写死无法动态化
- 原因：未将单值角色转换成 `role_id_list`。
- 规避：`field2array` 处理后传入 flow。

4. 备注不是文本域
- 原因：使用了错误字段（`type: textarea`）。
- 规避：使用 `isTextarea: true`。

## Debug Playbooks（实战排错剧本）

### A. 下拉“无数据/空白显示”
1. 看触发：确认 `reload-init-action` 是否触发了目标 group。
2. 看请求：确认接口返回 `data` 有值，且过滤条件正确（如 `role_type=supervisor`）。
3. 看适配：确认 `adapt` 输出是否为 `[{label,value}]`。
4. 看组件：确认 `select.options` 指向的是适配后的字段。
5. 看渲染：若用了 `optionRender`，确认回调上下文字段名与组件实现一致。

### B. 保存成功但列表不展示
1. 看写入链：确认主表与关系表都成功写入。
2. 看关键 ID：确认关系表外键 ID 能在主表查到（避免“旧 ID / 临时 ID”）。
3. 看查询 SQL：确认 join 条件与软删条件没有把数据过滤掉。
4. 看页面刷新：确认保存后触发了正确 `reload-init-action`。
5. 看过滤条件：确认当前页面筛选（agency/role/search）不会把新数据排除。

## Fast Debug Checklist
1. JSON 语法是否完整、括号/逗号是否正确。
2. `group` 名称是否拼写一致。
3. `reload-init-action` 是否只在必要动作触发。
4. `adapt` 输出字段 shape 是否匹配组件期望。
5. `listview keyField`、`selection`、下游查询主键是否统一。
6. `select options` 是否为标准 `[{label,value}]`。
7. 表单提交是否用 `appendFormFields`，并正确拼接额外参数。
8. 若配置拿不准：先看组件文档，再看源码实现，禁止猜配置。

## Practical Notes
- 优先复用页面内已有模式，避免引入新风格混用。
- 改动后先验证关键链路：打开页面 -> 查询 -> 新增/编辑 -> reload -> 展示。
- 遇到“看起来有数据但不显示”，优先怀疑数据 shape 与组件 props 不匹配。
