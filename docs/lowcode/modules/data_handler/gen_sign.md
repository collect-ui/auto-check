# `gen_sign`

- 名称：文件转字符串
- 类型：outer
- 注册路径：`GenSign`
- 生命周期：在 `handler_params`/`result_handler` 中作为步骤执行（data_handler）。

## 常用场景
- 结合 `template` 与 `if_template` 进行参数渲染和流程控制。
- 与 `filter` 条件配合实现增量同步、字段映射和结果整形。

## 数据源映射
- 映射文档：未命中（建议在 collect_doc 补充模块说明）

## 关联 Filter
- 详见 [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)
