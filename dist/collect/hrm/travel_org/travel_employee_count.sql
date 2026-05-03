select count(1) as count
from travel_employee e
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