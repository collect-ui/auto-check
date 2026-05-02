select distinct
  a.user_id
from user_role_id_list a
where a.user_id in ({{.user_id_list}})
  {{ if .exclude_role_id }}
  and a.role_id != {{.exclude_role_id}}
  {{ end }}
