# Lowcode Frontend AJAX 取值规范

适用范围：

- `collect/frontend/page_data/**/*.json`
- 所有由表格行、卡片行、列表项触发的弹窗提交、状态切换、删除、审核、撤销等 AJAX 动作

## 核心原则

1. 非表单字段，优先从 `row` 或点击时保存的当前行对象中取值。
2. 不要为了传 `id`、`status`、`agency_id`、`user_id` 之类的原始业务字段，额外塞进隐藏表单字段。
3. 表单只负责“用户可编辑输入”，行对象负责“原始业务上下文”。

## 为什么优先用 `row`

- `row` 是用户点击当下的原始业务数据，来源最直接。
- 隐藏表单字段容易在 `reset-form`、`update-form`、弹窗复用时丢值或串值。
- 如果需要传多个非表单字段，隐藏字段会越来越多，维护成本高，排查也困难。
- 同一个字段既放在 `appendFormFields`，又放在 `ajax.data`，容易出现值来源不清的问题。

## 推荐模式

当按钮来自表格行时：

1. 点击按钮先把整条 `row` 保存到 store，例如 `currentApproveRow`、`currentRejectRow`。
2. 弹窗表单只保留用户需要填写或修改的字段。
3. 提交时：
   - 表单编辑字段通过 `appendFormFields`
   - 非表单原始字段通过 `ajax.data` 从 `currentXxxRow` 读取

示例：

```json
{
  "tag": "button",
  "title": "驳回",
  "action": [
    {
      "tag": "update-store",
      "value": {
        "currentRejectRow": "${row}",
        "rejectDialogVisible": true
      }
    },
    {
      "tag": "reset-form",
      "formName": "travel-checkin-reject-form"
    },
    {
      "tag": "update-form",
      "formName": "travel-checkin-reject-form",
      "value": {
        "reject_reason": ""
      }
    }
  ]
}
```

```json
{
  "tag": "ajax",
  "api": "post:/template_data/data?service=hrm.travel_checkin_apply_reject",
  "appendFormFields": "travel-checkin-reject-form",
  "data": {
    "apply_id": "${currentRejectRow.apply_id}"
  }
}
```

## 不推荐模式

不要把原本来自 `row` 的字段塞进隐藏表单控件后再读取：

```json
{
  "tag": "form-item",
  "name": "apply_id",
  "visible": false,
  "children": [{ "tag": "input" }]
}
```

```json
{
  "tag": "ajax",
  "appendFormFields": "travel-checkin-reject-form",
  "data": {
    "apply_id": "${getFormValue('travel-checkin-reject-form','apply_id')}"
  }
}
```

问题：

- `apply_id` 只是上下文字段，不是用户输入，不应该交给表单管理。
- 表单被重置、复用、局部更新后，隐藏字段可能不同步。
- 多个隐藏字段并存时，容易出现“页面看不出，提交却带错参数”的问题。

## 字段来源拆分规范

推荐按下面方式拆分：

- `appendFormFields`：
  - 用户在弹窗中真实编辑的字段
  - 例如 `reject_reason`、`deepseek_api_key`、`description`
- `ajax.data`：
  - 来自 `row` / `currentRow` 的主键、状态、关联对象字段
  - 例如 `apply_id`、`agency_id`、`user_id`、`status`

## 多字段场景

如果一次请求需要多个原始字段，不要新增多个隐藏表单项，直接保存整条行对象：

```json
"value": {
  "currentRow": "${row}"
}
```

```json
"data": {
  "apply_id": "${currentRow.apply_id}",
  "agency_id": "${currentRow.agency_id}",
  "user_id": "${currentRow.user_id}"
}
```

这样比维护多个隐藏字段更清晰，也更容易排查。

## 例外情况

以下情况可以使用表单字段传值：

- 字段本身就是用户在当前弹窗里输入或修改的
- 字段需要参与表单校验规则
- 字段是表单组件联动后的结果，并且提交时应以表单当前值为准

如果字段不是用户编辑出来的，而是点击行时天然已经存在，优先还是走 `row/currentRow`。

## 落地检查清单

- 这个字段是不是用户手工输入的？
- 如果不是，能不能直接从 `row` 或 `currentRow` 读取？
- 这个字段是否只是主键/上下文，不应该交给表单管理？
- 是否同时在隐藏表单字段和 `ajax.data` 重复维护了同一份值？
- 这个弹窗如果被复用，隐藏字段会不会残留旧值？

满足以上任一风险时，优先改成 `row/currentRow -> ajax.data` 模式。
