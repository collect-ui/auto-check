select count(1)
from travel_escape_issue i
where 1 = 1
  {{ if .employee_id }}
  and i.employee_id = {{.employee_id}}
  {{ end }}
  {{ if .agency_id }}
  and i.agency_id = {{.agency_id}}
  {{ end }}
  {{ if .issue_status }}
  and i.issue_status = {{.issue_status}}
  {{ end }}
