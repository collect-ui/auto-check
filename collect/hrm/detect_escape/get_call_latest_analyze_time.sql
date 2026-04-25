select
  coalesce(max(ifnull(c.analyze_time, '')), '') as call_latest_analyze_time
from travel_call_record c
where c.employee_id = {{ .employee_id }}
  and ifnull(c.phone_start_time, 0) >= cast(strftime('%s', 'now', printf('-%d day', {{ if .days }}{{ .days }}{{ else }}7{{ end }})) as integer) * 1000
