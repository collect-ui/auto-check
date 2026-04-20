select count(1)
from travel_escape_analyze_log l
where 1 = 1
  {{ if .employee_id }}
  and l.employee_id = {{ .employee_id }}
  {{ end }}
  {{ if .agency_id }}
  and l.agency_id = {{ .agency_id }}
  {{ end }}
