# 月度逃单体检

## 文档头
- 功能名称：月度逃单体检
- 当前状态：进行中
- 当前阶段：接口联调进行中，预览链路已打通，主流程卡在同步转写耗时
- 最后更新时间：2026-04-24
- 下一个动作：继续跟进 `detect_escape_health_order_and_save` 的同步/转写长耗时，并完成最终回写验证

## 背景与目标
- 现有普通逃单分析默认只分析最近 2 天数据，不满足月度体检需求。
- 现有同步默认也是短窗口，无法支撑单员工 30 天体检。
- 30 天聊天与电话数据量过大，不能一次性直接送大模型。
- 目标是新增“个人体检”能力：
  - 先同步该员工最近 30 天数据
  - SQL 先产出 chunk_list
  - 使用 bulk_service 逐片分析
  - 最后再做一次汇总分析
  - 回写现有逃单结果、分析日志、待处理工单

## 产品需求
### 入口需求
- 复用“预览提示”按钮，支持：
  - 普通提示
  - 体检提示
- 复用“个人分析”按钮，支持：
  - 普通分析
  - 个人体检

### 体检流程需求
- 体检固定看最近 30 天数据。
- 体检必须先同步，再分片，再逐片调用模型，再汇总。
- 不允许直接把 30 天全量聊天/电话一次性发送给大模型。
- 联调阶段临时增加 `skip_sync=1`，仅用于跳过慢速同步/转写，验证分析与回写主链路。

### 结果需求
- 复用当前员工字段：
  - `escape_is_escape`
  - `escape_ai_content`
  - `escape_last_analyze_time`
- 复用 `travel_escape_analyze_log`
- 复用 `travel_escape_issue`

### 分片需求
- SQL 先产出 `chunk_list`
- `bulk_service` 对 `chunk_list` 逐条调用单片分析
- 最终 merge 只吃各分片分析结果，不再吃 30 天原始明细

### 阈值需求
- 单条聊天文本阈值做成可配置参数
- 默认值：`100000`
- 仅在体检模式启用

## 当前事实与样本数据
- 普通分析默认 `days=2`
- 体检时间窗口固定最近 30 天
- 当前底层已支持单员工同步：
  - `sync_chat_contact`
  - `sync_chat_record`
  - `sync_call_record`
  - `gen_file_text`
  - `gen_call_record_text`
- 样本员工：
  - `employee_id=fa5367a6-8d4c-4b23-afe1-5384dfb039f3`
- 已确认样本数据：
  - 最近 30 天聊天：390 条
  - 最近 30 天电话：0 条
  - 联系人：32 个
  - 原始文本总量约：33119 字符
  - 高峰日：
    - 2026-04-23：136 条
    - 2026-04-24：82 条
- 当前预估分片规模：6~7 片

## 方案设计
### 后端
- 新增 `hrm.sync_employee_all_for_health`
- 新增 `hrm.detect_escape_health_chunk_plan`
- 新增 `hrm.detect_escape_health_chunk_prepare_one`
- 新增 `hrm.detect_escape_health_chunk_prepare_bulk`
- 新增 `hrm.detect_escape_health_chunk_analyze_one`
- 新增 `hrm.detect_escape_health_chunk_analyze_bulk`
- 新增 `hrm.detect_escape_health_merge`
- 新增 `hrm.detect_escape_health_prompt_preview`
- 新增 `hrm.detect_escape_health_order_and_save`

### 分片逻辑
- 最近 30 天按天聚合数据
- SQL 输出 `chunk_list`
- 分片阈值：
  - `max_days_per_chunk=0`
  - `0` 表示默认不按固定天数强切，优先按时间连续性分配
  - `max_chat_count_per_chunk=120`
  - `max_call_count_per_chunk=20`
  - `max_chat_chars_per_chunk=12000`
  - `max_call_chars_per_chunk=6000`
- 单条聊天文本阈值：
  - `single_chat_text_limit=100000`

### 前端
- 原“预览提示”按钮改为先选模式
- 原“个人分析”按钮改为先选模式
- 体检预览展示：
  - 时间范围
  - 分片数量
  - 单条聊天文本阈值
  - 每片 prompt
  - 汇总提示模板

## 开发任务拆解
| ID | 模块 | 任务 | 说明 | 状态 | 负责人 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| BE-01 | detect_escape | 增加体检范围查询参数 | 聊天/电话 SQL 支持 start/end 与单条文本阈值 | done | Codex | 已完成 |
| BE-02 | sync_agency_data | 新增单员工30天同步服务 | 同步聊天、电话、附件转写、电话转写 | done | Codex | 已完成 |
| BE-03 | detect_escape | 新增 chunk plan SQL | SQL 生成 chunk_list | done | Codex | 已完成 |
| BE-04 | detect_escape | 新增单片提示准备服务 | 单片 prompt 组装 | done | Codex | 已完成 |
| BE-05 | detect_escape | 新增 bulk 单片分析 | bulk_service 跑单片分析 | done | Codex | 已完成 |
| BE-06 | detect_escape | 新增汇总分析服务 | 只吃 chunk 结果做最终总结 | done | Codex | 已完成 |
| BE-07 | detect_escape | 新增体检总流程 | 同步、分片、分析、回写、建工单 | done | Codex | 已完成 |
| FE-01 | travel_org_manage | 增加预览模式选择 | 普通提示/体检提示 | done | Codex | 已完成 |
| FE-02 | travel_org_manage | 增加分析模式选择 | 普通分析/个人体检 | done | Codex | 已完成 |
| FE-03 | travel_org_manage | 扩展体检预览弹框 | 展示 chunk 与汇总模板 | done | Codex | 已完成 |
| QA-01 | backend | YAML/JSON 结构校验 | detect_escape、sync、页面 JSON | done | Codex | YAML/JSON 与 go test 已通过 |
| QA-02 | backend | SQL 分片联调 | 用样本员工检查 chunk 结果 | done | Codex | 样本员工按新规则切出 9 片 |
| QA-07 | backend | 分片规则单测 | 连续天合并、时间断层拆片、超阈值拆片 | done | Codex | `go test ./internal/healthchunk ./...` 已通过 |
| QA-03 | backend | bulk 单片分析联调 | 检查逐片分析结果 | done | Codex | `chunk_analyze_one`、`chunk_analyze_bulk` 已通过 |
| QA-04 | backend | 汇总分析联调 | 检查最终汇总结论 | doing | Codex | 批量分析已通，待主流程完整回写收口 |
| QA-05 | frontend | 页面联调 | 模式切换、预览、个人体检 | todo |  |  |
| QA-06 | regression | 普通逃单回归 | 普通预览、普通个人分析、分析记录 | todo |  |  |
| DOC-01 | feature | 持续维护本文件 | 任务状态、进度、回归记录同步更新 | doing | Codex | 当前进行中 |

## 开发进度
### 已完成
- 体检后端主链路和 chunk 规划服务已接入
- 单员工 30 天同步服务已接入
- 前端模式选择与体检预览区块已接入
- feature 跟踪文档已建立
- `collect/hrm/detect_escape/index.yml`、`collect/hrm/sync_agency_data/index.yml`、页面 JSON 结构校验已通过
- `go test ./...` 已通过
- 样本员工最近 30 天分片 SQL 已验证，按新规则当前切分结果为 9 片
- 分片纯算法单测已补齐，覆盖连续时间合并、时间断层拆片、超阈值拆片

### 当前进行中
- 联调 `detect_escape_health_order_and_save`，定位同步与转写耗时
- 已补 `skip_sync=1` 临时调试开关，便于绕过同步验证后半链路

### 下一个动作
- 在主流程上验证汇总回写
- 评估是否为体检主流程增加“跳过同步/转写”的调试入口
- 主流程后半段已验证可进入批量模型分析

## 测试计划
### 1. SQL 分片测试
目标：确认 SQL 输出的是 chunk_list，而不是原始消息明细。

前置条件：
- 员工 `fa5367a6-8d4c-4b23-afe1-5384dfb039f3` 在本地库存在最近 30 天聊天数据。

步骤：
1. 调用 `hrm.detect_escape_health_chunk_plan`
2. 传入样本员工 `employee_id`
3. 检查返回是否为多条 chunk
4. 检查 chunk 是否升序
5. 检查是否无重叠无遗漏
6. 检查高峰日是否单独成片

预期结果：
- 返回多条 chunk 数据
- 不是原始聊天明细

实际结果：
- 已执行：样本员工按“时间连续优先、超阈值再拆”规则切分为 9 片
- 已补单测覆盖：
- 连续日期合并为单片
- 存在时间断层时拆片
- 聊天量超阈值时拆片

状态：
- done

### 2. 单片分析测试
目标：确认单片分析只处理一个 chunk。

前置条件：
- 已拿到 chunk_list

步骤：
1. 取 chunk_list 第 1 条
2. 调 `hrm.detect_escape_health_chunk_analyze_one`
3. 检查只读取该时间范围数据
4. 检查 prompt 是否包含 chunk 编号与时间范围
5. 检查返回是否包含单片结构化结果

预期结果：
- 单片分析仅对本片负责

实际结果：
- 已执行：
- `hrm.detect_escape_health_chunk_analyze_one` 已成功返回单片分析结果
- `hrm.detect_escape_health_chunk_analyze_bulk` 已成功返回嵌套的 `analyze_result`
- 当前单片样本结论为“无逃单”

状态：
- done

### 3. bulk_service 分片测试
目标：确认体检核心链路是 bulk_service + 单片分析。

步骤：
1. 把完整 `chunk_list` 传给 `hrm.detect_escape_health_chunk_analyze_bulk`
2. 检查返回条数是否等于 chunk 数
3. 检查每条结果是否保留 chunk_no
4. 检查是否存在逐条分析结果

预期结果：
- bulk_service 逐片分析成功

实际结果：
- 已执行：
- `hrm.detect_escape_health_chunk_analyze_bulk` 已成功逐片调用单片分析
- 当前 bulk 外层返回结构为数组，单项内包含 `analyze_result`，其内容类型为 `*collect.Result`

 状态：
- done

### 6. 体检预览联调测试
目标：确认 `hrm.detect_escape_health_prompt_preview` 能返回分片提示词列表。

实际结果：
- 已执行：`hrm.detect_escape_health_prompt_preview` 成功返回 9 条 `chunk_prompt_list`
- `hrm.detect_escape_health_chunk_prepare_bulk` 已成功返回分片提示词数组

状态：
- done

步骤：
1. 调用 `hrm.detect_escape_health_prompt_preview`
2. 检查 `chunk_list`
3. 检查 `chunk_prompt_list`
4. 检查汇总模板

预期结果：
- 能返回 `chunk_list` 与扁平化后的 `chunk_prompt_list`

实际结果：
- `chunk_list` 正常返回，当前为 9 片
- `merge_prompt_template` 正常返回
- `chunk_prompt_list` 当前仍为 `null`
- 运行日志已定位到剩余问题：`update_array` 中 `.item.prepare_result` 为 `*collect.Result`，模板取值语法尚未兼容

状态：
- doing

### 4. 汇总测试
目标：确认最终汇总只读取 chunk 结果。

步骤：
1. 准备 chunk 分析结果
2. 调 `hrm.detect_escape_health_merge`
3. 检查提示词是否只基于分片分析结果
4. 检查输出首行格式是否兼容现有逃单判定

预期结果：
- 汇总不再直接读取 30 天原始消息

实际结果：
- 待执行

状态：
- todo

### 5. 主流程联调测试
目标：确认个人体检完整走通。

步骤：
1. 调 `hrm.detect_escape_health_order_and_save`
2. 检查是否先同步 30 天数据
3. 检查是否生成 chunk_list
4. 检查是否逐片分析
5. 检查是否最终汇总
6. 检查员工分析结果是否回写
7. 检查分析日志是否新增
8. 检查工单是否按规则创建

预期结果：
- 顺序为：同步 -> 分片 -> 单片分析 -> 汇总 -> 回写

实际结果：
- 待执行

状态：
- todo

### 6. 页面测试
目标：确认页面模式切换和预览展示正确。

步骤：
1. 打开 `travel_org_manage`
2. 选择员工
3. 点击“预览提示”
4. 选择“体检提示”
5. 检查 chunk 信息和汇总模板是否展示
6. 点击“个人分析”
7. 选择“个人体检”
8. 检查完成后列表是否刷新

预期结果：
- 模式切换正常
- 体检预览正常

实际结果：
- 待执行

状态：
- todo

### 7. 回归测试
目标：确认普通逃单分析不受影响。

步骤：
1. 执行普通预览提示
2. 执行普通个人分析
3. 查看分析记录
4. 查看工单
5. 检查现有全量分析/定时分析入口

预期结果：
- 旧功能保持不变

实际结果：
- 待执行

状态：
- todo

## 回归记录
### 第1轮
- 日期：2026-04-24
- 范围：YAML/JSON 结构校验、go test、样本分片 SQL
- 结果：通过
- 问题列表：bulk_service 扁平化结构仍需接口联调确认
- 是否允许进入下一阶段：允许进入接口联调

## 风险与阻塞
- bulk_service 返回结构需要确认是否完全符合当前扁平化逻辑
- 前端 JSON 表达式需要确认运行时兼容性
- 30 天同步耗时可能偏长
- 高峰日消息可能使单片 prompt 仍偏大，需要继续观察
- 体检日志当前只记录最终汇总，不记录每片明细

## 变更记录
- 2026-04-24 / Codex / 新建月度逃单体检 feature 跟踪文档，并录入当前实现与测试计划
- 2026-04-24 / Codex / 同步结构校验结果、go test 结果和样本员工 7 片分片验证结果
