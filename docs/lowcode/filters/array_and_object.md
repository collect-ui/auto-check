# 数组与对象 Filters

## `contains`
- 用法：判断数组是否包含某值
- 示例：`{{contains .arr .target}}`
- 注意：数组元素类型需可直接比较

## `sub_arr`
- 用法：二维结构中取子数组字段
- 示例：`{{sub_arr .arr 0 "[children]"}}`
- 注意：索引越界会异常，先判断长度

## `sub_arr_attr`
- 用法：二维结构取某元素属性
- 示例：`{{sub_arr_attr .arr 0 "[children]" 1 "name"}}`
- 注意：越界时返回空串或"0"（按实现）

## `range_number`
- 用法：生成 0..n-1 数组
- 示例：`{{range_number 5}}`
- 注意：常配合 foreach 生成固定次数循环

## `first_item`
- 用法：取数组第一个元素
- 示例：`{{first_item .arr}}`
- 注意：空数组会越界，先用 must 判断

## `to_json`
- 用法：对象转 JSON 字符串
- 示例：`{{to_json .obj}}`
- 注意：序列化失败会返回空串
