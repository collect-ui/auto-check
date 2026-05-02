# 旅行社入住申请与账号绑定设计方案

## 1. 目标

新增一套“旅行社入住申请”能力，满足以下业务目标：

1. 提供一个免登录的旅行社入住申请页面，供旅行社自行提交入住信息。
2. 申请时必须填写现有系统账号密码，并调用现有登录能力校验账号密码是否正确。
3. 审核通过后，自动生成一条新的 `travel_agency` 数据，并将该旅行社绑定到对应 `user_account`。
4. 绑定后的旅行社账号继续复用现有登录逻辑，账号密码与申请时填写的用户账号保持一致。
5. 管理员新增一个专门的“入住申请管理”菜单，对申请做增删改查、审批通过、驳回。
6. 登录后的旅行社账号只可查看自己绑定的旅行社数据；管理员仍可查看全部旅行社数据。
7. 本次先落地文档；后续实现必须严格以本文档为准，并补齐可执行测试。

## 2. 现状结论

### 2.1 已有能力

当前仓库内已经存在以下可复用能力：

- `collect/system/login/index.yml`
  - `system.login`：系统登录接口。
- `collect/hrm/login/index.yml`
  - `hrm.system_login`：复用系统登录能力的业务登录入口，适合做账号密码校验。
- `collect/hrm/travel_org/index.yml`
  - 已有 `travel_agency_list / save / update / delete` 等旅行社主档服务。
- `collect/hrm/tencent_key/current_agency.sql`
  - 已有按当前登录用户查询所属旅行社的思路，依赖 `travel_agency_user_rel`。
- `collect/system/registration/index.yml`
  - 已有“免登录申请 + 后台审核”的设计范式，可复用到本需求。
- `collect/frontend/page_data/data/system/travel_org_manage.json`
  - 已有旅行社主档维护页面。

### 2.2 当前缺口

当前仓库内不存在以下能力：

- 独立的旅行社入住申请表。
- 独立的入住申请管理页面。
- 审批通过后自动创建旅行社并绑定用户的流程。
- 面向旅行社账号的数据范围限制服务。
- `travel_agency_user_rel` 的 Go 模型定义，当前只在 SQL 中被引用。

### 2.3 风险说明

当前仓库未定位到登录页对应的 page-data 文件，因此“登录页增加申请入口”属于联动项。后续实现时：

- 如果登录页源码在本仓库中定位到了，就在本仓库中改。
- 如果登录页源码属于共享运行时或其他仓库，则在对应源码位置补入口。
- 这不阻塞本功能主体的后端、页面和管理菜单设计。

## 3. 业务范围

### 3.1 本次纳入范围

- 免登录入住申请页面。
- 入住申请后台管理菜单。
- 申请单增删改查。
- 申请单审批通过、驳回。
- 审批通过后创建旅行社。
- 审批通过后绑定系统用户与旅行社关系。
- 旅行社相关页面按登录用户做数据范围控制。
- 文档内接口示例与测试用例。

### 3.2 本次不纳入范围

- 旅行社申请人自行查询申请进度。
- 旅行社申请人撤回申请。
- 多账号共同管理一个旅行社。
- 新建独立的“旅行社专用系统角色”。
- 修改现有同步逻辑的核心实现。

## 4. 关键业务规则

### 4.1 账号来源规则

- 申请时必须填写现有系统账号 `username` 和密码 `password`。
- 提交申请时必须调用 `hrm.system_login` 校验账号密码。
- 校验成功后，再通过 `hrm.user_list` 查询用户信息，取得 `user_id`。
- 本次不支持“申请时顺便创建新账号”。

### 4.2 旅行社与账号绑定规则

- 一个旅行社入住申请对应一个系统账号。
- 审核通过后，在 `travel_agency_user_rel` 中写入一条绑定关系。
- `role_type` 固定写入 `admin`，表示该用户是旅行社管理员账号。
- 如果该用户已有其他有效旅行社管理员绑定，则禁止再次审批通过。

### 4.3 审批规则

- 提交申请只生成申请单，不直接生成 `travel_agency`。
- 只有管理员审批通过后，才创建 `travel_agency`。
- 审批通过时再次校验：
  - 申请状态必须是 `pending`
  - `agency_code` 不能已存在于有效旅行社
  - `username/user_id` 不能已作为其他有效旅行社管理员绑定
- 审批驳回时必须填写驳回原因。

### 4.4 登录后可见范围规则

- `admin` 角色登录后：仍然可以查看全部旅行社数据。
- `company` 角色登录后：只能查看自己绑定的 `agency_id` 数据。
- 旅行社相关页面不得在前端做纯展示层过滤，必须通过后端可访问范围服务返回数据。

### 4.5 同步账号规则

- 审批通过后，`travel_agency.wx_sync_account = username`
- 审批通过后，`travel_agency.wx_sync_password = password`
- 该密码来源于申请时填写的原始密码，用于后续同步场景衔接。
- 管理页面列表与详情默认不明文展示申请密码。

## 5. 数据模型设计

## 5.1 新增表：`travel_agency_checkin_apply`

建议新增 Go 模型：`model/base/travel_agency_checkin_apply.go`

字段定义如下：

| 字段 | 类型建议 | 说明 |
| --- | --- | --- |
| `apply_id` | string | 主键，UUID |
| `agency_name` | string | 旅行社名称 |
| `agency_code` | string | 旅行社编码 |
| `contact_name` | string | 联系人 |
| `contact_phone` | string | 联系手机号 |
| `username` | string | 现有系统用户名 |
| `password` | string | 申请时填写的原始密码 |
| `user_id` | string | 通过用户名解析出的系统用户ID |
| `status` | string | `pending / approved / rejected` |
| `reject_reason` | string | 驳回原因 |
| `agency_id` | string | 审批通过后生成的旅行社ID |
| `create_time` | string | 创建时间 |
| `audit_time` | string | 审核时间 |
| `audit_user` | string | 审核人 |

约束要求：

- `apply_id` 主键。
- `status` 默认 `pending`。
- 建议对 `agency_code + status in (pending, approved)` 做业务唯一校验。
- 建议对 `username + status in (pending, approved)` 做业务唯一校验。

## 5.2 新增模型：`travel_agency_user_rel`

建议新增 Go 模型：`model/base/travel_agency_user_rel.go`

字段定义如下：

| 字段 | 类型建议 | 说明 |
| --- | --- | --- |
| `rel_id` | string | 主键，UUID |
| `agency_id` | string | 旅行社ID |
| `user_id` | string | 用户ID |
| `role_type` | string | 关系角色，首版固定 `admin` |
| `supervisor_user_id` | string | 预留字段，首版可为空 |
| `status` | string | 状态，默认 `normal` |
| `create_time` | string | 创建时间 |
| `create_user` | string | 创建人 |

要求：

- 注册到 `model/base/add_table.go`。
- 审批通过时通过低代码服务写入该表。

## 6. 后端服务设计

建议新增目录：`collect/hrm/travel_checkin/`

建议新增服务入口文件：`collect/hrm/travel_checkin/index.yml`

### 6.1 `hrm.travel_checkin_apply_submit`

用途：免登录提交入住申请。

接口规则：

- `http: true`
- `must_login: false`
- 入参：
  - `agency_name`
  - `agency_code`
  - `contact_name`
  - `contact_phone`
  - `username`
  - `password`

执行流程：

1. 校验必填参数。
2. 调用 `hrm.system_login` 校验账号密码。
3. 调用 `hrm.user_list` 获取用户，取 `user_id`。
4. 校验不存在同一 `agency_code` 的 `pending/approved` 申请。
5. 校验不存在同一 `username` 的 `pending/approved` 申请。
6. 校验该用户未作为其他有效旅行社管理员绑定。
7. 写入 `travel_agency_checkin_apply`。

返回：

- `apply_id`
- `status`
- `username`
- `agency_name`
- `agency_code`

注意：

- 列表或返回数据不得透出明文密码。

### 6.2 `hrm.travel_checkin_apply_list`

用途：管理员查询申请单。

入参：

- `search`
- `status`
- `page`
- `size`
- `pagination`
- `count`

搜索范围：

- `agency_name`
- `agency_code`
- `contact_name`
- `contact_phone`
- `username`

返回字段中密码必须脱敏或不返回。

### 6.3 `hrm.travel_checkin_apply_detail`

用途：管理员查看单条申请详情。

入参：

- `apply_id`

返回：

- 申请单完整业务字段
- `password` 不直接回传明文；若页面必须展示，只显示掩码

### 6.4 `hrm.travel_checkin_apply_update`

用途：管理员编辑申请单。

限制：

- 仅允许修改 `pending` 或 `rejected` 申请。
- 不允许修改 `approved` 申请。

可编辑字段：

- `agency_name`
- `agency_code`
- `contact_name`
- `contact_phone`
- `username`
- `password`

流程：

1. 校验 `apply_id`
2. 读取原申请单
3. 校验状态只允许 `pending/rejected`
4. 若 `username/password` 有变化，则重新调用 `hrm.system_login`
5. 更新申请单并同步 `user_id`

### 6.5 `hrm.travel_checkin_apply_delete`

用途：管理员删除申请单。

限制：

- 仅允许删除 `pending` 或 `rejected`
- `approved` 禁止删除

入参：

- `apply_id_list`

### 6.6 `hrm.travel_checkin_apply_approve`

用途：管理员审批通过。

入参：

- `apply_id`

流程固定如下：

1. 查询申请单，必须存在且状态为 `pending`
2. 校验 `agency_code` 未在有效 `travel_agency` 中占用
3. 校验 `user_id` 未在有效 `travel_agency_user_rel` 中作为 `admin` 占用
4. 调用 `hrm.travel_agency_save` 或新增专用内部服务创建旅行社：
   - `agency_name = 申请单.agency_name`
   - `agency_code = 申请单.agency_code`
   - `checkin_status = checked_in`
   - `wx_sync_enabled = no`
   - `wx_sync_account = 申请单.username`
   - `wx_sync_password = 申请单.password`
   - `description` 先置空
5. 向 `travel_agency_user_rel` 写入关系：
   - `agency_id`
   - `user_id`
   - `role_type = admin`
   - `status = normal`
6. 给该用户补 `company` 角色：
   - 已有则跳过
   - 没有则调用角色绑定服务补齐
7. 更新申请单：
   - `status = approved`
   - `agency_id = 新生成的agency_id`
   - `audit_time = 当前时间`
   - `audit_user = session_user_id`

返回：

- `apply_id`
- `agency_id`
- `status = approved`

### 6.7 `hrm.travel_checkin_apply_reject`

用途：管理员驳回。

入参：

- `apply_id`
- `reject_reason`

流程：

1. 校验申请存在
2. 校验当前状态为 `pending`
3. 写入：
   - `status = rejected`
   - `reject_reason`
   - `audit_time`
   - `audit_user`

### 6.8 `hrm.travel_agency_accessible_list`

用途：统一返回当前登录用户可访问的旅行社列表。

规则：

- 管理员：返回全部有效旅行社
- `company` 用户：只返回 `travel_agency_user_rel` 中绑定到当前 `session_user_id` 的旅行社

实现建议：

- 封装一个新的 SQL 服务，不直接复用前端拼过滤条件。
- 保留 `travel_agency_list` 作为通用后台服务，避免影响现有其他逻辑。

返回字段至少包含：

- `agency_id`
- `agency_name`
- `agency_code`
- `checkin_status`
- `wx_sync_enabled`
- `employee_count`

## 7. 前端页面设计

## 7.1 免登录申请页

建议页面编码：`frontend.travel_checkin_apply`

建议数据文件：`collect/frontend/page_data/data/system/travel_checkin_apply.json`

建议入口定义：

- 路由：`/travel_checkin_apply`
- `must_login: false`
- 不在左侧菜单显示

页面内容：

1. 标题区
   - 页面标题：`旅行社入住申请`
   - 说明：使用已有系统账号密码完成验证后提交
2. 表单区
   - 旅行社名称
   - 旅行社编码
   - 联系人
   - 联系手机号
   - 系统用户名
   - 系统密码
3. 操作按钮
   - 提交申请
   - 重置
4. 提交成功提示
   - `申请已提交，请等待管理员审核`

交互要求：

- 点击提交先做前端表单校验，再调用 `hrm.travel_checkin_apply_submit`
- 密码输入框必须为 `password` 类型
- 提交中按钮进入 loading，防止重复提交

## 7.2 管理员申请管理页

建议页面编码：`frontend.travel_checkin_manage`

建议数据文件：`collect/frontend/page_data/data/system/travel_checkin_manage.json`

建议菜单：

- `menu_code = travel_checkin_manage`
- `menu_name = 旅行社入住申请`
- 路由：`/framework/travel_checkin_manage`

页面固定功能：

1. 列表查询
   - 状态筛选
   - 关键字搜索
2. 列表字段
   - 申请状态
   - 旅行社名称
   - 旅行社编码
   - 联系人
   - 联系手机号
   - 账号
   - 创建时间
   - 审核时间
   - 审核人
3. 行操作
   - 查看详情
   - 编辑
   - 审批通过
   - 驳回
   - 删除
4. 批量操作
   - 批量删除（仅 `pending/rejected`）

页面约束：

- 不开放“管理员直接新增申请单”能力，申请来源固定为公共申请页。
- `approved` 状态行不展示编辑和删除。
- 驳回弹窗必须填写原因。
- 审批通过弹窗只做确认，不允许改业务字段。

## 7.3 登录页联动

登录页需新增一个入口按钮或链接：

- 文案：`旅行社入住申请`
- 跳转地址：`/travel_checkin_apply`

该改动若登录页源码不在本仓库，则作为联动任务在对应源码仓库执行。

## 8. 现有页面联动改造

以下页面涉及“当前旅行社”概念，后续实现需切换为基于 `hrm.travel_agency_accessible_list` 初始化：

- `collect/frontend/page_data/data/system/travel_org_manage.json`
- `collect/frontend/page_data/data/system/customer_assign_manage.json`
- `collect/frontend/page_data/data/system/tencent_key_apply.json`

### 8.1 `travel_org_manage`

必须处理的点：

- 去掉“当前仅支持维护一个旅行社”的文案假设
- 初始旅行社列表改为调用 `hrm.travel_agency_accessible_list`
- 管理员保持全部旅行社可见
- 旅行社账号只看到自己绑定的旅行社

### 8.2 `customer_assign_manage`

- 左侧旅行社列表改为调用 `hrm.travel_agency_accessible_list`

### 8.3 `tencent_key_apply`

- 当前旅行社解析保留现有逻辑或切换到统一可访问范围服务
- 保证旅行社账号只能对自己旅行社发起相关申请

## 9. 文件落地建议

后续正式实现时建议新增或修改以下文件：

### 9.1 文档

- `feature/travel_agency_checkin_design.md`
- `feature/travel_agency_checkin_request_examples.json`

### 9.2 模型

- `model/base/travel_agency_checkin_apply.go`
- `model/base/travel_agency_user_rel.go`
- `model/base/add_table.go`

### 9.3 低代码服务

- `collect/hrm/travel_checkin/index.yml`
- `collect/hrm/travel_checkin/travel_checkin_apply_list.sql`
- `collect/hrm/travel_checkin/travel_checkin_apply_count.sql`
- `collect/hrm/travel_checkin/travel_agency_accessible_list.sql`

### 9.4 前端 page-data

- `collect/frontend/page_data/index.yml`
- `collect/frontend/page_data/data/menu/menu.json`
- `collect/frontend/page_data/data/system/travel_checkin_apply.json`
- `collect/frontend/page_data/data/system/travel_checkin_manage.json`
- `collect/frontend/page_data/data/system/travel_org_manage.json`
- `collect/frontend/page_data/data/system/customer_assign_manage.json`
- `collect/frontend/page_data/data/system/tencent_key_apply.json`

## 10. 测试方案

## 10.1 后端服务测试

至少覆盖以下服务场景：

1. `travel_checkin_apply_submit`
   - 正确账号密码提交成功
   - 错误密码提交失败
   - 不存在账号提交失败
   - 重复 `agency_code` 提交失败
   - 重复 `username` 提交失败
2. `travel_checkin_apply_update`
   - `pending` 可编辑
   - `rejected` 可编辑
   - `approved` 不可编辑
   - 改密码后重新校验账号成功/失败
3. `travel_checkin_apply_delete`
   - `pending` 可删
   - `rejected` 可删
   - `approved` 不可删
4. `travel_checkin_apply_approve`
   - 成功生成旅行社
   - 成功写入绑定关系
   - 成功补 `company` 角色
   - 重复绑定失败
   - `agency_code` 冲突失败
5. `travel_checkin_apply_reject`
   - 待审驳回成功
   - 非待审驳回失败
6. `travel_agency_accessible_list`
   - 管理员看到全部
   - 旅行社账号只看到本社

## 10.2 页面联调测试

至少覆盖以下页面链路：

1. 公共申请页
   - 必填校验
   - 错误密码提示
   - 正确提交成功提示
2. 管理页
   - 列表加载
   - 查询/重置
   - 查看详情
   - 编辑待审申请
   - 驳回申请
   - 审批通过
   - 删除待审/驳回申请
3. 登录后范围验证
   - 管理员登录可见全部旅行社
   - 旅行社账号登录只见本社
   - 旅行社账号进入 `travel_org_manage` / `customer_assign_manage` / `tencent_key_apply` 均无越权数据

## 10.3 回归验证命令

后续实施完成后，按以下顺序至少执行：

1. `go test ./...`
2. `go vet ./...`
3. 若涉及 Go 文件改动，执行 `go fmt ./...`

说明：

- 当前仓库缺少系统化 `*_test.go`，因此 `go test ./...` 主要承担编译校验。
- 页面层需补接口联调和手工回归。

## 11. 实施顺序

后续编码实施顺序固定如下：

1. 新增模型与表注册
2. 新增申请服务与可访问范围服务
3. 新增免登录申请页与管理员管理页
4. 接入管理员菜单与公共路由
5. 调整现有旅行社相关页面的数据范围来源
6. 补服务回归与页面联调测试

## 12. 验收标准

满足以下条件才算完成：

1. 免登录申请页可正常提交申请。
2. 提交时必须校验现有账号密码，错误时不能落库。
3. 管理员能对申请单完成增删改查和审批。
4. 审批通过后自动生成旅行社并绑定用户。
5. 审批通过后旅行社同步账号密码与该用户账号密码一致。
6. 管理员登录后仍能查看全部旅行社。
7. 旅行社账号登录后只能查看自己绑定旅行社的数据。
8. 后端编译校验和页面联调测试通过。

