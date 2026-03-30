select
datetime(a.message_time / 1000, 'unixepoch', 'localtime') AS message_time_formatted,
0 as is_self,
null as owner_alias,
a.*
from travel_chat_record a
where 1=1
{{ if .agency_id }}
and a.agency_id = {{ .agency_id }}
{{ end }}
{{ if .employee_id }}
and a.employee_id = {{ .employee_id }}
{{ end }}
{{ if .contact_id }}
and a.contact_id = {{ .contact_id }}
{{ end }}
{{ if .message_time_from }}
and a.message_time >= {{ .message_time_from }}
{{ end }}
{{ if .message_time_to }}
and a.message_time <= {{ .message_time_to }}
{{ end }}
order by a.message_time
limit 500