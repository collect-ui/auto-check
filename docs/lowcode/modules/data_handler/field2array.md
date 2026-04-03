# `field2array`

- 名称：字段转数组
- 类型：inner
- 注册路径：`Field2Array`
- 生命周期：在 `handler_params`/`result_handler` 中作为步骤执行（data_handler）。

## 常用场景
- 结合 `template` 与 `if_template` 进行参数渲染和流程控制。
- 与 `filter` 条件配合实现增量同步、字段映射和结果整形。

## 数据源映射
- 映射文档：`field2array` (`eee7f650-4583-4bf6-b770-ce853eba8c54`)\n- 映射方式：`exact_title`\n- 文档明细：important=2 params=2 demo=1 result=0

## 关联 Filter
- 详见 [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)
