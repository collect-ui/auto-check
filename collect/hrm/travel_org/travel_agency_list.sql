select
  a.*,
  (
    select count(1)
    from travel_agency_user_rel r
    where r.agency_id = a.agency_id
      and ifnull(r.status, 'normal') = 'normal'
  ) as member_count,
  (
    select count(1)
    from travel_agency_user_rel r
    where r.agency_id = a.agency_id
      and r.role_type = 'supervisor'
      and ifnull(r.status, 'normal') = 'normal'
  ) as supervisor_count,
  (
    select count(1)
    from travel_agency_user_rel r
    where r.agency_id = a.agency_id
      and r.role_type = 'sales'
      and ifnull(r.status, 'normal') = 'normal'
  ) as sales_count
from travel_agency a
where 1=1
  {{ if .search }}
  and (a.agency_name like {{.search}} or a.agency_code like {{.search}})
  {{ end }}
order by a.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
