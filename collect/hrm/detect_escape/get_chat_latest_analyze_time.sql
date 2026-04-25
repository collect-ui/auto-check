select
  coalesce(max(ifnull(r.analyze_time, '')), '') as chat_latest_analyze_time
from travel_chat_record r
where r.employee_id = {{ .employee_id }}
  and ifnull(r.message_time, 0) >= cast(strftime('%s', 'now', printf('-%d day', {{ if .days }}{{ .days }}{{ else }}7{{ end }})) as integer) * 1000
