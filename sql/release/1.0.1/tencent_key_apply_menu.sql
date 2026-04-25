-- 腾讯 Key 申请菜单 seed
-- 运行前请确认当前项目使用的 belong_project 为 auto-check

-- 1. 更新已存在菜单的展示信息
update sys_menu
set
  menu_name = '腾讯Key申请',
  icon = 'KeyOutlined',
  menu_type = '2',
  router_group = 'framework',
  api = 'post:/template_data/data?service=frontend.tencent_key_apply',
  url = '/framework/tencent_key_apply',
  data = 'system/tencent_key_apply.json',
  in_menu = '1',
  is_common = '1',
  parent_id = '',
  type = '',
  belong_project = 'auto-check'
where menu_code = 'tencent_key_apply'
  and belong_project = 'auto-check';

-- 2. 不存在时插入菜单
insert into sys_menu (
  sys_menu_id,
  menu_type,
  menu_name,
  menu_code,
  icon,
  is_index,
  router_group,
  api,
  data,
  url,
  in_menu,
  is_common,
  description,
  order_index,
  create_time,
  create_user,
  parent_id,
  belong_project,
  type
)
select
  'tencent_key_apply',
  '2',
  '腾讯Key申请',
  'tencent_key_apply',
  'KeyOutlined',
  '0',
  'framework',
  'post:/template_data/data?service=frontend.tencent_key_apply',
  'system/tencent_key_apply.json',
  '/framework/tencent_key_apply',
  '1',
  '1',
  '旅行社腾讯云语音 Key 自助申请',
  coalesce((
    select max(order_index) + 1
    from sys_menu
    where belong_project = 'auto-check'
      and router_group = '/framework'
  ), 999),
  datetime('now', 'localtime'),
  'codex',
  '',
  'auto-check',
  ''
where not exists (
  select 1
  from sys_menu
  where menu_code = 'tencent_key_apply'
    and belong_project = 'auto-check'
);

-- 3. 如需只开放给特定角色，请将 is_common 改为 0 后，再插入 role_menu
-- insert into role_menu (role_menu_id, role_id, sys_menu_id, belong_project)
-- select
--   lower(hex(randomblob(16))),
--   'your_role_id',
--   m.sys_menu_id,
--   'auto-check'
-- from sys_menu m
-- where m.menu_code = 'tencent_key_apply'
--   and m.belong_project = 'auto-check'
--   and not exists (
--     select 1
--     from role_menu rm
--     where rm.role_id = 'your_role_id'
--       and rm.sys_menu_id = m.sys_menu_id
--       and rm.belong_project = 'auto-check'
--   );
