select
  l.log_id,
  l.employee_id,
  l.agency_id,
  l.employee_name,
  l.analyze_source,
  l.is_escape,
  l.chat_count,
  l.call_count,
  l.chat_latest_message_time,
  l.call_latest_phone_time,
  l.system_prompt,
  l.prompt_content,
  l.ai_result,
  l.create_time,
  l.create_user
from travel_escape_analyze_log l
where 1 = 1
  {{ if .employee_id }}
  and l.employee_id = {{ .employee_id }}
  {{ end }}
  {{ if .agency_id }}
  and l.agency_id = {{ .agency_id }}
  {{ end }}
order by l.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
