# `sql`

- 名称：执行sql 查询
- 类型：inner
- 注册路径：`SqlService`
- 生命周期：在 service 定义中作为 `module` 直接执行（module_handler）。

## 常用场景
- 结合 `template` 与 `if_template` 进行参数渲染和流程控制。
- 与 `filter` 条件配合实现增量同步、字段映射和结果整形。

## 数据源映射
- 映射文档：`sql` (`ccc4f5b6-2e98-4692-9e6b-333c1ab404e0`)\n- 映射方式：`exact_title`\n- 文档明细：important=5 params=6 demo=9 result=0

## 关联 Filter
- 详见 [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)
