# bulk_service + http 批量调用与结果整形

本文聚焦一个高频场景：  
输入是对象列表（如员工列表），需要批量调用 http 服务，并最终产出与“单次调用”一致的数据结构，方便调用方无感接入。

## 1. 目标与结论

目标：
- 批量调用外部服务（如 `spider_qi_work.query_chat_list`）。
- 把每次调用结果统一收集。
- 将批量结果整形成与单次调用一致的数组结构（例如最终返回 `list`）。

结论（推荐套路）：
1. `module: bulk_service` 负责并发/串行批量调服务。  
2. `batch.save_field` 把每次子调用结果挂到每个 item 上。  
3. 在 `result_handler` 里先 `result2params`，再 `prop_arr + append_item: true` 扁平化。  
4. `param2result` 输出标准数组，调用方几乎不需要额外处理。

## 2. 实战配置（可直接复用）

下面是可用的批量服务配置（与你当前实践一致）：

```yml
- key: sync_chat_contact_bulk_query
  name: 批量获取员工通讯录
  log: true
  module: bulk_service
  http: true
  params:
    agency_employee_list:
      default: []
    authorization:
      default: ""
    companyId:
      default: ""
    controlId:
      default: ""
    loginUserId:
      default: ""
    createDepartmentId:
      default: ""
  result_handler:
    - key: result2params
      fields:
        - to: "[list]"
    - key: prop_arr
      foreach: "[list]"
      append_item: true
      value: "[query_result.data]"
      save_field: list
    - key: param2result
      field: "[list]"
  batch:
    foreach: "[agency_employee_list]"
    item: item
    loop_max: 1
    service:
      service: spider_qi_work.query_chat_list
      authorization: "[params.authorization]"
      companyId: "[params.companyId]"
      controlId: "[params.controlId]"
      loginUserId: "[params.loginUserId]"
      createDepartmentId: "[params.createDepartmentId]"
      wxId: "[wx_id]"
      nickName: "[nick_name]"
      userId: "[user_id]"
      search: ""
      start: 1
      limit: 500
    save_field: query_result
    append_item_param: true
```

## 3. 关键原理（结合源码）

### 3.1 `bulk_service` 实际做了什么

`module_bulk_service.go` 的核心行为：
- 对 `batch.foreach` 的每个元素组装子服务参数。
- 调用 `ResultInner` 执行子服务。
- 将子服务结果对象写回当前元素的 `save_field`（如 `query_result`）。
- 返回“增强后的元素列表”。

所以批量输出不是“直接业务数组”，而是类似：
- 每个 item = 原元素字段 + `query_result`（子服务结果对象）

### 3.2 为什么要 `result_handler` 再处理一次

`bulk_service` 返回的是“批量执行轨迹”。  
调用方通常要“纯业务数组”。因此需要：
1. `result2params` 把模块结果放到参数（如 `[list]`）。
2. `prop_arr` 取每个 item 的目标字段（如 `[query_result.data]`）。
3. `append_item: true` 把二级数组打平，避免 `[][]map`。
4. `param2result` 输出最终标准数组。

## 4. 参数作用域：最容易踩的坑

### 4.1 `append_item_param: true` 的覆盖行为

`append_item_param: true` 会把当前循环 item 字段拼进子服务参数。  
因此你可以在 `service` 中直接写 `[wx_id]`、`[user_id]`。

### 4.2 外层全局参数要用 `[params.xxx]`

在 `bulk_service` 实现里，会把外层参数挂到 item 的 `params` 字段。  
所以 token 一类全局字段建议显式写：
- `[params.authorization]`
- `[params.companyId]`

这样不会被 item 同名字段污染，也不依赖隐式行为。

## 5. 结果字段大小写坑（非常重要）

`save_field` 保存的是 Go 结果对象（结构体），不是 JSON 字符串。  
模板里访问时，常见可用字段是导出字段名：
- `Success`
- `Code`
- `Msg`
- `Data`

如果写成小写（如 `query_result.success`）可能拿不到值。  
实践建议：
1. 先打印一次中间结果（`result2params` 后看结构）。  
2. 再确定使用 `query_result.Success` 还是 `query_result.data`（取决于你当前链路被渲染后的对象形态）。

## 6. 调用方如何做到“无感单次/批量”

调用方只约定消费一个统一字段，例如 `list`：
- 单次服务直接返回 `list`。
- 批量服务通过 `result_handler` 整形后也返回 `list`。

这样调用方不用区分来源，不需要写额外分支。

## 7. 通用模板（推荐）

当你要批量调用任意服务并统一输出数组时，可用下面模板：

```yml
- key: xxx_bulk
  module: bulk_service
  params:
    data_list:
      default: []
    common_a:
      default: ""
  batch:
    foreach: "[data_list]"
    item: item
    loop_max: 1
    service:
      service: target.service
      common_a: "[params.common_a]"
      item_id: "[id]"
    save_field: result_obj
    append_item_param: true
  result_handler:
    - key: result2params
      fields:
        - to: "[list]"
    - key: prop_arr
      foreach: "[list]"
      append_item: true
      value: "[result_obj.data]"
      save_field: list
    - key: param2result
      field: "[list]"
```

## 8. 排查顺序（建议固定）

1. 先看 `batch` 子调用请求参数是否正确（尤其 `[params.xxx]` 与 item 字段）。  
2. 看 `save_field` 下到底放了什么结构。  
3. 看 `prop_arr` 是否需要 `append_item: true`。  
4. 看最终 `param2result` 输出是否已是目标数组结构。  
5. 如果“有调用无数据”，优先检查下游 `http_json` 请求体字段是否齐全（例如 `wxId` 是否真的入参并入包）。

---

一句话总结：  
`bulk_service` 负责“批量执行”，`result_handler` 负责“数据整形”，两者配合后，就能稳定产出与单次服务一致的数据结构。
