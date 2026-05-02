select distinct
  r.user_id
from travel_agency_user_rel r
where r.user_id in ({{.user_id_list}})
  and ifnull(r.status, 'normal') = 'normal'
  and r.agency_id != {{.agency_id}}
