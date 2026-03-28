select
  r.user_id as value,
  (u.nick || '（' || u.username || '）') as label,
  r.supervisor_user_id
from travel_agency_user_rel r
join user_account u on u.user_id = r.user_id and ifnull(u.is_delete, '0') = '0'
where r.agency_id = {{.agency_id}}
  and r.role_type = 'sales'
  and ifnull(r.status, 'normal') = 'normal'
order by u.nick asc
