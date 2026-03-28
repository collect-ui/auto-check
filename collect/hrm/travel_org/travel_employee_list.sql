select
  e.*,
  a.agency_name
from travel_employee e
left join travel_agency a on a.agency_id = e.agency_id
where e.agency_id = {{.agency_id}}
  and ifnull(e.status, 'normal') = 'normal'
  {{ if .search }}
  and (
    e.nick_name like {{.search}}
    or e.phone like {{.search}}
    or e.ower_wx_alias like {{.search}}
    or e.wx_id like {{.search}}
  )
  {{ end }}
order by e.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}