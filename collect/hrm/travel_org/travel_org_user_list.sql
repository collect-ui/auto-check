select
  r.relation_id,
  r.agency_id,
  r.user_id,
  r.role_type,
  r.supervisor_user_id,
  r.status,
  r.create_time,
  r.description,
  u.username,
  u.nick,
  u.phone,
  a.agency_name,
  s.nick as supervisor_name,
  s.username as supervisor_username
from travel_agency_user_rel r
join user_account u on u.user_id = r.user_id and ifnull(u.is_delete, '0') = '0'
left join user_account s on s.user_id = r.supervisor_user_id and ifnull(s.is_delete, '0') = '0'
left join travel_agency a on a.agency_id = r.agency_id
where r.agency_id = {{.agency_id}}
  and ifnull(r.status, 'normal') = 'normal'
  {{ if .role_type }}
  and r.role_type = {{.role_type}}
  {{ end }}
  {{ if .search }}
  and (u.nick like {{.search}} or u.username like {{.search}})
  {{ end }}
order by case when r.role_type='supervisor' then 0 else 1 end, r.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
