get_modify_data(比对数据)  
示例
    modify_config: doc_modify.json
    handler_params:
      - key: get_modify_data
        save_field: change_list

    我经常遇到业务级别，需要记录某个字段是谁改的，改之前是什么，改之后是什么。
   但是利用用数据库的binlog日志展示不做不到，比如要记录版本号是谁改的，改之前是什么，改之后是什么，然后还原此条。
    一个两个情况到没有什么，主要很多地方有这样的需求，比如保存一个全量列表，之前的搞法就是直接全部删除，然后全部添加，后面发现效率不行，毕竟数量多了，删除和添加总会要占用一定时间，甚至可能触发数据库锁。本身只改了一点点数据，却触发整个表的删除与新增
    有了这个对比工具，我们可以对比列表的差异部分，然后数据进行，哪些删除，哪些新增，哪些修改，理应如此
简单字段比对修改
简单数组字段比对新增与删除
数据对象比对新增修改删除
支持结果数据转换
支持操作名称修改
参数
handler_params[get_modify_data]
string
是
处理器中key
modify_config
string
是
规则路径，在主体中
modify_config.op_field_transfer
json
操作的转换字典，change_list 有些固定字段，比如name表示名称，如何有冲突可以在此处修改
modify_config.fields[]
array
是
数据规则
modify_config.fields[rule]
string
是
规则名称。compare_field_value简单字段，simple_array_value简单数组，array_obj_value数组对象
modify_config.fields[field]
string
是
对比的字段名称
modify_config.fields[name]
string
是
对比字段的中文名称
modify_config.fields[left]
string
左边取对象字段，如果没有就从参数中取
modify_config.fields[right]
string
是
右边取对象字段
modify_config.fields[operation]
string
仅仅对简单字段修改有效，对操作名称进行重新调整，一般是add，modify，remove
modify_config.fields[append_right_fields]
array
拼接右边的字段，*表示所有字段
modify_config.fields[append_left_fields]
array
拼接左边的字段，一般数组对象修改，左右2边都有的情况，优先左边的字段，配置op_field_transfer,右边已经存在字段护理
modify_config.fields[left_field]
string
当左右2边数据对比字段不对等到时候，左边定位数据需要字段a，右边要取字段b。主要用于定位数据，左边的字段
modify_config.fields[right_field]
string
当左右2边数据对比字段不对等到时候，左边定位数据需要字段a，右边要取字段b。主要用于定位数据，右边的字段
modify_config.fields[left_value_field]
string
主要用于数组对象，对比行记录里面其他字段值，左边的取值
modify_config.fields[right_value_field]
string
主要用于数组对象，对比行记录里面其他字段值，右边的取值
modify_config.fields[with_add_remove]
string
主要用于数组对象，是生成添加修改记录，一个字段数组对象中只要有一个
modify_config.fields[save_original]
boolean
是否保留原始值，取值为value，主要用户转换，看下面transfer 和service
modify_config.fields[value_list_field]
string
将左右2边的值取出来，从另外一个目标服务查询转换一下，为下面service提供取值列表字段，一般current_value_list
modify_config.fields[target_transfer_key]
string
目标服务的取值关键字段，定位行数据，根据编码定位行
modify_config.fields[target_transfer_value]
string
转换后的取值字段，根据编码换值
modify_config.fields[service]
json
转换调用的服务，如果current_value_list 有冲突，可以改value_list_field
示例
1. 文档对比
{
  "desc": "替换前和替换后，概念调整下，方便对比，从左往右，传过来的数据，是前段的数据，left。已有的后台数据是right",
  "left_save_field": "after",
  "right_save_field": "before",
  "op_field_transfer": {
    "name": "op_name"
  },
  "fields": [
    {"rule": "compare_field_value", "field": "[title]", "name": "标题", "left": "[doc]", "right": "[local_doc_detail.doc]", "operation": "modify_base", "append_right_fields": ["[collect_doc_id]"]},
    {"rule": "compare_field_value", "field": "[sub_title]", "name": "子标题", "left": "[doc]", "right": "[local_doc_detail.doc]", "operation": "modify_base", "append_right_fields": ["[collect_doc_id]"]},
    {"rule": "compare_field_value", "field": "[code]", "name": "代码", "left": "[doc]", "right": "[local_doc_detail.doc]", "operation": "modify_base", "append_right_fields": ["[collect_doc_id]"]},
    {"rule": "compare_field_value", "field": "[code_desc]", "name": "代码描述", "left": "[doc]", "right": "[local_doc_detail.doc]", "operation": "modify_base", "append_right_fields": ["[collect_doc_id]"]},
    {"rule": "compare_field_value", "field": "[parent_dir]", "name": "上级目录", "left": "[doc]", "right": "[local_doc_detail.doc]", "operation": "modify_base", "append_right_fields": ["[collect_doc_id]"]},
    {"rule": "compare_field_value", "field": "[type]", "name": "类型", "left": "[doc]", "right": "[local_doc_detail.doc]", "operation": "modify_base", "append_right_fields": ["[collect_doc_id]"]},
    {"rule": "compare_field_value", "field": "[order_index]", "name": "排序", "left": "[doc]", "right": "[local_doc_detail.doc]", "operation": "modify_base", "append_right_fields": ["[collect_doc_id]"]},
    {"rule": "array_obj_value", "left_field": "[name]", "right_field": "[name]", "field": "[demo]", "name": "示例名称", "left": "[demo]", "right": "[local_doc_detail.demo]", "with_add_remove": true, "left_value_field": "[name]", "right_value_field": "[name]", "operation": "modify", "append_right_fields": ["[*]"],"append_left_fields": ["[*]"]},
    {"rule": "array_obj_value", "left_field": "[name]", "right_field": "[name]", "field": "[demo]", "name": "示例代码", "left": "[demo]", "right": "[local_doc_detail.demo]",  "left_value_field": "[code]", "right_value_field": "[code]", "operation": "modify", "append_left_fields": ["[*]"]},
    {"rule": "array_obj_value", "left_field": "[name]", "right_field": "[name]", "field": "[demo]", "name": "示例排序", "left": "[demo]", "right": "[local_doc_detail.demo]",  "left_value_field": "[order_index]", "right_value_field": "[order_index]", "operation": "modify", "append_left_fields": ["[*]"]},

    {"rule": "array_obj_value", "left_field": "[name]", "right_field": "[name]", "field": "[params]", "name": "参数名称", "left": "[params]", "right": "[local_doc_detail.params]", "with_add_remove": true, "left_value_field": "[name]", "right_value_field": "[name]", "operation": "modify", "append_right_fields": ["[*]"]},
    {"rule": "array_obj_value", "left_field": "[name]", "right_field": "[name]", "field": "[params]", "name": "参数类型", "left": "[params]", "right": "[local_doc_detail.params]",  "left_value_field": "[type]", "right_value_field": "[type]", "operation": "modify", "append_left_fields": ["[*]"]},
    {"rule": "array_obj_value", "left_field": "[name]", "right_field": "[name]", "field": "[params]", "name": "参数是否必须", "left": "[params]", "right": "[local_doc_detail.params]",  "left_value_field": "[must]", "right_value_field": "[must]", "operation": "modify", "append_left_fields": ["[*]"]},
    {"rule": "array_obj_value", "left_field": "[name]", "right_field": "[name]", "field": "[params]", "name": "参数描述", "left": "[params]", "right": "[local_doc_detail.params]",  "left_value_field": "[desc]", "right_value_field": "[desc]", "operation": "modify", "append_left_fields": ["[*]"]},
    {"rule": "array_obj_value", "left_field": "[name]", "right_field": "[name]", "field": "[params]", "name": "参数排序", "left": "[params]", "right": "[local_doc_detail.params]",  "left_value_field": "[order_index]", "right_value_field": "[order_index]", "operation": "modify", "append_left_fields": ["[*]"]},

    {"rule": "array_obj_value", "left_field": "[name]", "right_field": "[name]", "field": "[important_list]", "name": "要点", "left": "[important_list]", "right": "[local_doc_detail.important_list]", "with_add_remove": true, "left_value_field": "[name]", "right_value_field": "[name]", "operation": "modify", "append_right_fields": ["[*]"]},
    {"rule": "array_obj_value", "left_field": "[name]", "right_field": "[name]", "field": "[important_list]", "name": "要点排序", "left": "[important_list]", "right": "[local_doc_detail.important_list]",  "left_value_field": "[order_index]", "right_value_field": "[order_index]", "operation": "modify","append_left_fields": ["[*]"]}
  ]
}
2. 用户修改对比
{
  "desc": "替换前和替换后，概念调整下，方便对比，从左往右，传过来的数据，是前段的数据，left。已有的后台数据是right",
  "left_save_field": "after",
  "right_save_field": "before",
  "fields": [
    {
      "rule": "compare_field_value",
      "field": "[nick]",
      "name": "用户昵称",
      "right": "[user_info]",
      "operation": "modify",
      "append_right_fields": [
        "[user_id]"
      ]
    },
    {
      "rule": "compare_field_value",
      "field": "[create_ldap]",
      "name": "创建ldap",
      "right": "[user_info]",
      "operation": "modify",
      "append_right_fields": [
        "[user_id]"
      ]
    },
    {
      "belong": "设置belong 将fields 二层层级去掉，或者在field支持点，xx.xx",
      "rule": "compare_field_value",
      "field": "[user_status]",
      "name": "用户状态",
      "right": "[user_info]",
      "operation": "modify",
      "append_right_fields": [
        "[user_id]"
      ],
      "value_list_field": "current_value_list",
      "target_transfer_key": "[sys_code]",
      "target_transfer_value": "[sys_code_text]",
      "service": {
        "service": "system.get_sys_code",
        "sys_code_type": "user_job_status",
        "sys_code_list": "[current_value_list]"
      }

    },
    {
      "rule": "simple_array_value",
      "field": "[roles]",
      "name": "用户角色",
      "right": "[user_info]",
      "operation": "modify",
      "save_original": true,
      "append_right_fields": [
        "[user_id]"
      ],
      "value_list_field": "current_value_list",
      "target_transfer_key": "[role_code]",
      "target_transfer_value": "[role_name]",
      "service": {
        "service": "hrm.role_query",
        "role_code_list": "[current_value_list]"
      }

    },
    {
      "enable": "{{ eq .create_ldap \"1\"}}",
      "rule": "array_obj_value",
      "left_field": "[name]",
      "right_field": "[name]",
      "field": "[ldap_group]",
      "desc": "field匹配规则,value field取值",
      "name": "ldap分组",
      "right": "[right_ldap_group]",
      "left": "[left_ldap_group]",
      "left_value_field": "[name]",
      "right_value_field": "[name]",
      "operation": "modify",
      "with_add_remove": true,
      "save_original": true,
      "append_right_fields": [
        "[user_id]"
      ]
    }
  ]
}
3. 简单字段对比
{
      "rule": "compare_field_value",
      "field": "[create_ldap]",
      "name": "创建ldap",
      "right": "[user_info]",
      "operation": "modify",
      "append_right_fields": [
        "[user_id]"
      ]
    }
4. 简单数组对比
{
      "rule": "simple_array_value",
      "field": "[roles]",
      "name": "用户角色",
      "right": "[user_info]",
      "operation": "modify",
      "save_original": true,
      "append_right_fields": [
        "[user_id]"
      ],
      "value_list_field": "current_value_list",
      "target_transfer_key": "[role_code]",
      "target_transfer_value": "[role_name]",
      "service": {
        "service": "hrm.role_query",
        "role_code_list": "[current_value_list]"
      }

    }
5. 数组对象对比
{
    "rule": "array_obj_value",
    "left_field": "[name]",
    "right_field": "[name]",
    "field": "[params]",
    "name": "参数名称",
    "left": "[params]",
    "right": "[local_doc_detail.params]",
    "with_add_remove": true,
    "left_value_field": "[name]",
    "right_value_field": "[name]",
    "operation": "modify",
    "append_right_fields": ["[*]"]
}

