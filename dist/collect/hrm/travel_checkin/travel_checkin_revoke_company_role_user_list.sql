select distinct
  r.user_id
from travel_agency_user_rel r
where r.agency_id = {{.agency_id}}
  and ifnull(r.status, 'normal') = 'normal'
  and not exists (
    select 1
    from travel_agency_user_rel r2
    where r2.user_id = r.user_id
      and ifnull(r2.status, 'normal') = 'normal'
      and r2.agency_id != {{.agency_id}}
  )
