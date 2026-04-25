select a.uid
from travel_chat_record a
where 1=1
{{ if .agency_id }}
and a.agency_id = {{ .agency_id }}
{{ end }}
and ifnull(a.message_time, 0) > 0
and ifnull(a.message_time, 0) < {{ .cutoff_time }}
order by a.message_time
