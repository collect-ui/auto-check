select count(1) as count
from travel_agency_user_rel r
join user_account u on u.user_id = r.user_id and ifnull(u.is_delete, '0') = '0'
where r.agency_id = {{.agency_id}}
  and ifnull(r.status, 'normal') = 'normal'
  {{ if .role_type }}
  and r.role_type = {{.role_type}}
  {{ end }}
  {{ if .search }}
  and (u.nick like {{.search}} or u.username like {{.search}})
  {{ end }}
