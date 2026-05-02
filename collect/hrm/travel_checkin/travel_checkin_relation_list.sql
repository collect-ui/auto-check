select
  r.*
from travel_agency_user_rel r
where 1=1
  {{ if .relation_id }}
  and r.relation_id = {{.relation_id}}
  {{ end }}
  {{ if .agency_id }}
  and r.agency_id = {{.agency_id}}
  {{ end }}
  {{ if .user_id }}
  and r.user_id = {{.user_id}}
  {{ end }}
  {{ if .role_type }}
  and r.role_type = {{.role_type}}
  {{ end }}
  {{ if .status }}
  and ifnull(r.status, 'normal') = {{.status}}
  {{ end }}
order by r.create_time desc
