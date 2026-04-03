# `bulk_upsert`

- 名称：批量新增
- 类型：inner
- 注册路径：`BulkUpsertService`
- 生命周期：在 service 定义中作为 `module` 直接执行（module_handler）。

## 常用场景
- 结合 `template` 与 `if_template` 进行参数渲染和流程控制。
- 与 `filter` 条件配合实现增量同步、字段映射和结果整形。

## 数据源映射
- 映射文档：`bulk_upsert` (`803b90d9-c58c-4113-b4c0-58782e03142c`)\n- 映射方式：`exact_title`\n- 文档明细：important=1 params=6 demo=1 result=0

## 关联 Filter
- 详见 [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)
