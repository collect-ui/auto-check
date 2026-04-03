# 模块注册总表

来源：`collect/service_router.yml`

## module_handler
| key | name | type | path |
|---|---|---|---|
| `sql` | 执行sql 查询 | inner | `SqlService` |
| `model_save` | 模型保存 | inner | `ModelSaveService` |
| `model_update` | 模型修改 | inner | `ModelUpdateService` |
| `model_delete` | 模型删除 | inner | `ModelDeleteService` |
| `bulk_create` | 批量新增 | inner | `BulkCreateService` |
| `bulk_upsert` | 批量新增 | inner | `BulkUpsertService` |
| `empty` | 空模块 | inner | `EmptyService` |
| `bulk_service` | 批量服务 | inner | `BulkService` |
| `http` | 发送http请求 | inner | `HttpService` |
| `ldap` | 发送ldap请求 | inner | `LdapService` |
| `service_flow` | 服务流程化 | inner | `ServiceFlowService` |
| `ssh` | 执行shell | outer | `Ssh` |
| `read_file` | 文件读取 | outer | `ReadFile` |

## data_handler
| key | name | type | path |
|---|---|---|---|
| `update_field` | 添加参数 | inner | `UpdateField` |
| `prop_arr` | 数组对象转数组 | inner | `PropArr` |
| `check_field` | 检查参数 | inner | `CheckField` |
| `update_array` | 添加参数 | inner | `UpdateArray` |
| `update_array_from_array` | 补充右边的数据 | inner | `UpdateArrayFromArray` |
| `array_zip` | 补充右边的数据 | inner | `ArrayZip` |
| `service2field` | 服务转字段 | inner | `Service2Field` |
| `arr2obj` | 数组结果转对象 | inner | `Arr2Obj` |
| `arr2dict` | 参数数组转key/value对象 | inner | `Arr2Dict` |
| `filter_arr` | 数组转对象 | inner | `FilterArr` |
| `file_move` | 数组转对象 | inner | `FileMove` |
| `param2result` | 参数转结果 | inner | `Param2Result` |
| `params2result` | 多个参数转结果 | inner | `Params2Result` |
| `result2params` | 结果转参数 | inner | `Result2Params` |
| `result2map` | 结果转map | inner | `Result2Map` |
| `count2map` | count转map | inner | `Count2Map` |
| `session_add` | 添加session | inner | `SessionAdd` |
| `session_remove` | 删除session | inner | `SessionRemove` |
| `session_get` | 获取session | inner | `SessionGet` |
| `data2excel` | 数据转excel | inner | `Data2Excel` |
| `excel2data` | 数据转excel | inner | `Excel2Data` |
| `file2str` | 上传文件转字符串 | inner | `File2Str` |
| `file2json` | 上传文件转json | inner | `File2Json` |
| `str2file` | 生成文件转字符串 | inner | `Str2File` |
| `str2img` | 生成文件转字符串 | inner | `Base64Str2Img` |
| `str2json` | 字符串转json | inner | `Str2Json` |
| `ignore_data` | 忽略数据 | inner | `IgnoreData` |
| `file2result` | 数据转excel | inner | `File2Result` |
| `files2result` | 数据转excel | inner | `Files2Result` |
| `file2datajson` | 文件转data_json | inner | `File2DataJson` |
| `field2array` | 字段转数组 | inner | `Field2Array` |
| `arr2arrayObj` | 字段转数组,简单数组，转数组对象 | inner | `Arr2arrayObj` |
| `get_modify_data` | 获取修改的数据 | inner | `GetModifyData` |
| `group_by` | 分组 | inner | `GroupBy` |
| `order_by` | 排序 | inner | `OrderBy` |
| `agg` | 聚合统计 | inner | `Agg` |
| `combine_array` | 数组添加字段 | inner | `CombineArray` |
| `handler_cache` | 处理缓存 | inner | `HandlerCache` |
| `prevent_duplication` | 防止重复请求 | inner | `PreventDuplication` |
| `to_tree` | 列表转树形结构 | inner | `ToTree` |
| `to_list` | 树形转列表结构 | inner | `ToList` |
| `update_order` | 修改排序号 | inner | `UpdateOrder` |
| `analysis_ip` | 分析IP | outer | `AnalysisIp` |
| `shell` | shell | outer | `Shell` |
| `sftp` | sftp | outer | `Sftp` |
| `shell_term` | shell | outer | `ShellTerm` |
| `param_key2arr` | 参数key字段转数组 | outer | `ParamKey2Arr` |
| `rename_field` | 请求字段重命名 | outer | `RenameField` |
| `multi_arr` | 数组乘以数组 | outer | `MultiArr` |
| `handler_password` | 处理密码 | outer | `HandlerPassword` |
| `value_transfer` | 值转换 | outer | `ValueTransfer` |
| `analysis_attendance` | 分析考勤 | outer | `AnalysisAttendance` |
| `to_local_file` | 分析考勤 | outer | `ToLocalFile` |
| `gen_sport_level` | 计算运动级别 | outer | `GenSportLevel` |
| `xml2json` | 文件转字符串 | outer | `Xml2Json` |
| `schema_transfer` | 文件转字符串 | outer | `SchemaTransfer` |
| `gen_doc_project` | 文件转字符串 | outer | `GenDocProject` |
| `gen_sign` | 文件转字符串 | outer | `GenSign` |
| `gen_doc` | 文件转字符串 | outer | `GenDoc` |
| `render_doc` | 渲染doc | outer | `RenderDoc` |
| `extract_bid` | 解析pdf | outer | `ExtractBid` |
| `fix_json` | 解析json | outer | `FixJson` |
| `handler_tree_level_order` | 添加树的序号 | outer | `HandlerTreeLevelOrder` |
| `client_ip` | 获取ip | outer | `ClientIp` |
