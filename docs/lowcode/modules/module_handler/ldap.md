# `ldap`

- 名称：发送ldap请求
- 类型：inner
- 注册路径：`LdapService`
- 生命周期：在 service 定义中作为 `module` 直接执行（module_handler）。

## 常用场景
- 结合 `template` 与 `if_template` 进行参数渲染和流程控制。
- 与 `filter` 条件配合实现增量同步、字段映射和结果整形。

## 数据源映射
- 映射文档：`ldap` (`9215873e-d44d-4a8f-b243-f2c45b1833e5`)\n- 映射方式：`exact_title`\n- 文档明细：important=2 params=12 demo=10 result=0

## 关联 Filter
- 详见 [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)
