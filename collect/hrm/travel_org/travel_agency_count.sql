select count(1) as count
from travel_agency a
where 1=1
  {{ if .search }}
  and (a.agency_name like {{.search}} or a.agency_code like {{.search}})
  {{ end }}
