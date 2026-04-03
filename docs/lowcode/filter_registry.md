# Filter 注册与用法总览

来源：`/data/project/collect/src/collect/filters/all_register.go`

总数：`31`

## `uuid`
- 函数：`Uuid() string`
- 源码：`/data/project/collect/src/collect/filters/uuid.go`
- 用法：生成标准 UUID
- 示例：`{{uuid}}`
- 注意：每次渲染都会变，避免在幂等更新主键重复调用
- 历史文档：`collect_doc_id=cd14dfe4-ddfd-431e-aeef-b00db64e32f6`，标题 `uuid`

## `uuid_short`
- 函数：`ShortUUID() string`
- 源码：`/data/project/collect/src/collect/filters/uuid_short.go`
- 用法：生成短 UUID（8位）
- 示例：`{{uuid_short}}`
- 注意：短 ID 碰撞概率高于标准 UUID，不建议做全局主键

## `is_empty`
- 函数：`IsEmpty(value interface{}) bool`
- 源码：`/data/project/collect/src/collect/filters/is_empty.go`
- 用法：判断值是否为空（空串/空数组/null）
- 示例：`{{is_empty .value}}`
- 注意：返回布尔值，常用于 if_template
- 历史文档：`collect_doc_id=6506e88b-ac97-4724-b6ce-c11f251ce560`，标题 `is_empty`

## `must`
- 函数：`Must(value interface{}) bool`
- 源码：`/data/project/collect/src/collect/filters/must.go`
- 用法：判断值是否非空
- 示例：`{{must .value}}`
- 注意：与 is_empty 互补，常用于参数必填校验
- 历史文档：`collect_doc_id=4c952eac-4d1e-47c4-b6f2-ac964167ad65`，标题 `must`

## `current_date_time`
- 函数：`CurrentDateTime() string`
- 源码：`/data/project/collect/src/collect/filters/current_date_time.go`
- 用法：返回当前时间字符串
- 示例：`{{current_date_time}}`
- 注意：格式受后端实现控制，通常 yyyy-MM-dd HH:mm:ss
- 历史文档：`collect_doc_id=1aef7d2e-9336-47ce-b70b-bed9aff9b6ce`，标题 `current_date_time`

## `current_date_format`
- 函数：`CurrentDateFormat(fmt string) string`
- 源码：`/data/project/collect/src/collect/filters/current_date_format.go`
- 用法：按格式返回当前时间
- 示例：`{{current_date_format "20060102"}}`
- 注意：格式使用 Go time layout 规则

## `replace`
- 函数：`Replace(source string, from string, to string) string`
- 源码：`/data/project/collect/src/collect/filters/replace.go`
- 用法：字符串全量替换
- 示例：`{{replace .s ":" ""}}`
- 注意：仅处理字符串参数
- 历史文档：`collect_doc_id=a721393b-32e3-463f-b679-49c9eef2f8cc`，标题 `replace`

## `md5`
- 函数：`Md5(str string) string`
- 源码：`/data/project/collect/src/collect/filters/md5.go`
- 用法：计算字符串 MD5
- 示例：`{{md5 .password}}`
- 注意：仅用于摘要，不用于安全加密存储
- 历史文档：`collect_doc_id=4a13b507-5eb3-48a5-a99a-28deff080a47`，标题 `md5`

## `sub_str`
- 函数：`SubStr(content string, start int, end int) string`
- 源码：`/data/project/collect/src/collect/filters/sub_str.go`
- 用法：字符串切片，支持负索引
- 示例：`{{sub_str .s -6 -1}}`
- 注意：索引越界会触发运行错误，先保证长度
- 历史文档：`collect_doc_id=2d6b0e66-7188-4660-8d74-0c70176dedca`，标题 `sub_str`

## `get_key`
- 函数：`GetKey(key string) string`
- 源码：`/data/project/collect/src/collect/filters/get_key.go`
- 用法：读取系统配置 key
- 示例：`{{get_key "wechat_schedule_enable"}}`
- 注意：依赖配置中心，key 不存在返回空
- 历史文档：`collect_doc_id=6cb9a450-5ab1-4a85-9125-54d8844b609c`，标题 `get_key`

## `pinyin`
- 函数：`Pinyin(source string) string`
- 源码：`/data/project/collect/src/collect/filters/pinyin.go`
- 用法：中文转拼音
- 示例：`{{pinyin .name}}`
- 注意：多音字按库默认规则转换
- 历史文档：`collect_doc_id=c13b5daf-13ac-47f5-9069-2a6c16e765a4`，标题 `pinyin`

## `hash_sha`
- 函数：`HashSha(str string) string`
- 源码：`/data/project/collect/src/collect/filters/hash_sha.go`
- 用法：生成 SSHA 哈希
- 示例：`{{hash_sha .password}}`
- 注意：用于 LDAP 风格哈希，不等同 bcrypt
- 历史文档：`collect_doc_id=7b95f2ea-a69d-47a7-9857-ab301d5b0bb6`，标题 `hash_sha`

## `snow_id`
- 函数：`SnowID() int64`
- 源码：`/data/project/collect/src/collect/filters/snowid.go`
- 用法：生成雪花 ID（int64）
- 示例：`{{snow_id}}`
- 注意：依赖节点配置，跨集群需保证 machine_id 唯一
- 历史文档：`collect_doc_id=888d07ba-81b1-4654-b149-de9fcda9f502`，标题 `snow_id`

## `index`
- 函数：`Index(source string, target string) int`
- 源码：`/data/project/collect/src/collect/filters/index.go`
- 用法：查找子串位置
- 示例：`{{index .s "abc"}}`
- 注意：找不到返回 -1

## `unix_time`
- 函数：`UnixTime(delay int, unit string) int64`
- 源码：`/data/project/collect/src/collect/filters/unix_time.go`
- 用法：返回 Unix 秒级时间戳（可带偏移）
- 示例：`{{unix_time -1 `day`}}`
- 注意：秒级；如需毫秒需手动 *1000

## `unix_time2datetime`
- 函数：`UnixTime2Datetime(unit int64) string`
- 源码：`/data/project/collect/src/collect/filters/unix_time2datetime.go`
- 用法：Unix 秒转时间字符串
- 示例：`{{unix_time2datetime .ts}}`
- 注意：输入应为秒级 int64

## `contains`
- 函数：`Contains(arr []interface{}, str interface{}) bool`
- 源码：`/data/project/collect/src/collect/filters/contains.go`
- 用法：判断数组是否包含某值
- 示例：`{{contains .arr .target}}`
- 注意：数组元素类型需可直接比较

## `to_json`
- 函数：`ToJSON(v interface{}) string`
- 源码：`/data/project/collect/src/collect/filters/to_json.go`
- 用法：对象转 JSON 字符串
- 示例：`{{to_json .obj}}`
- 注意：序列化失败会返回空串

## `cast`
- 函数：`Cast(value any, dataType string) any`
- 源码：`/data/project/collect/src/collect/filters/cast.go`
- 用法：类型转换 int/int64/float/float64
- 示例：`{{cast .value "int64"}}`
- 注意：不支持的类型原样返回

## `multiply`
- 函数：`Multiply(a, b interface{}) string`
- 源码：`/data/project/collect/src/collect/filters/multiply.go`
- 用法：乘法，返回保留2位小数字符串
- 示例：`{{multiply 2 3}}`
- 注意：返回字符串，不是数字类型

## `divide`
- 函数：`Divide(a, b interface{}) string`
- 源码：`/data/project/collect/src/collect/filters/divide.go`
- 用法：除法，返回保留2位小数字符串
- 示例：`{{divide 10 4}}`
- 注意：除数为 0 风险需在外层避免

## `sub_arr`
- 函数：`SubArr(arr []map[string]interface{}, index int, field string) []map[string]interface`
- 源码：`/data/project/collect/src/collect/filters/sub_arr.go`
- 用法：二维结构中取子数组字段
- 示例：`{{sub_arr .arr 0 "[children]"}}`
- 注意：索引越界会异常，先判断长度

## `range_number`
- 函数：`RangeNumber(n int) []int`
- 源码：`/data/project/collect/src/collect/filters/range_number.go`
- 用法：生成 0..n-1 数组
- 示例：`{{range_number 5}}`
- 注意：常配合 foreach 生成固定次数循环

## `sub_arr_attr`
- 函数：`SubArrAttr(arr []map[string]interface{}, x int, field string, y int, attr string) interface`
- 源码：`/data/project/collect/src/collect/filters/sub_arr_attr.go`
- 用法：二维结构取某元素属性
- 示例：`{{sub_arr_attr .arr 0 "[children]" 1 "name"}}`
- 注意：越界时返回空串或"0"（按实现）

## `str_contains`
- 函数：`StrContains(s, substr string) bool`
- 源码：`/data/project/collect/src/collect/filters/str_contains.go`
- 用法：字符串包含判断
- 示例：`{{str_contains .s "@chatroom"}}`
- 注意：区分大小写

## `random_int`
- 函数：`RandomInt(min, max int) int`
- 源码：`/data/project/collect/src/collect/filters/randomInt.go`
- 用法：生成随机整数[min,max]
- 示例：`{{random_int 1 10}}`
- 注意：每次渲染都会变化，不适合幂等字段

## `first_item`
- 函数：`FirstItem(list []interface{}) interface`
- 源码：`/data/project/collect/src/collect/filters/firstItem.go`
- 用法：取数组第一个元素
- 示例：`{{first_item .arr}}`
- 注意：空数组会越界，先用 must 判断

## `concat`
- 函数：`Concat(args ...string) interface`
- 源码：`/data/project/collect/src/collect/filters/concat.go`
- 用法：拼接多个字符串
- 示例：`{{concat .a .b .c}}`
- 注意：参数需为字符串

## `genId`
- 函数：`GenId(value string) interface`
- 源码：`/data/project/collect/src/collect/filters/genId.go`
- 用法：基于输入生成稳定短ID
- 示例：`{{genId .value}}`
- 注意：同输入可复现，适合派生 key

## `join`
- 函数：`Join(args []interface{}, sep string) interface`
- 源码：`/data/project/collect/src/collect/filters/join.go`
- 用法：数组按分隔符拼接
- 示例：`{{join .arr ","}}`
- 注意：实现中会把元素断言为 string

## `date_format`
- 函数：`DateFormat(timeStr string, from_fmt string) string`
- 源码：`/data/project/collect/src/collect/filters/date_format.go`
- 用法：时间字符串格式化为 yyyy-MM-dd HH:mm:ss
- 示例：`{{date_format .timeStr "2006-01-02T15:04:05Z07:00"}}`
- 注意：解析失败返回空串
