select count(1) as count
from travel_agency a
where 1=1
  and ifnull(nullif(a.status, ''), 'normal') = 'normal'
  {{ if .agency_code }}
  and a.agency_code = {{.agency_code}}
  {{ end }}
  {{ if .checkin_status }}
  and a.checkin_status = {{.checkin_status}}
  {{ end }}
  {{ if .wx_sync_enabled }}
  and a.wx_sync_enabled = {{.wx_sync_enabled}}
  {{ end }}
  {{ if .search }}
  and (a.agency_name like {{.search}} or a.agency_code like {{.search}})
  {{ end }}
