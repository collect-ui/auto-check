select

datetime(a.message_time / 1000, 'unixepoch', 'localtime') AS message_time_formatted,
a.*
from travel_chat_contact a
where 1=1
{{ if .agency_id }}
and a.agency_id = {{ .agency_id }}
{{ end }}
{{ if .employee_id }}
and a.employee_id = {{ .employee_id }}
{{ end}}
order by a.message_time desc
limit 500