# `session_add`

- 名称：添加session
- 类型：inner
- 注册路径：`SessionAdd`
- 生命周期：在 `handler_params`/`result_handler` 中作为步骤执行（data_handler）。

## 常用场景
- 结合 `template` 与 `if_template` 进行参数渲染和流程控制。
- 与 `filter` 条件配合实现增量同步、字段映射和结果整形。

## 数据源映射
- 映射文档：`session_add` (`01044aa5-6f65-4b59-a4a9-ae7a0191be4c`)\n- 映射方式：`exact_title`\n- 文档明细：important=1 params=4 demo=0 result=0

## 关联 Filter
- 详见 [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)
