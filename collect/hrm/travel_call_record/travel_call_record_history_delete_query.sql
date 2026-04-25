select a.uid
from travel_call_record a
where 1=1
{{ if .agency_id }}
and a.agency_id = {{ .agency_id }}
{{ end }}
and ifnull(a.phone_start_time, 0) > 0
and ifnull(a.phone_start_time, 0) < {{ .cutoff_time }}
order by a.phone_start_time
