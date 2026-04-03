# 数值与类型 Filters

## `cast`
- 用法：类型转换 int/int64/float/float64
- 示例：`{{cast .value "int64"}}`
- 注意：不支持的类型原样返回

## `multiply`
- 用法：乘法，返回保留2位小数字符串
- 示例：`{{multiply 2 3}}`
- 注意：返回字符串，不是数字类型

## `divide`
- 用法：除法，返回保留2位小数字符串
- 示例：`{{divide 10 4}}`
- 注意：除数为 0 风险需在外层避免

## `random_int`
- 用法：生成随机整数[min,max]
- 示例：`{{random_int 1 10}}`
- 注意：每次渲染都会变化，不适合幂等字段
