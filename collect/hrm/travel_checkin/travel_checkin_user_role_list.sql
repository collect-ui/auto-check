select
  a.*
from user_role_id_list a
where a.user_id = {{.user_id}}
  {{ if .role_id }}
  and a.role_id = {{.role_id}}
  {{ end }}
order by a.create_time desc
