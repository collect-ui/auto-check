# `model_save` `deepseek_api_key` 保存异常排查与修复测试方案

## 1. 问题定义

- 目标服务：`hrm.travel_agency_save_raw`
- 目标字段：`deepseek_api_key`
- 预期：入参传 `"deepseek_api_key":"t"` 后，`travel_agency.deepseek_api_key` 落库为 `t`。

最小复现请求体（用户提供）：

```json
{
  "agency_code": "t11",
  "agency_id": "38ac74cd-5672-4e00-9515-c007d1f7b5671",
  "agency_name": "t1",
  "biz_type": "travel",
  "checkin_status": "checked_in",
  "deepseek_api_key": "t",
  "description": "入住申请审批通过自动创建",
  "escape_repeat_ad_keywords": null,
  "escape_system_prompt": "",
  "escape_user_prompt": "",
  "logo_path": null,
  "service": "hrm.travel_agency_save_raw",
  "status": "normal",
  "wx_last_sync_time": null,
  "wx_sync_access_token": null,
  "wx_sync_account": "jinyou888",
  "wx_sync_company_id": null,
  "wx_sync_department_id": null,
  "wx_sync_enabled": "yes",
  "wx_sync_error_count": 0,
  "wx_sync_expire_time": 0,
  "wx_sync_password": "jinyou@888",
  "wx_sync_role_id": null,
  "wx_sync_user_id": null
}
```

## 2. 关键定位点

服务定义：
- `collect/hrm/travel_org/index.yml` -> `key: travel_agency_save_raw`

模型定义：
- `model/base/travel_agency.go` -> `DeepseekAPIKey string gorm:"column:deepseek_api_key" json:"deepseek_api_key"`

执行模块：
- `module: model_save`
- 代码：`/data/project/collect/src/collect/service_imp/module_model_save.go`

字段映射逻辑：
- `SetDataValueByParams`：`/data/project/collect/src/collect/utils/utils.go`
- snake_case -> CamelCase（含缩写规则 `API`）：`ToSchemaName`

## 3. 测试策略（必须可重复）

### 3.1 基线校验

先查目标记录（示例）：

```bash
sqlite3 /data/project/auto-check/database/auto_check.db \
"SELECT agency_id,agency_code,deepseek_api_key,create_time,create_user
 FROM travel_agency
 WHERE agency_id='1ddef044-67e3-46b3-b47e-5e7f6595a383';"
```

### 3.2 临时日志（仅定位时开启）

在 `module_model_save.go` 中临时打印：
- `table`
- `service`
- `params["deepseek_api_key"]`
- 映射后模型字段值（`DeepseekAPIKey`）

注意：
- 仅定位时开启
- 完成后必须回滚日志代码

### 3.3 调用与核对

建议用本地 `TemplateService` 直调（避免 HTTP 层干扰），调用 `hrm.travel_agency_save_raw` 后立刻查询：

```bash
sqlite3 /data/project/auto-check/database/auto_check.db \
"SELECT agency_id,agency_code,deepseek_api_key,create_time,create_user
 FROM travel_agency
 WHERE agency_code='t11'
 ORDER BY create_time DESC
 LIMIT 5;"
```

至少重复 3 次，确认非偶现。

### 3.4 回滚临时日志

定位结束后，删除 `model_save` 临时日志并重启服务，确保主干代码干净。

## 4. 本次执行记录（2026-05-01）

### 4.1 查询用户指定记录

对 `agency_id=1ddef044-67e3-46b3-b47e-5e7f6595a383` 的数据库查询结果为：
- `deepseek_api_key` 为空（确认为空值，不是查询显示问题）

### 4.2 直调最小请求体复测

使用与用户一致的最小 JSON（含 `deepseek_api_key: "t"`）直调 `hrm.travel_agency_save_raw`：
- 服务返回：`success=true`
- 紧接 `travel_agency_list` 查询：`deepseek_api_key=t`
- 数据库落库值与查询一致

### 4.3 结论

`model_save` 对 `deepseek_api_key` 的基础写入链路可正常工作。  
出现“某条记录为空”时，需要继续沿业务链追踪该记录是否被后续服务更新为空（例如其它 `model_update`/流程服务写回）。

## 5. 后续修复建议（防止再次误判）

1. 在相关业务流（审批通过链路）加入一次写后读校验（仅 debug 环境）。
2. 对关键字段增加“空值覆盖保护”开关（可配置）：当旧值非空且新值空时拒绝覆盖并告警。
3. 增加一个固定回归脚本：`save_raw -> list -> sqlite` 三段式校验，作为发布前 smoke test。

