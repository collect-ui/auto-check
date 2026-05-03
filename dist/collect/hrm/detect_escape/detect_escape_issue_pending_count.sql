select count(1) as pending_count
from travel_escape_issue i
where ifnull(i.issue_status, 'pending') = 'pending'
  {{ if .agency_id }}
  and i.agency_id = {{.agency_id}}
  {{ end }}
