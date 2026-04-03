# 字符串与文本 Filters

## `replace`
- 用法：字符串全量替换
- 示例：`{{replace .s ":" ""}}`
- 注意：仅处理字符串参数

## `sub_str`
- 用法：字符串切片，支持负索引
- 示例：`{{sub_str .s -6 -1}}`
- 注意：索引越界会触发运行错误，先保证长度

## `str_contains`
- 用法：字符串包含判断
- 示例：`{{str_contains .s "@chatroom"}}`
- 注意：区分大小写

## `concat`
- 用法：拼接多个字符串
- 示例：`{{concat .a .b .c}}`
- 注意：参数需为字符串

## `join`
- 用法：数组按分隔符拼接
- 示例：`{{join .arr ","}}`
- 注意：实现中会把元素断言为 string

## `pinyin`
- 用法：中文转拼音
- 示例：`{{pinyin .name}}`
- 注意：多音字按库默认规则转换

## `md5`
- 用法：计算字符串 MD5
- 示例：`{{md5 .password}}`
- 注意：仅用于摘要，不用于安全加密存储

## `hash_sha`
- 用法：生成 SSHA 哈希
- 示例：`{{hash_sha .password}}`
- 注意：用于 LDAP 风格哈希，不等同 bcrypt

## `index`
- 用法：查找子串位置
- 示例：`{{index .s "abc"}}`
- 注意：找不到返回 -1
