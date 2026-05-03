select count(1) as count
from user_account a
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
