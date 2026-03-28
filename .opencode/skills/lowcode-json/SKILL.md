---
name: lowcode-json
description: 完整手册：低代码页面 JSON 的高频组件配置、联动规则、排错流程与源码核查规范。
---

## Purpose
- 让大模型在 `collect/frontend/page_data/**/*.json` 的改动中，快速做对常见组件与动作链配置。
- 降低“猜配置”导致的反复回归，改为“按文档+源码+DB实数确认后再落地”。

## Scope
- 主要目标：`collect/frontend/page_data/**/*.json`
- 关联核查：`collect/**/*.yml`、`collect/**/*.sql`（用于确认接口参数、SQL口径与数据 shape）

## Source Of Truth (拿不准先看这里)
1. 组件文档：`/data/project/collect-ui/docs/readme/components/*.md`
2. 组件源码：`/data/project/collect-ui/src/components/*/*.tsx`
3. 低代码配置：`collect/frontend/page_data/**/*.json`
4. 服务编排：`collect/**/*.yml`
5. Ajax 动作源码：`/data/project/collect-ui/src/action/ajax.tsx`
6. 表单项显隐实现：`/data/project/collect-ui/src/components/form/form-item.tsx`
7. 输入框实现（搜索/文本域）：`/data/project/collect-ui/src/components/input/input.tsx`
8. 下拉实现（optionRender/fieldNames）：`/data/project/collect-ui/src/components/select/select.tsx`

## Mandatory Workflow
1. 定位页面 JSON：找到 `initStore`、`actionGroupDefine`、目标组件节点。
2. 确认组件能力：先读 docs，再看组件源码（尤其 props 实现）。
3. 小步改动：一次只改一个行为链（渲染/提交/reload）。
4. 静态校验：JSON 结构、表达式、group 名称、字段名一致性。
5. 联动复核：检查“触发 -> 请求 -> adapt -> 展示/提交”的闭环。
6. 数据复核：遇到展示异常，必须核验 `JSON -> YML -> SQL -> DB实数` 全链路。

## Ajax 参数拼接规则（基于 `collect-ui/src/action/ajax.tsx`）
- 模块定位：`ajax` 是低代码请求核心模块，搜索/新增/编辑/删除都依赖它。
- 源码位置：`/data/project/collect-ui/src/action/ajax.tsx`
- 核心能力：变量解析、参数拼接、GET/POST 分流、下载处理、结果适配、成功/失败回调。

### 参数说明（高频）
- `api` / `url`：请求地址，支持 `post:/template_data/data?...`；`url` 是 `api` 别名。
- `appendFields`：从 store 拼字段（常用于 `page/size/count/pagination`）。
- `appendFormFields`：从表单拼字段（`store.getFormValue(formName)`，常用于 `search`、编辑值）。
- `data`：附加参数，支持对象或表达式字符串（常放上下文，如 `agency_id`）。
- `adapt`：响应字段写回 store（如 `list/count`）。
- `onSuccess` / `onError`：请求成功/失败后的动作链。
- `start` / `end`：请求前后更新状态（如 loading）。
- `showResultMsg`：成功后弹消息。
- `download` / `downloadingPercent`：文件下载与进度更新。

- 请求入参拼接顺序固定：
  1. `appendFields`
  2. `appendFormFields`
  3. `api.data`
  4. `data`
- 同名字段后者覆盖前者（例如 `search` 可由表单值覆盖 store 值）。
- 搜索推荐混用：
  - `appendFields`：分页状态（`page/size`）
  - `appendFormFields`：搜索表单值（`search`）

推荐模板：
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
- 输入：`isSearch: true`，回车触发 `onSearchAction`。
- `onSearchAction`：先 `update-store`（写 `search`、重置 `page=1`），再 `reload-init-action`。
- 请求层：`appendFields + appendFormFields`，避免“分页有值但搜索词丢失”。

### 常见坑
- 只写 `appendFields`，但输入未同步到 store：后台收不到搜索词。
- 只写 `appendFormFields`，但分页在 store：翻页参数丢失。
- `data` 覆写了同名字段：以为用表单值，实际被覆盖。

## Action Group Contract（必须写清楚）
- 每个 `actionGroupDefine.<group>` 写清：
  - `trigger`：由哪个动作触发。
  - `input`：依赖哪些 store 字段。
  - `output`：`adapt` 产出给谁消费。
- 一个 group 只做一件事（列表组只维护 list/count；下拉组只维护 options）。
- 依赖选中主键时必须加 `enable`（如 `currentAgency.agency_id`）。
- 禁止在一个 group 顺手更新无关域，避免串线。

## Backend Data定位 Playbook（新增）
目标：避免“看起来是前端问题，实际是后端口径问题”。

固定顺序（必须走完）：
1. 页面请求：确认 `service`、`appendFields`、`appendFormFields`、`data` 最终入参。
2. yml 入参：确认 `params` 定义与前端字段一致。
3. SQL 条件：确认 `where/join` 与业务口径一致（`status/is_delete/role_type`）。
4. DB 实数：查 summary + detail + 可见口径结果。
5. 页面展示：核对 `adapt` 字段与组件实际消费字段。

计数类专项：
- 检查统计 SQL 是否遗漏列表 SQL 的 join/过滤条件（典型：遗漏 `user_account.is_delete='0'`）。
- 明确口径：关系行数 / 可见成员数 / 去重成员数。
- 禁止前端“补差值”，必须修正后端统计口径。

## DB 只读排错模板（新增）
- 首选 `sqlite3`；若环境无命令，使用 Python `sqlite3` 只读查询。
- 输出固定三段：
  1. summary（按角色/状态聚合）
  2. detail（relation_id/user_id/role_type/status/create_time）
  3. visible（按页面 join 条件后的可见记录）
- 只读原则：排错阶段不写库、不改状态。

## Backend Schema & Model（auto-check 实战，新增）
目标：在本项目新增一张业务表时，确保“建表 -> model -> register -> service -> 页面”一次打通。

### 固定接入流程
1. 建表 SQL：在 `sql/` 下新增或追加版本脚本（避免直接改历史不可追踪脚本）。
2. Model 文件：在 `model/base`（或对应域目录）新增 `*.go`，包含结构体、`TableName()`、`PrimaryKey()`。
3. 注册模型：在 `model/register.go` 把新 model 加入注册列表。
4. 服务联动：在 `collect/**/*.yml` 定义 service，在 `collect/**/*.sql` 写查询/统计 SQL。
5. 页面联调：`collect/frontend/page_data/**/*.json` 的 `api/appendFields/appendFormFields` 与 yml `params` 对齐。

### 建表建议（最小模板）
```sql
create table if not exists demo_entity (
  entity_id varchar(64) primary key,
  entity_name varchar(255) not null default '',
  status varchar(32) not null default 'normal',
  create_time datetime not null default current_timestamp,
  create_user varchar(64) not null default ''
);
```

### Model 最小模板
```go
package base

const TableNameDemoEntity = "demo_entity"

type DemoEntity struct {
	EntityID   string `gorm:"column:entity_id;primaryKey" json:"entity_id"`
	EntityName string `gorm:"column:entity_name" json:"entity_name"`
	Status     string `gorm:"column:status" json:"status"`
	CreateTime string `gorm:"column:create_time" json:"create_time"`
	CreateUser string `gorm:"column:create_user" json:"create_user"`
}

func (*DemoEntity) TableName() string {
	return TableNameDemoEntity
}

func (*DemoEntity) PrimaryKey() []string {
	return []string{"entity_id"}
}
```

### Register 最小模板
```go
// model/register.go 中追加
new(base.DemoEntity),
```

### 后端联动核验点（必须逐项打勾）
1. 表结构字段名与 model tag 完全一致（大小写、下划线）。
2. yml `params` 与 JSON 传参一致（`agency_id/search/page/size` 等）。
3. list SQL 与 count SQL 过滤口径一致（`status/is_delete/role_type`）。
4. 新增/编辑返回字段满足下游依赖（关键 ID 需要 `save_field`）。
5. 页面 `adapt` 的字段 shape 与组件消费字段一致。

### 高发问题与处理
1. 表存在但查不到数据：先确认服务实际连的是哪一个数据库文件/实例。
2. 写入成功但页面无数据：优先查 where 条件与软删状态过滤。
3. 统计数与列表条数不一致：对比 list SQL 与 count SQL 的 join/where。
4. 有 relation 无用户展示：检查关联主键是否使用“创建返回的实际 ID”。

## Backend Low-Code Core Rules（必遵守，新增）
适用范围：`collect/**/*.yml`、`collect/**/*.sql`、`/data/project/collect/src/collect/service_imp/*`

### 1) `sql` 模块只做查询（禁止写操作）
- 注册定义在：`collect/service_router.yml`（`module_handler.sql -> SqlService`）。
- 实现源码在：`/data/project/collect/src/collect/service_imp/module_sql_service.go`。
- `SqlService` 底层固定是 `db.Query(...)` 取结果集，不是写入通道。
- 规则：`module: sql` 仅允许 `select` 语义；`insert/update/delete` 必须迁移到 `model_* / bulk_*` 模块。

### 2) 前端传简单数组时，后端先转对象数组
- 典型入参：`["a","b"]`。
- 统一先用 `arr2arrayObj` 转成：`[{"id":"a"},{"id":"b"}]`（字段名按业务定义）。
- 处理器源码：`/data/project/collect/src/collect/service_imp/handler_params_arr2array_obj.go`。
- 推荐配置（示例）：
```yml
handler_params:
  - key: arr2arrayObj
    foreach: "[route_id_list]"
    item: route_id
    fields:
      - field: route_id
        template: "{{.route_id}}"
      - field: agency_id
        template: "{{.agency_id}}"
      - field: sales_user_id
        template: "{{.sales_user_id}}"
    save_field: route_rel_list
```

### 3) 一个保存接口做“单服务聚合”，禁止拆成多个外层接口调用
- 错误模式：页面或上层服务先调 A 表保存，再调 B 关联保存（分两次 service 调用，易不一致）。
- 正确模式：一个 `save` 服务内聚合，使用 `handler_params`/`result_handler` 串起参数转换和结果处理。
- 允许在同一服务内用 `service2field` 做内聚编排，但对外只暴露一个保存入口。
- 核心目标：保证保存与关联写入在一个编排闭环，避免半成功。

### 4) 写操作模块选型（标准）
- 删除：`module: model_delete`（源码：`service_imp/model_delete.go`）。
- 批量新增：`module: bulk_create`（源码：`service_imp/module_bulk_create.go`）。
- 单条新增：`module: model_save`。
- 单条更新：`module: model_update`。
- 批量新增/更新：`module: bulk_upsert`。

### 5) 模块与数据处理器注册总入口
- 总入口文件：`collect/service_router.yml`（注意文件名是 `service_router.yml`）。
- `module_handler`：注册 `sql/model_save/model_update/model_delete/bulk_create/...`。
- `data_handler`：注册 `arr2arrayObj/field2array/service2field/result2params/...`。
- 运行时绑定逻辑：
  - `SetRegisterList`：`/data/project/collect/src/collect/service_imp/service_module_register.go`
  - 内置注册清单：`/data/project/collect/src/collect/service_imp/all_reqister.go`

### 后端配置排错清单（强制）
1. 先看 service `module` 是否选错（写操作误用 `sql`）。
2. 再看数组 shape：简单数组是否先经 `arr2arrayObj`。
3. 再看保存编排：是否由单一 `save` 服务统一处理。
4. 再看 `service_router.yml` 注册：key/path 是否存在且可加载。
5. 最后查 DB：校验主表、关联表、统计口径一致。

## High-Frequency Patterns

### 1) `layout-fit` 页面骨架
适用：列表+详情、左右分栏、管理页。

推荐：
- `initStore` 统一声明状态（当前选中、搜索、选择集、弹窗开关）。
- `children` 左 `listview`，右 `table + toolbar + dialog`。
- `actionGroupDefine` 分组管理查询与下拉加载。

禁止：
- 多处重复维护同一状态字段。
- 高频输入事件直接绑 reload 导致接口抖动。

### 2) `listview` 联动（重点）
适用：左侧组织/项目/分类切换。

必备：
- `keyField` 与主键一致。
- `itemData` 与数组字段一致。
- `rowClickAction` 同步更新：`currentX`、`selection`、关联查询条件。
- 切换后仅触发必要 group（如 `relationList`、`supervisorList`）。

禁止：
- `keyField`、`selection`、`current` 主键不一致。
- group 串线（在 A 组误刷新 B 组）。

### 3) `table` 列配置
适用：成员列表、管理列表。

推荐：
- 普通文本：`field + headerName`。
- 角色/状态：优先 `valueFormatter`（源码已支持模板表达式）。
- 操作列：按钮 + `confirm` + 成功后 `reload-init-action`。

示例：
```json
{
  "headerName": "角色",
  "field": "role_type",
  "valueFormatter": "${String(value||'').indexOf('supervisor')>=0?'主管':'销售'}"
}
```

`valueFormatter` 变量规则（必须）：
- 只能使用 `value` 与 `row`（来自 `collect-ui/src/components/table/table.tsx` 的模板执行环境）。
- 不要写 `params.value`、`params.data`，否则会执行失败或展示异常。

正确示例：
```json
{
  "headerName": "线路",
  "field": "route_names",
  "valueFormatter": "${String(row.role_type||'').indexOf('sales')>=0?(value||'-'):'-'}"
}
```

错误示例（禁止）：
```json
{
  "valueFormatter": "${params.data&&params.data.role_type==='sales'?(params.value||'-'):'-'}"
}
```

### 4) `form` 与提交
适用：新增/编辑弹窗。

推荐：
- 表单提交优先 `appendFormFields`。
- 非表单参数（如 `agency_id`）放 `data` 或 `appendFields`。
- 编辑先 `update-form` 回填，新增先 `reset-form`。
- 动态显隐用 `visible` + `getFormValue(...)`（先核对 `form-item` 源码支持）。

禁止：
- 先全量同步表单到 store 再发请求（中间态易错）。

### 5) `select`（重点）
适用：角色选择、主管选择。

推荐（最稳）：
- `options` 统一为 `[{label, value}]`。
- 在 `adapt` 完成 shape 转换。

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
- `fieldNames` 仅在必须保留非标准结构时使用。
- `optionRender` 前先核对组件回调上下文，禁止凭感觉写 `row.xxx`。
- 下拉数据来自列表接口时，默认 `pagination:false`、`count:false`。

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

### 6.1) `date`（新增，重点）
适用：日期筛选、分配日期、创建时间条件。

必须写：
```json
{
  "tag": "date",
  "valueFormat": "YYYY-MM-DD"
}
```

不要写：
- `tag: "date-picker"`（当前 collect-ui 组件实现不存在该 tag，页面会不展示控件）。

经验：
- `date` 组件值默认按 `YYYY-MM-DD` 处理；筛选表单建议显式写 `valueFormat`。
- 如果接口报“日期不能为空”，先检查搜索 form 是否有 `initialValues`，以及该字段是否在 `appendFormFields` 范围内。

### 7) Dialog 提交时序
适用：新增/编辑弹窗（含 `confirmAndContinue`）。

推荐顺序：
1. `submit-form`
2. `ajax`（`appendFormFields`）
3. `reload-init-action`（刷新列表/下拉）
4. `reset-form`（仅连续新增）
5. `update-store` 关闭弹窗（非连续新增）

## Service-Flow Coordination（与后端配置协同）

### 1) 返回值落盘必须显式保存
- `service2field` 后若下游复用关键字段（如 `user_id`），必须 `save_field`。
- 关系保存必须使用“创建流返回的实际 ID”，不要用上游临时字段。

### 2) 动态角色映射
- 前端传 `role_type`（`sales/supervisor`）。
- 用 `field2array` 转为 `role_id_list` 后再传用户创建流。

示例：
```yaml
- key: field2array
  field: "[role_type]"
  save_field: role_id_list
```

## JSON -> YML -> SQL 参数链核验
- JSON 参数名与 yml `params` 一致（拼写/大小写/路径）。
- yml 调下游 service 的字段与下游入参一致。
- SQL 过滤字段与 yml 传入字段一致（`agency_id/role_type/search`）。
- 表单提交优先 `appendFormFields`，上下文字段放 `data`/`appendFields`。
- 关键 ID 跨服务传递必须核验来源是否为“实际返回值”。

## Error Library（本次会话沉淀）
1. 关系表 `user_id` 与用户表不一致
- 原因：创建用户流内部重生 ID，关系仍写旧 ID。
- 规避：`create_user_flow` 结果 `save_field`，关系保存用返回值。

2. 直属主管下拉“没数据”
- 原因：`select` 配置与组件实现不匹配。
- 规避：统一 `options=[{label,value}]`，必要时再用 `fieldNames/optionRender`。

3. 角色写死无法动态化
- 原因：未把单值角色转换成 `role_id_list`。
- 规避：`field2array` 后传 flow。

4. 备注不是文本域
- 原因：使用 `type: textarea`。
- 规避：`isTextarea: true`。

5. 卡片“主管数”与右侧列表不一致
- 原因：统计 SQL 只看关系表，遗漏账号软删过滤。
- 规避：统计 SQL 对齐列表 SQL 口径（join + where 一致）。

6. 表单 `visible` 不生效
- 原因：未核对 `form-item` 实现支持字段/路径。
- 规避：先看源码，再选 `visible` 或兼容字段。

7. 搜索回车不生效/后台无搜索词
- 原因：缺 `onSearchAction` 或请求未拼接表单字段。
- 规避：`isSearch + onSearchAction` + `appendFields/appendFormFields` 闭环。

8. 日期框不展示（分配日期）
- 原因：低代码写成 `tag: date-picker`，但组件实现实际是 `tag: date`。
- 规避：统一改 `tag: date` 并补 `valueFormat: YYYY-MM-DD`；筛选表单补 `initialValues`。

9. `valueFormatter` 写了 `params` 导致显示异常/英文值直出
- 原因：table 组件模板执行仅注入 `row` 和 `value`，没有 `params`。
- 规避：统一改为 `${...value...}` 或 `${...row...}` 写法；提交前搜索 `params.value|params.data`。

10. `service2field` 返回数据理解错误导致错误添加 `.data`
- 原因：误以为 `save_field` 保存完整响应，实际只保存 `data` 字段内容。
- 规避：`save_field` 保存的是 `data` 字段，使用时直接使用 `[field]`。
- 示例错误：`field: "[phone_list.data]"`（错误添加 .data，phone_list 已经是数据本身）
- 示例正确：`field: "[phone_list]"`（phone_list 就是数据数组）

## Debug Playbooks（实战排错剧本）

### A. 下拉“无数据/空白显示”
1. 看触发：`reload-init-action` 是否触发目标 group。
2. 看请求：接口是否返回 `data`，过滤条件是否正确。
3. 看适配：`adapt` 是否输出 `[{label,value}]`。
4. 看组件：`select.options` 是否指向适配字段。
5. 看渲染：`optionRender` 回调上下文是否与源码一致。

### B. 保存成功但列表不展示
1. 看写入链：主表和关系表是否都写成功。
2. 看关键 ID：关系外键是否能在主表查到。
3. 看查询 SQL：join/软删条件是否过滤掉数据。
4. 看页面刷新：是否触发正确 group。
5. 看页面筛选：agency/role/search 是否排除了新数据。

### C. 卡片计数与列表条数不一致
1. 同对象分别跑“列表 SQL”和“统计 SQL”。
2. 对比 `where`：`status/is_delete/role_type/agency_id` 是否一致。
3. 对比 `join`：列表有 join 的过滤，统计是否漏掉。
4. 明确口径后改 SQL，禁止前端补差。

## Fast Debug Checklist
1. JSON 语法是否完整（括号/逗号/引号）。
2. `group` 名称是否一致。
3. `reload-init-action` 是否只在必要动作触发。
4. `adapt` 输出 shape 是否匹配组件期望。
5. `listview keyField`、`selection`、下游主键是否统一。
6. `select options` 是否标准 `[{label,value}]`。
7. 表单提交是否使用 `appendFormFields` 并拼接上下文。
8. 统计类问题是否对比过“列表 SQL vs 统计 SQL”口径。
9. 数据库排查是否遵守只读并输出 summary/detail/visible。
10. 拿不准先看 docs + 源码，禁止猜配置。

## Practical Notes
- 优先复用页面内已有模式，避免引入新风格混用。
- 改动后先验证关键链路：打开页面 -> 查询 -> 新增/编辑 -> reload -> 展示。
- “有数据不显示”优先查 shape 与组件 props 匹配。
- “展示数量不对”优先查统计 SQL 与列表 SQL 口径差异。

## API Debug Login Rule（新增）
- 调试任何 `http: true` 的业务服务前，先调用登录接口建立会话，否则会被 `handler_login_check` 拦截返回“请登录！！！”。
- 登录接口：`POST /template_data/data`，请求体示例：`{"service":"system.login","username":"admin","password":"123456"}`。
- 调试步骤固定：
  1. 先 `system.login` 保存 cookie/session。
  2. 再调用目标业务服务（同一 cookie）。
  3. 需要切账号时先 `system.logout` 或清理 cookie。
- 排错优先级：若返回“请登录！！！”，先判定为会话问题，不要先改业务服务。

## Customer Assign 排错补充（2026-03-24）
适用场景：`hrm.customer_lead_save_with_assign` 保存传了销售/线路，但 `hrm.customer_lead_list` 查询不展示。

1. `service2field enable` 布尔陷阱  
- 在当前引擎中，`enable: "{{and .sales_user_id .route_id}}"` 可能渲染为 UUID 字符串，随后被布尔转换为 `false`，导致子服务不执行。  
- 建议：要么写成严格布尔表达式（如 `must` 组合），要么直接去掉 `enable`，交给子服务 `check.must` 做必填拦截。

2. 主子服务 ID 必须贯穿  
- 组合保存场景中，子服务依赖父服务传入的 `lead_id`。  
- 若父服务内部又重新 `template: "{{uuid}}"` 生成了新 `lead_id`，会导致主表和关联表断链，查询 join 不到。  
- 规范写法：`lead_id` 参数使用“有值沿用、无值生成”，示例：`{{if .lead_id}}{{.lead_id}}{{else}}{{uuid}}{{end}}`。

3. Model 字段要与 DB 列对齐  
- 接口传参成功不代表落库成功；`model_save` 只会写 model 中存在的字段。  
- 本次问题中 `customer_lead_assign` model 缺少 `route_id`，导致线路始终为空。  
- 新增/改表字段后，必须同步 model 并回归查询。

4. 日期范围空数组兜底  
- 查询参数 `assign_date_range: []` 时，后端要有 start/end 默认值兜底，不能依赖前端必传。  
- 建议 SQL 入参模板使用“长度判定 + 默认边界日期”。

 5. 固定联调顺序（强制）
- 登录拿会话 -> 保存接口 -> 查询接口 -> 校验关键字段（`lead_id/assign_id/sales_user_id/route_id/route_name`）。  
- 不能只看保存返回 `success=true`，必须看查询结果是否能反查到刚写入的关联数据。

## Backend Low-Code Debugging Rules（后端低代码调试规则，新增）
适用场景：`collect/**/*.yml` 中的服务配置，特别是 `handler_params` 中的各种处理器。

### 1. service2field - 服务调用转字段
**错误用法**：
```yaml
- key: service2field
  service:
    service: spider_qi_work.login
    username: "{{.agency_info.wx_sync_account}}"  # ❌ 错误：使用模板变量
    password: "{{.agency_info.wx_sync_password}}"
```

**正确用法**：
```yaml
- key: service2field
  name: 重新登录获取token  # ✅ 添加name便于日志追踪
  service:
    service: spider_qi_work.login
    username: "[agency_info.wx_sync_account]"    # ✅ 正确：使用[字段引用]
    password: "[agency_info.wx_sync_password]"
  save_field: login_result
```

**关键规则**：
- service2field的参数必须使用 `[字段名]` 格式引用
- 禁止在service2field内部使用 `{{.字段名}}` 模板变量
- 使用 `name` 属性便于调试日志识别

### 2. result2params - 结果转参数
**错误用法**：
```yaml
- key: result2params
  fields:
    - from: "[login_result.data.access_token]"  # ❌ 错误：嵌套.data
      to: "[access_token]"
```

**正确用法**：
```yaml
- key: result2params
  name: 提取登录结果字段  # ✅ 添加name
  fields:
    - from: login_result.access_token  # ✅ 正确：直接字段路径
      to: access_token                 # ✅ 正确：直接字段名，不加[]
```

**关键规则**：
- `from` 字段：直接使用 `字段名.子字段`，不加 `[]`
- `to` 字段：直接使用字段名，不加 `[]`
- 服务返回的数据结构是扁平的，不需要 `.data` 嵌套

### 2.1 service2field 返回数据结构理解（重要经验）
**核心原则**：`service2field` 的 `save_field` 保存的是服务返回的 `data` 字段内容，而不是完整响应。HTTP 服务返回的结构是 `{data: ..., success: true, code: "0", msg: "成功"}`，但 `save_field` 只保存 `data` 部分。

**错误理解**：
```yaml
# ❌ 错误理解：认为 save_field 保存完整响应
save_field: phone_list  # 错误理解：phone_list = {data: [...], success: true, ...}
```

**正确理解**：
```yaml
# ✅ 正确理解：save_field 只保存 data 字段内容
save_field: phone_list  # 正确理解：phone_list = [...]（直接是 data 数组）
```

**错误模式**：
```yaml
# ❌ 错误：在内部使用时错误地添加 .data
- key: service2field
  service:
    service: spider_qi_work.query_user_wx
    authorization: "[token_data.data.access_token]"  # ❌ 错误：不应该加 .data
    companyId: "[token_data.data.companyId]"        # ❌ 错误：不应该加 .data
  save_field: phone_list

# ❌ 错误：在 param2result 中错误地添加 .data
- key: param2result
  field: "[phone_list.data]"  # ❌ 错误：phone_list 已经是数据本身
```

**正确模式**：
```yaml
# ✅ 正确：service2field 保存 data 字段内容
- key: service2field
  service:
    service: spider_qi_work.query_user_wx
    authorization: "[token_data.access_token]"  # ✅ 正确：直接使用 token_data
    companyId: "[token_data.companyId]"        # ✅ 正确：直接使用 token_data
  save_field: phone_list  # phone_list = [...]（直接是数据数组）

# ✅ 正确：内部使用时直接使用 field 对象
- key: param2result
  field: "[phone_list]"  # ✅ 正确：直接返回 phone_list

# ✅ 正确：在 handler_params 中传递时使用完整字段路径
- key: result2params
  fields:
    - from: phone_list  # ✅ 正确：直接使用 phone_list
      to: list
```

**经验总结**：
1. **HTTP 服务返回结构**：所有 HTTP 服务返回 `{data: ..., success: true, code: "0", msg: "成功"}`
2. **save_field 只保存 data**：`save_field` 保存的是 `data` 字段的内容，不是完整响应
3. **内部使用直接使用 field**：在 `handler_params` 内部传递时直接使用 `[field]`
4. **返回给调用方直接使用 field**：在 `param2result` 中返回 `[field]`
5. **不要手动加 .data**：`save_field` 已经自动提取了 `data` 字段

**常见场景**：
```yaml
# 场景1：获取 token 服务
- key: service2field
  service:
    service: hrm.get_qi_work_token
    agency_id: "[agency_id]"
  save_field: token_data  # token_data = {access_token: "...", companyId: ...}（data字段内容）

# 场景2：使用 token 调用其他服务  
- key: service2field
  service:
    service: spider_qi_work.query_user_wx
    authorization: "[token_data.access_token]"  # ✅ 正确：直接使用 token_data
    companyId: "[token_data.companyId]"        # ✅ 正确：直接使用 token_data
  save_field: user_list  # user_list = [...]（data字段内容）

# 场景3：返回数据给调用方
- key: param2result
  field: "[user_list]"  # ✅ 正确：直接返回 user_list
```

**关键理解**：
1. **服务返回**：`{data: 实际数据, success: true, code: "0", msg: "成功"}`
2. **save_field**：只保存 `data` 字段的内容
3. **引用方式**：直接使用 `[field]`，不需要 `.data`
4. **实际示例**：
   - 服务返回：`{data: [{phone: "13800138000", name: "张三"}], success: true}`
   - `save_field: phone_list` → `phone_list = [{phone: "13800138000", name: "张三"}]`
   - 使用：`[phone_list]` 得到 `[{phone: "13800138000", name: "张三"}]`

**验证方法**：
1. 查看服务实际返回结构
2. 理解 `save_field` 只保存 `data` 部分
3. 使用时直接引用 `[field]`，不加 `.data`
4. 如果返回空数据，检查服务是否真的返回了 `data` 字段

### 3. param2result - 参数转结果
**错误用法**：
```yaml
- key: param2result
  field: "[token_result]"  # ❌ 错误：使用[]包裹
```

**正确用法**：
```yaml
- key: param2result
  field: access_token  # ✅ 正确：直接字段名
```

**场景A：直接返回字段**
```yaml
- key: param2result
  name: 返回有效token数据
  field: agency_info.wx_sync_access_token
  to_field: access_token
```

**场景B：在result_handler中返回**
```yaml
result_handler:
  - key: param2result
    field: access_token
```

**关键规则**：
- `field` 属性：直接使用字段名或 `字段名.子字段`
- `to_field` 属性：指定返回结果的字段名
- 在 `result_handler` 中使用时，直接返回指定字段

### 4. 数据结构理解
- 服务返回的数据是扁平的：`login_result.access_token` 不是 `login_result.data.access_token`
- 数据库字段到接口参数的映射要一致：
  - 数据库：`wx_sync_access_token` (snake_case)
  - 接口参数：`access_token` (snake_case)
  - 保持命名一致性

### 5. 条件执行控制
```yaml
- key: service2field
  enable: "{{or (not .agency_info.wx_sync_access_token) (lt .agency_info.wx_sync_expire_time (unix_time 0 `second`))}}"
  name: Token无效时重新登录
```

**enable表达式要点**：
- 使用 `not` 判断字段是否存在
- 使用 `lt`/`gt` 比较时间戳
- `unix_time 0 'second'` 获取当前时间戳

### 6. 时间处理规范
```yaml
wx_sync_expire_time: "{{add (unix_time 0 `second`) .expires_in}}"
```
- `expires_in`：秒数
- `unix_time 0 'second'`：当前时间戳（秒）
- `add`：计算过期时间戳

### 7. 服务拆分原则
- **完整配置服务**：`travel_agency_wx_update` - 包含账号密码等所有字段
- **简化更新服务**：`travel_agency_wx_token_update` - 只更新token相关字段
- 根据使用场景选择服务，避免不必要的字段更新

### 8. 常见错误模式与修正

**错误模式1：service2field参数格式错误**
```yaml
# ❌ 错误
username: "{{.agency_info.wx_sync_account}}"

# ✅ 正确
username: "[agency_info.wx_sync_account]"
```

**错误模式2：result2params字段路径错误**
```yaml
# ❌ 错误
from: "[login_result.data.access_token]"

# ✅ 正确
from: login_result.access_token
```

**错误模式3：param2result字段格式错误**
```yaml
# ❌ 错误
field: "[access_token]"

# ✅ 正确
field: access_token
```

**错误模式4：不必要的arr2obj构建**
```yaml
# ❌ 过度设计
- key: arr2obj
  fields:
    - field: access_token
      value: "[access_token]"

# ✅ 简化设计
- key: param2result
  field: access_token
```

### 9. 调试流程
1. **检查字段引用格式**：确认所有 `[字段名]`、`字段名.子字段` 格式正确
2. **验证数据结构**：确认服务返回的数据结构是扁平的
3. **测试条件执行**：验证 `enable` 表达式是否正确
4. **查看执行日志**：通过 `name` 属性追踪每个步骤
5. **验证时间计算**：确认时间戳计算正确
6. **测试完整流程**：从开始到结束验证整个服务链

### 10. 最佳实践清单
1. **字段引用格式**：
   - service2field参数 → `[字段名]`
   - result2params from/to → `字段名.子字段` / `字段名`
   - param2result field → `字段名`

2. **添加调试信息**：
   - 每个处理器都添加 `name` 属性
   - 便于日志追踪和问题定位

3. **条件执行**：
   - 使用 `enable` 控制处理器执行
   - 清晰的逻辑表达式

4. **服务拆分**：
   - 完整配置服务 vs 简化更新服务
   - 根据场景选择

5. **时间处理**：
   - 统一使用秒级时间戳
   - 正确的计算表达式

6. **错误处理**：
   - 明确的错误消息
   - 合理的默认值

通过遵循这些规范，可以显著减少后端低代码配置的调试时间，提高开发效率。

## Go Model 文件生成规范（新增）
适用场景：使用 gorm.io/gen 工具自动生成 Model 文件，或手动编写 Model 结构体。

### 1. 自动生成 vs 手动编写
- **自动生成文件**：`.gen.go` 后缀，由 gorm.io/gen 工具从数据库表结构生成
- **手动编写文件**：普通 `.go` 后缀，需要手动维护
- **混合模式**：部分表使用自动生成，部分表手动编写（如 `travel_agency.go`）

### 2. ID 字段命名规范
**数据库表字段**：使用小写 + 下划线
```sql
wx_sync_company_id
wx_sync_department_id  
wx_sync_role_id
wx_sync_user_id
```

**Go Model 字段**：使用 PascalCase（首字母大写）
```go
WxSyncCompanyID    string `gorm:"column:wx_sync_company_id" json:"wx_sync_company_id"`
WxSyncDepartmentID string `gorm:"column:wx_sync_department_id" json:"wx_sync_department_id"`
WxSyncRoleID       string `gorm:"column:wx_sync_role_id" json:"wx_sync_role_id"`
WxSyncUserID       string `gorm:"column:wx_sync_user_id" json:"wx_sync_user_id"`
```

**关键规则**：
- Go 字段名中的 `ID` 必须大写（不是 `Id`）
- gorm tag 中的 `column` 必须与数据库字段名完全一致
- json tag 中的字段名通常与数据库字段名一致（小写+下划线）

### 3. 主键字段定义
**单主键**：
```go
AgencyID string `gorm:"column:agency_id;primaryKey" json:"agency_id"`
```

**复合主键**：
```go
// 在 PrimaryKey() 方法中返回多个字段
func (*TravelAgencyUserRel) PrimaryKey() []string {
    return []string{"relation_id"}  // 或返回多个字段
}
```

### 4. 字段类型映射
**常见映射关系**：
- 数据库 `VARCHAR` → Go `string`
- 数据库 `INT` → Go `int` 或 `int64`
- 数据库 `DATETIME` → Go `string`（存储为字符串）
- 数据库 `BOOLEAN` → Go `string`（通常用 "0"/"1" 或 "true"/"false"）

**可为空字段**：
```go
Description *string `gorm:"column:description" json:"description"`
```

### 5. 自动生成工具限制
**gorm.io/gen 工具特点**：
- 根据数据库表结构自动生成 Go 结构体
- 字段名自动转换为 PascalCase
- `ID` 后缀会自动转换为大写
- 生成的文件有 `// Code generated by gorm.io/gen. DO NOT EDIT.` 注释

**手动修改注意事项**：
- 不要直接修改 `.gen.go` 文件，重新生成会被覆盖
- 如果需要自定义逻辑，创建新的 `.go` 文件
- 在 `add_table.go` 中注册自定义 Model

### 6. Model 注册流程
**在 add_table.go 中注册**：
```go
// 注册自动生成的 Model
tableUserAccount := UserAccount{}
modelMap["user_account"] = tableUserAccount
primaryKeyMap["user_account"] = tableUserAccount.PrimaryKey()

// 注册手动编写的 Model  
travelAgency := TravelAgency{}
modelMap["travel_agency"] = travelAgency
primaryKeyMap["travel_agency"] = travelAgency.PrimaryKey()
```

**在 model/register.go 中调用**：
```go
baseTableMap, basePkMap := base.GetTable()
for k, v := range baseTableMap {
    modelMap[k] = v
}
for k, v := range basePkMap {
    primaryKeyMap[k] = v
}
```

### 7. 常见错误模式
**错误模式1：ID 字段命名不一致**
```go
// ❌ 错误：使用小写 id
WxSyncCompanyId string `gorm:"column:wx_sync_company_id" json:"wx_sync_company_id"`

// ✅ 正确：使用大写 ID
WxSyncCompanyID string `gorm:"column:wx_sync_company_id" json:"wx_sync_company_id"`
```

**错误模式2：gorm tag 与数据库字段名不匹配**
```go
// ❌ 错误：column 名称不匹配
WxSyncCompanyID string `gorm:"column:wx_sync_companyId" json:"wx_sync_company_id"`

// ✅ 正确：column 与数据库字段名一致
WxSyncCompanyID string `gorm:"column:wx_sync_company_id" json:"wx_sync_company_id"`
```

**错误模式3：未注册 Model**
```go
// ❌ 错误：创建了 Model 文件但未在 add_table.go 中注册
// 导致服务无法使用该 Model

// ✅ 正确：在 add_table.go 中注册
travelAgency := TravelAgency{}
modelMap["travel_agency"] = travelAgency
primaryKeyMap["travel_agency"] = travelAgency.PrimaryKey()
```

### 8. 最佳实践
1. **字段命名一致性**：
   - 数据库：`snake_case`
   - Go Model：`PascalCase`，`ID` 大写
   - JSON：通常与数据库一致（`snake_case`）

2. **类型选择**：
   - 主键、外键：使用 `string` 类型，存储 UUID
   - 状态字段：使用 `string` 类型，存储枚举值
   - 时间字段：使用 `string` 类型，存储格式化的时间字符串

3. **工具使用**：
   - 新表优先使用 gorm.io/gen 自动生成
   - 需要自定义逻辑时创建手动文件
   - 不要修改 `.gen.go` 文件

4. **注册验证**：
   - 新增 Model 后必须注册
   - 验证 `GetTable()` 函数包含新 Model
   - 验证 `model/register.go` 正确调用

### 9. 调试流程
1. **检查字段命名**：确认 Go 字段名使用 PascalCase，`ID` 大写
2. **验证 tag 一致性**：gorm column 与数据库字段名完全一致
3. **检查 Model 注册**：确认在 `add_table.go` 中注册
4. **测试 Model 使用**：通过服务调用验证 Model 可用性
5. **验证数据读写**：测试增删改查操作是否正常

通过遵循这些规范，可以确保 Go Model 文件与数据库结构保持一致，避免因字段命名或类型不匹配导致的数据读写问题。
