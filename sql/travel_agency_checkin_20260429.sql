CREATE TABLE IF NOT EXISTS travel_agency_checkin_apply (
  apply_id varchar(50) primary key,
  agency_name varchar(255),
  agency_code varchar(255),
  contact_name varchar(255),
  contact_phone varchar(64),
  username varchar(255),
  login_username varchar(255) default '',
  password varchar(255),
  user_id varchar(50),
  status varchar(32) default 'pending',
  reject_reason varchar(1000) default '',
  agency_id varchar(50) default '',
  create_time varchar(64),
  audit_time varchar(64) default '',
  audit_user varchar(64) default ''
);

CREATE INDEX IF NOT EXISTS idx_travel_checkin_apply_status ON travel_agency_checkin_apply(status);
CREATE INDEX IF NOT EXISTS idx_travel_checkin_apply_username ON travel_agency_checkin_apply(username);
CREATE INDEX IF NOT EXISTS idx_travel_checkin_apply_login_username ON travel_agency_checkin_apply(login_username);
CREATE INDEX IF NOT EXISTS idx_travel_checkin_apply_agency_code ON travel_agency_checkin_apply(agency_code);

INSERT INTO role(role_id, role_name, order_index, role_code)
SELECT 'company', '旅行社', 150, 'company'
WHERE NOT EXISTS (
  SELECT 1 FROM role WHERE role_id = 'company'
);

UPDATE sys_menu
SET menu_name = '商家组织维护'
WHERE menu_code = 'travel_org_manage';

UPDATE sys_menu
SET menu_name = '游客管理与分配'
WHERE menu_code = 'customer_assign_manage';

INSERT INTO sys_menu(
  sys_menu_id, menu_type, menu_name, menu_code, icon, is_index,
  group_path, router_group, group_api, api, data, url,
  in_menu, is_common, parent_id, create_time, create_user,
  order_index, description, belong_project, type
)
SELECT
  'travel_checkin_apply_menu',
  '2',
  '旅行社入住申请',
  'travel_checkin_apply',
  'FormOutlined',
  '0',
  '',
  '',
  '',
  'post:/template_data/data?service=frontend.travel_checkin_apply',
  'system/travel_checkin_apply.json',
  '/travel_checkin_apply',
  '0',
  '1',
  '',
  datetime('now'),
  'system',
  910,
  '旅行社免登录入住申请页面',
  'auto-check',
  ''
WHERE NOT EXISTS (
  SELECT 1 FROM sys_menu WHERE menu_code = 'travel_checkin_apply'
);

INSERT INTO sys_menu(
  sys_menu_id, menu_type, menu_name, menu_code, icon, is_index,
  group_path, router_group, group_api, api, data, url,
  in_menu, is_common, parent_id, create_time, create_user,
  order_index, description, belong_project, type
)
SELECT
  'travel_checkin_manage_menu',
  '2',
  '旅行社入住申请',
  'travel_checkin_manage',
  'FormOutlined',
  '0',
  '',
  'framework',
  '',
  'post:/template_data/data?service=frontend.travel_checkin_manage',
  'system/travel_checkin_manage.json',
  '/framework/travel_checkin_manage',
  '1',
  '0',
  '',
  datetime('now'),
  'system',
  911,
  '旅行社入住申请管理页面',
  'auto-check',
  ''
WHERE NOT EXISTS (
  SELECT 1 FROM sys_menu WHERE menu_code = 'travel_checkin_manage'
);

INSERT INTO role_menu(role_menu_id, role_id, sys_menu_id, belong_project)
SELECT 'role_menu_company_framework_group', 'company', 'eeb2fcd8-9e03-484f-8b89-d06f4ca41b81', 'auto-check'
WHERE NOT EXISTS (
  SELECT 1 FROM role_menu WHERE role_id = 'company' AND sys_menu_id = 'eeb2fcd8-9e03-484f-8b89-d06f4ca41b81'
);

INSERT INTO role_menu(role_menu_id, role_id, sys_menu_id, belong_project)
SELECT 'role_menu_company_framework', 'company', 'f87666f7-7032-4c9a-b5ee-fff9b2ca6824', 'auto-check'
WHERE NOT EXISTS (
  SELECT 1 FROM role_menu WHERE role_id = 'company' AND sys_menu_id = 'f87666f7-7032-4c9a-b5ee-fff9b2ca6824'
);

INSERT INTO role_menu(role_menu_id, role_id, sys_menu_id, belong_project)
SELECT 'role_menu_company_first', 'company', '9f477739-34e3-4fdb-acbc-9dcb0ad42ab3', 'auto-check'
WHERE NOT EXISTS (
  SELECT 1 FROM role_menu WHERE role_id = 'company' AND sys_menu_id = '9f477739-34e3-4fdb-acbc-9dcb0ad42ab3'
);

INSERT INTO role_menu(role_menu_id, role_id, sys_menu_id, belong_project)
SELECT 'role_menu_company_travel_org', 'company', '17fde24a-ec4c-4f8f-bc0d-e22f4e6354ff', 'auto-check'
WHERE NOT EXISTS (
  SELECT 1 FROM role_menu WHERE role_id = 'company' AND sys_menu_id = '17fde24a-ec4c-4f8f-bc0d-e22f4e6354ff'
);

INSERT INTO role_menu(role_menu_id, role_id, sys_menu_id, belong_project)
SELECT 'role_menu_company_customer_assign', 'company', '88f6431e-8763-4e4c-ba12-3acda7c30757', 'auto-check'
WHERE NOT EXISTS (
  SELECT 1 FROM role_menu WHERE role_id = 'company' AND sys_menu_id = '88f6431e-8763-4e4c-ba12-3acda7c30757'
);

INSERT INTO role_menu(role_menu_id, role_id, sys_menu_id, belong_project)
SELECT 'role_menu_company_tencent_key', 'company', 'tencent_key_apply', 'auto-check'
WHERE NOT EXISTS (
  SELECT 1 FROM role_menu WHERE role_id = 'company' AND sys_menu_id = 'tencent_key_apply'
);

INSERT INTO role_menu(role_menu_id, role_id, sys_menu_id, belong_project)
SELECT 'role_menu_admin_travel_checkin_manage', 'admin', 'travel_checkin_manage_menu', 'auto-check'
WHERE NOT EXISTS (
  SELECT 1 FROM role_menu WHERE role_id = 'admin' AND sys_menu_id = 'travel_checkin_manage_menu'
);
