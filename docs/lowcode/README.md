# Lowcode 文档总览

- 模块处理器：`13`
- 数据处理器：`64`
- 模板 Filter：`31`

## 索引
- [module_registry.md](/data/project/auto-check/docs/lowcode/module_registry.md)
- [custom_filter_template.md](/data/project/auto-check/docs/lowcode/custom_filter_template.md)
- [filter_registry.md](/data/project/auto-check/docs/lowcode/filter_registry.md)
- [source_mapping.md](/data/project/auto-check/docs/lowcode/source_mapping.md)
- [frontend_ajax_row_value_guideline.md](/data/project/auto-check/docs/lowcode/frontend_ajax_row_value_guideline.md)
- filters 分类：
  - [identity_and_id.md](/data/project/auto-check/docs/lowcode/filters/identity_and_id.md)
  - [time_and_date.md](/data/project/auto-check/docs/lowcode/filters/time_and_date.md)
  - [string_and_text.md](/data/project/auto-check/docs/lowcode/filters/string_and_text.md)
  - [array_and_object.md](/data/project/auto-check/docs/lowcode/filters/array_and_object.md)
  - [math_and_cast.md](/data/project/auto-check/docs/lowcode/filters/math_and_cast.md)
  - [runtime_and_guard.md](/data/project/auto-check/docs/lowcode/filters/runtime_and_guard.md)

## 页面配置约束（新增）
- `tabs` 默认使用组件内部状态，不要在页面 store 中再维护 `activeKey` 并反向绑定到 `tabs.activeKey`。
- 禁止同时使用“组件内部 activeKey + 外部 update-store 控制 activeKey”的双控模式，容易导致 tab 内容看起来一致或切换错乱。
- `tabs.action` 里只放业务动作（例如切到 `call` 时发 HTTP 加载数据），不要再写 `employeeDetailTab = activeKey` 这类同步逻辑。
- `listview.itemAttr` 渲染统一使用 `row`，避免 `item/row` 混用导致字段取值错位。
- 行触发的 AJAX，如果字段不是用户编辑输入，优先从 `row/currentRow` 取值，不要依赖隐藏表单字段。详见 [frontend_ajax_row_value_guideline.md](/data/project/auto-check/docs/lowcode/frontend_ajax_row_value_guideline.md)。
