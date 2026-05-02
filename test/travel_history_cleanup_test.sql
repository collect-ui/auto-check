begin transaction;

delete from travel_chat_record where agency_id = 'UT_CLEANUP_AG_20260424';
delete from travel_call_record where agency_id = 'UT_CLEANUP_AG_20260424';
delete from travel_chat_contact where agency_id = 'UT_CLEANUP_AG_20260424';
delete from travel_employee where agency_id = 'UT_CLEANUP_AG_20260424';
delete from travel_agency where agency_id = 'UT_CLEANUP_AG_20260424';

insert into travel_agency (
  agency_id, agency_name, agency_code, biz_type, checkin_status, status, create_time, create_user, description, wx_sync_enabled
) values (
  'UT_CLEANUP_AG_20260424', '清理测试旅行社', 'UT_CLEANUP_20260424', 'travel', 'checked_in', 'normal', '2026-04-24 10:00:00', 'codex', 'cleanup test', 'no'
);

insert into travel_employee (
  employee_id, agency_id, nick_name, phone, user_id, wx_id, wx_target, status, create_time, create_user, modify_time, modify_user
) values (
  'UT_CLEANUP_EMP_20260424', 'UT_CLEANUP_AG_20260424', '清理测试员工', '13900000001', 900001, 'wx_ut_cleanup_emp_01', 1, 'normal', '2026-04-24 10:00:00', 'codex', '2026-04-24 10:00:00', 'codex'
);

insert into travel_chat_contact (
  contact_id, agency_id, employee_id, wx_id, contact_nick_name, nick_name, head, content, message_time, owner_wx_id, person_count, type, wx_alias, is_group, create_time, modify_time
) values
('UT_CONTACT_DEL_01',  'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 'wx_ut_contact_del_01', '旧联系人待删', '旧联系人待删', '', 'old', cast(strftime('%s','2026-02-20 10:00:00') as integer) * 1000, 'wx_ut_cleanup_emp_01', 2, 1, '', 0, '2026-04-24 10:00:00', '2026-04-24 10:00:00'),
('UT_CONTACT_KEEP_01', 'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 'wx_ut_contact_keep_01', '旧联系人保留', '旧联系人保留', '', 'old but active', cast(strftime('%s','2026-02-20 10:00:00') as integer) * 1000, 'wx_ut_cleanup_emp_01', 2, 1, '', 0, '2026-04-24 10:00:00', '2026-04-24 10:00:00'),
('UT_GROUP_DEL_01',    'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 'wx_ut_group_del_01@chatroom', '旧群待删', '旧群待删', '', 'old group', cast(strftime('%s','2026-02-18 10:00:00') as integer) * 1000, 'wx_ut_cleanup_emp_01', 5, 2, '', 1, '2026-04-24 10:00:00', '2026-04-24 10:00:00'),
('UT_CONTACT_KEEP_02', 'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 'wx_ut_contact_keep_02', '边界联系人保留', '边界联系人保留', '', 'boundary', cast(strftime('%s','2026-03-01 00:00:00') as integer) * 1000, 'wx_ut_cleanup_emp_01', 2, 1, '', 0, '2026-04-24 10:00:00', '2026-04-24 10:00:00');

insert into travel_chat_record (
  uid, agency_id, employee_id, contact_id, contact_wx_id, wx_id, owner_wx_id, owner_nick_name, contact_nick_name, nick_name, is_group, message_type, content, message_time, message_status, wx_msg_id, create_time, modify_time
) values
('UT_CHAT_DEL_01',  'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 'UT_CONTACT_DEL_01',  'wx_ut_contact_del_01',        'wx_ut_contact_del_01',        'wx_ut_cleanup_emp_01', '清理测试员工', '旧联系人待删', '旧联系人待删', 0, 1, 'old chat delete 1', cast(strftime('%s','2026-02-20 10:00:00') as integer) * 1000, 1, 10001, '2026-04-24 10:00:00', '2026-04-24 10:00:00'),
('UT_CHAT_DEL_02',  'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 'UT_CONTACT_KEEP_01', 'wx_ut_contact_keep_01',       'wx_ut_contact_keep_01',       'wx_ut_cleanup_emp_01', '清理测试员工', '旧联系人保留', '旧联系人保留', 0, 1, 'old chat delete 2', cast(strftime('%s','2026-02-21 10:00:00') as integer) * 1000, 1, 10002, '2026-04-24 10:00:00', '2026-04-24 10:00:00'),
('UT_CHAT_DEL_03',  'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 'UT_GROUP_DEL_01',    'wx_ut_group_del_01@chatroom', 'wx_ut_group_del_01@chatroom', 'wx_ut_cleanup_emp_01', '清理测试员工', '旧群待删', '旧群待删', 1, 1, 'old group delete', cast(strftime('%s','2026-02-18 10:00:00') as integer) * 1000, 1, 10003, '2026-04-24 10:00:00', '2026-04-24 10:00:00'),
('UT_CHAT_KEEP_01', 'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 'UT_CONTACT_KEEP_01', 'wx_ut_contact_keep_01',       'wx_ut_contact_keep_01',       'wx_ut_cleanup_emp_01', '清理测试员工', '旧联系人保留', '旧联系人保留', 0, 1, 'recent keep', cast(strftime('%s','2026-03-10 10:00:00') as integer) * 1000, 1, 10004, '2026-04-24 10:00:00', '2026-04-24 10:00:00'),
('UT_CHAT_KEEP_02', 'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 'UT_CONTACT_KEEP_02', 'wx_ut_contact_keep_02',       'wx_ut_contact_keep_02',       'wx_ut_cleanup_emp_01', '清理测试员工', '边界联系人保留', '边界联系人保留', 0, 1, 'boundary keep', cast(strftime('%s','2026-03-01 00:00:00') as integer) * 1000, 1, 10005, '2026-04-24 10:00:00', '2026-04-24 10:00:00');

insert into travel_call_record (
  uid, agency_id, employee_id, phone_id, name, phone_out_number, phone_in_number, relegation, phone_operator, phone_call_type, phone_client_type, ring_time_length, phone_end_time, phone_status, call_time_length, phone_record_address, phone_start_time, group_id, user_id, phone_type, parsed_text, create_time, modify_time, phone_record_text
) values
('UT_CALL_DEL_01',  'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 20001, '旧通话待删1', '13900000001', '13800000001', '', 1, 1, 1, 3, cast(strftime('%s','2026-02-19 10:05:00') as integer) * 1000, 1, 300, '', cast(strftime('%s','2026-02-19 10:00:00') as integer) * 1000, 1, 900001, 1, 'old call 1', '2026-04-24 10:00:00', '2026-04-24 10:00:00', ''),
('UT_CALL_DEL_02',  'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 20002, '旧通话待删2', '13900000001', '13800000002', '', 1, 1, 1, 3, cast(strftime('%s','2026-02-25 10:05:00') as integer) * 1000, 1, 300, '', cast(strftime('%s','2026-02-25 10:00:00') as integer) * 1000, 1, 900001, 1, 'old call 2', '2026-04-24 10:00:00', '2026-04-24 10:00:00', ''),
('UT_CALL_KEEP_01', 'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 20003, '边界通话保留', '13900000001', '13800000003', '', 1, 1, 1, 3, cast(strftime('%s','2026-03-01 00:05:00') as integer) * 1000, 1, 300, '', cast(strftime('%s','2026-03-01 00:00:00') as integer) * 1000, 1, 900001, 1, 'boundary call', '2026-04-24 10:00:00', '2026-04-24 10:00:00', ''),
('UT_CALL_KEEP_02', 'UT_CLEANUP_AG_20260424', 'UT_CLEANUP_EMP_20260424', 20004, '近期通话保留', '13900000001', '13800000004', '', 1, 1, 1, 3, cast(strftime('%s','2026-03-12 10:05:00') as integer) * 1000, 1, 300, '', cast(strftime('%s','2026-03-12 10:00:00') as integer) * 1000, 1, 900001, 1, 'recent call', '2026-04-24 10:00:00', '2026-04-24 10:00:00', '');

commit;
