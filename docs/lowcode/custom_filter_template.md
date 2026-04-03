# 模板自定义 Filter 指南

Filter 在 `template`、`if_template` 中调用，例如：
- `template: "{{uuid}}"`
- `if_template: "{{must .agency_id}}"`
- `template: "{{unix_time -1 `day`}}*1000"`

## 生命周期位置
- `params`：初始化默认值和计算字段。
- `handler_params`：步骤执行前后数据加工。
- `result_handler`：返回结果整形。
- `filter`/`if_template`：条件分支、增量过滤。

## 可用 Filter 清单
共 `31` 个，详见 [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)。

## 常见坑
- `unix_time` 是秒级，毫秒请手动 `*1000`。
- `first_item` 对空数组无保护，先 `must` 再取值。
- `join` 期望字符串数组，混合类型可能报错。
- 组合键匹配时注意 `field/right_field` 方向不要写反。