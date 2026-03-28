select
  a.*,
  (
    select count(1)
    from travel_employee e
    where e.agency_id = a.agency_id
      and ifnull(e.status, 'normal') = 'normal'
  ) as employee_count
from travel_agency a
where 1=1
  {{ if .agency_id }}
  and a.agency_id = {{.agency_id}}
  {{ end }}
  {{ if .search }}
  and (a.agency_name like {{.search}} or a.agency_code like {{.search}})
  {{ end }}
order by a.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
