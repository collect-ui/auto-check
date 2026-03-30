-- 测试插入一条聊天记录
INSERT INTO travel_chat_record (
    uid, agency_id, employee_id, contact_id, 
    wx_id, owner_wx_id, contact_nick_name, nick_name,
    head, wx_alias, is_group, message_type, content,
    message_time, message_status, wx_msg_id, create_time, modify_time
) VALUES (
    'test_uid_001', 'test_agency_001', 'test_employee_001', 'wxid_test#owner_wxid_test',
    'wxid_test', 'owner_wxid_test', '测试联系人', '测试昵称',
    'https://example.com/head.jpg', 'wx_alias_test', 0, 1, '测试消息内容',
    1774590819000, 3, 13003, datetime('now'), datetime('now')
);

-- 查询测试数据
SELECT 
    uid, agency_id, employee_id, contact_id,
    wx_id, owner_wx_id, contact_nick_name, content,
    datetime(message_time / 1000, 'unixepoch', 'localtime') as message_time_formatted,
    create_time
FROM travel_chat_record 
WHERE uid = 'test_uid_001';

-- 清理测试数据
DELETE FROM travel_chat_record WHERE uid = 'test_uid_001';