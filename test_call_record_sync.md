# 电话记录同步测试记录

## 1. 同步接口

请求：

```json
POST /template_data/data?service=hrm.sync_call_record
{
  "agency_id": "9134",
  "start_time": 1772467200000,
  "end_time": 1775231999999,
  "pageNum": 1,
  "pageSize": 1000,
  "viewDataRangeType": 3
}
```

预期返回要点：

```json
{
  "mode": "agency",
  "start_time": 1772467200000,
  "end_time": 1775231999999,
  "fetched_count": 1,
  "add_count": 1,
  "modify_count": 0,
  "mapped_call_record_list": [
    {
      "uid": "93c584e8-7d68-43a6-a741-6b4bbf6faf35",
      "phone_id": 270233096,
      "phone_out_number": "15717448189",
      "phone_in_number": "19907445603",
      "phone_call_type": 4,
      "phone_status": 1,
      "call_time_length": 84,
      "phone_start_time": 1775121034237,
      "employee_id": "<按手机号匹配到的本地employee_id>",
      "parsed_text": "通话类型4：15717448189 -> 19907445603，状态1，通话84秒，录音：https://df.qi.work/group1/M00/13/8B/rBIAAWnOMt-EDvKqAAAAAOQvxzM334.mp3"
    }
  ]
}
```

## 2. 列表接口

请求：

```json
POST /template_data/data?service=hrm.travel_call_record_list
{
  "agency_id": "9134",
  "start_time": 1772467200000,
  "end_time": 1775231999999,
  "limit": 20
}
```

预期返回要点：

- 返回字段包含：`uid`、`phone_id`、`employee_id`、`phone_start_time_formatted`、`parsed_text`
- 按 `phone_start_time desc` 排序
- `parsed_text` 非空，可直接用于页面展示

## 3. 幂等验证

- 同一时间窗重复执行两次 `hrm.sync_call_record`。
- 预期第二次：`add_count = 0`，`modify_count >= 0`（若上游数据有变化则更新）。

