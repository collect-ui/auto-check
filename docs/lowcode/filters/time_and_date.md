# 时间与日期 Filters

## `current_date_time`
- 用法：返回当前时间字符串
- 示例：`{{current_date_time}}`
- 注意：格式受后端实现控制，通常 yyyy-MM-dd HH:mm:ss

## `current_date_format`
- 用法：按格式返回当前时间
- 示例：`{{current_date_format "20060102"}}`
- 注意：格式使用 Go time layout 规则

## `unix_time`
- 用法：返回 Unix 秒级时间戳（可带偏移）
- 示例：`{{unix_time -1 `day`}}`
- 注意：秒级；如需毫秒需手动 *1000

## `unix_time2datetime`
- 用法：Unix 秒转时间字符串
- 示例：`{{unix_time2datetime .ts}}`
- 注意：输入应为秒级 int64

## `date_format`
- 用法：时间字符串格式化为 yyyy-MM-dd HH:mm:ss
- 示例：`{{date_format .timeStr "2006-01-02T15:04:05Z07:00"}}`
- 注意：解析失败返回空串
