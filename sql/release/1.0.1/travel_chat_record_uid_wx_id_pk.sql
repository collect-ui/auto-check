-- travel_chat_record 主键迁移：uid -> (uid, wx_id)
-- 执行前请先备份数据库文件

-- =========================
-- SQLite migration
-- =========================
BEGIN TRANSACTION;

CREATE TABLE travel_chat_record_new (
    uid TEXT NOT NULL,
    agency_id TEXT,
    employee_id TEXT,
    contact_id TEXT,
    contact_wx_id TEXT,
    wx_id TEXT NOT NULL DEFAULT '',
    owner_wx_id TEXT,
    owner_head TEXT,
    owner_nick_name TEXT,
    contact_nick_name TEXT,
    nick_name TEXT,
    head TEXT,
    wx_alias TEXT,
    is_group INTEGER,
    group_user_wx_id TEXT,
    group_user_wx_nick_name TEXT,
    group_user_wx_head TEXT,
    group_user_wx_room_name TEXT,
    message_type INTEGER,
    content TEXT,
    message_time INTEGER,
    message_status INTEGER,
    wx_msg_id INTEGER,
    file_name TEXT,
    file_size INTEGER,
    file_status INTEGER,
    file_url TEXT,
    file_text TEXT,
    link_url TEXT,
    transfer_money REAL,
    transfer_status INTEGER,
    receive_transfer_time INTEGER,
    transcation_id TEXT,
    red_packet TEXT,
    red_packet_type INTEGER,
    red_packet_status INTEGER,
    red_packet_count INTEGER,
    red_packet_end_time INTEGER,
    red_packet_from_wx_id TEXT,
    red_packet_from_wx_nick_name TEXT,
    call_time INTEGER,
    start_call_time INTEGER,
    end_call_time INTEGER,
    message_check_time INTEGER,
    withdraw_time INTEGER,
    user_nick_name TEXT,
    company_id INTEGER,
    dep_id INTEGER,
    user_id INTEGER,
    create_time TEXT,
    modify_time TEXT,
    PRIMARY KEY (uid, wx_id)
);

INSERT INTO travel_chat_record_new (
    uid, agency_id, employee_id, contact_id, contact_wx_id, wx_id, owner_wx_id,
    owner_head, owner_nick_name, contact_nick_name, nick_name, head, wx_alias,
    is_group, group_user_wx_id, group_user_wx_nick_name, group_user_wx_head, group_user_wx_room_name,
    message_type, content, message_time, message_status, wx_msg_id,
    file_name, file_size, file_status, file_url, file_text,
    link_url, transfer_money, transfer_status, receive_transfer_time, transcation_id,
    red_packet, red_packet_type, red_packet_status, red_packet_count, red_packet_end_time,
    red_packet_from_wx_id, red_packet_from_wx_nick_name,
    call_time, start_call_time, end_call_time,
    message_check_time, withdraw_time, user_nick_name, company_id, dep_id, user_id,
    create_time, modify_time
)
SELECT
    t.uid,
    t.agency_id,
    t.employee_id,
    t.contact_id,
    t.contact_wx_id,
    COALESCE(c.wx_id, t.contact_wx_id, '') AS wx_id,
    t.owner_wx_id,
    t.owner_head,
    t.owner_nick_name,
    t.contact_nick_name,
    t.nick_name,
    t.head,
    t.wx_alias,
    t.is_group,
    t.group_user_wx_id,
    t.group_user_wx_nick_name,
    t.group_user_wx_head,
    t.group_user_wx_room_name,
    t.message_type,
    t.content,
    t.message_time,
    t.message_status,
    t.wx_msg_id,
    t.file_name,
    t.file_size,
    t.file_status,
    t.file_url,
    t.file_text,
    t.link_url,
    t.transfer_money,
    t.transfer_status,
    t.receive_transfer_time,
    t.transcation_id,
    t.red_packet,
    t.red_packet_type,
    t.red_packet_status,
    t.red_packet_count,
    t.red_packet_end_time,
    t.red_packet_from_wx_id,
    t.red_packet_from_wx_nick_name,
    t.call_time,
    t.start_call_time,
    t.end_call_time,
    t.message_check_time,
    t.withdraw_time,
    t.user_nick_name,
    t.company_id,
    t.dep_id,
    t.user_id,
    t.create_time,
    t.modify_time
FROM travel_chat_record t
LEFT JOIN travel_chat_contact c ON c.contact_id = t.contact_id;

DROP TABLE travel_chat_record;
ALTER TABLE travel_chat_record_new RENAME TO travel_chat_record;

COMMIT;

-- =========================
-- MySQL migration (manual)
-- =========================
-- 1) 先回填空 wx_id（根据 contact_id 关联联系人表，查不到回退 contact_wx_id）
-- UPDATE travel_chat_record t
-- LEFT JOIN travel_chat_contact c ON c.contact_id = t.contact_id
-- SET t.wx_id = COALESCE(NULLIF(c.wx_id, ''), NULLIF(t.contact_wx_id, ''), '')
-- WHERE IFNULL(t.wx_id, '') = '';
--
-- 2) 修改主键
-- ALTER TABLE travel_chat_record DROP PRIMARY KEY;
-- ALTER TABLE travel_chat_record
--   MODIFY COLUMN uid VARCHAR(255) NOT NULL,
--   MODIFY COLUMN wx_id VARCHAR(255) NOT NULL;
-- ALTER TABLE travel_chat_record ADD PRIMARY KEY (uid, wx_id);
