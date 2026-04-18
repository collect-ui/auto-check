select
  a.content,
  datetime(a.message_time / 1000, 'unixepoch', 'localtime') AS message_time_formatted,
  a.message_type,
  a.contact_nick_name
from travel_chat_record a
where a.employee_id = {{ .employee_id }}
order by a.message_time desc
limit {{ if .limit }}{{ .limit }}{{ else }}100{{ end }}
