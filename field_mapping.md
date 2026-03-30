# 字段映射参考

## 前端 chatDetailList 字段 (48个)
1. alias
2. call_time
3. company_id
4. contact_nick_name
5. contact_wx_id
6. content
7. create_time
8. dep_id
9. end_call_time
10. file_name
11. file_size
12. file_status
13. file_url
14. group_user_wx_head
15. group_user_wx_id
16. group_user_wx_nick_name
17. group_user_wx_room_name
18. head
19. id
20. is_group
21. is_self
22. link_url
23. message_check_time
24. message_status
25. message_time
26. message_type
27. owner_alias
28. owner_head
29. owner_nick_name
30. owner_wx_id
31. receive_transfer_time
32. red_packet
33. red_packet_count
34. red_packet_end_time
35. red_packet_from_wx_id
36. red_packet_from_wx_nick_name
37. red_packet_status
38. red_packet_type
39. start_call_time
40. transcation_id
41. transfer_money
42. transfer_status
43. type
44. uid
45. user_id
46. user_nick_name
47. withdraw_time
48. wx_msg_id

## 后端 travel_chat_record 字段 (47个)
1. uid
2. agency_id
3. employee_id
4. contact_id
5. wx_id
6. owner_wx_id
7. contact_nick_name
8. nick_name
9. head
10. wx_alias
11. is_group
12. group_user_wx_id
13. group_user_wx_nick_name
14. group_user_wx_head
15. group_user_wx_room_name
16. message_type
17. content
18. message_time
19. message_status
20. wx_msg_id
21. file_name
22. file_size
23. file_status
24. file_url
25. link_url
26. transfer_money
27. transfer_status
28. receive_transfer_time
29. transcation_id
30. red_packet
31. red_packet_type
32. red_packet_status
33. red_packet_count
34. red_packet_end_time
35. red_packet_from_wx_id
36. red_packet_from_wx_nick_name
37. call_time
38. start_call_time
39. end_call_time
40. message_check_time
41. withdraw_time
42. user_nick_name
43. company_id
44. dep_id
45. user_id
46. create_time
47. modify_time

## 关键字段映射差异

### 需要特别注意的字段：
1. **前端 `contact_wx_id`** ↔ **后端 `wx_id`**
2. **前端 `alias`** ↔ **后端 `nick_name`**
3. **前端 `owner_head`** ↔ **后端 `head`** (注意：前端有 `head` 和 `owner_head` 两个字段)
4. **前端 `type`** ↔ **后端 `message_type`** (可能相同)
5. **前端 `id`** ↔ **后端 `uid`** (前端使用 `id`，后端使用 `uid` 作为主键)

### 前端特有字段：
- `is_self`: 需要在前端根据业务逻辑计算
- `owner_alias`: 可能需要从其他表关联获取

### 后端特有字段：
- `agency_id`: 旅行社ID
- `employee_id`: 员工ID
- `contact_id`: 联系人ID
- `modify_time`: 修改时间

## 建议的字段处理

### 1. SQL 查询中添加字段映射
可以在 SQL 查询中添加字段别名来匹配前端字段名：

```sql
select
  a.uid as id,  -- 映射前端 id 字段
  a.wx_id as contact_wx_id,  -- 映射前端 contact_wx_id
  a.nick_name as alias,  -- 映射前端 alias
  a.head as owner_head,  -- 映射前端 owner_head
  -- 其他字段...
from travel_chat_record a
```

### 2. 前端适配处理
或者在前端进行字段适配，但建议在 SQL 层处理更高效。

### 3. 计算字段
- `is_self`: 需要在前端根据当前用户和消息发送者判断
- `owner_alias`: 可能需要关联其他表查询