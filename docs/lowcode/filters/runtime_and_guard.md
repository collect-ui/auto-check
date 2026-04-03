# 运行时与校验 Filters

## `must`
- 用法：判断值是否非空
- 示例：`{{must .value}}`
- 注意：与 is_empty 互补，常用于参数必填校验

## `is_empty`
- 用法：判断值是否为空（空串/空数组/null）
- 示例：`{{is_empty .value}}`
- 注意：返回布尔值，常用于 if_template

## `get_key`
- 用法：读取系统配置 key
- 示例：`{{get_key "wechat_schedule_enable"}}`
- 注意：依赖配置中心，key 不存在返回空
