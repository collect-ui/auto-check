select
    a.user_id,
    a.password as password,
    (
        SELECT GROUP_CONCAT(ur.role_name)
        FROM role ur
        left join user_role_id_list r  on  r.role_id  = ur.role_id
        where  r.user_id  = a.user_id
    ) as role_names,
    (
        SELECT GROUP_CONCAT(ur.role_code)
        FROM role ur
        left join user_role_id_list r  on  r.role_id  = ur.role_id
        where  r.user_id  = a.user_id
    ) as roles,
    (
        SELECT ur.role_code
        FROM role ur
        join user_role_id_list r on r.role_id = ur.role_id
        where r.user_id = a.user_id
          and ur.role_code in ('sales', 'customer_service')
        order by ur.role_code
        limit 1
    ) as role_code,
    c.sys_code_text as status_text,
    a.*
from user_account a
left join sys_code c on a.status = c.sys_code and c.sys_code_type = 'user_job_status'
where ifnull(a.status,'1')!='0'
  and a.is_delete = '0'
  {{ if .search }}
  and (a.nick like {{.search}} or a.username like {{.search}})
  {{ end }}
  and exists(
      select 1
      from user_role_id_list ur
      where a.user_id = ur.user_id
        and ur.role_id in ({{.role_id_list}})
  )
order by a.username
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
