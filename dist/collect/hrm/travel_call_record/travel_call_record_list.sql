select
  datetime(a.phone_start_time / 1000, 'unixepoch', '+8 hours') as phone_start_time_formatted,
  datetime(a.phone_end_time / 1000, 'unixepoch', '+8 hours') as phone_end_time_formatted,
  case
    when ifnull(a.parsed_text, '') != '' then a.parsed_text
    else
      '电话' || ifnull(a.phone_out_number, '-') || ' -> ' || ifnull(a.phone_in_number, '-') ||
      '，通话类型' || ifnull(a.phone_call_type, 0) ||
      '，状态' || ifnull(a.phone_status, 0) ||
      '，时长' || ifnull(a.call_time_length, 0) || '秒'
  end as parsed_text,
  a.*
from travel_call_record a
where 1=1
{{ if .agency_id }}
and a.agency_id = {{ .agency_id }}
{{ end }}
{{ if .employee_id }}
and (
  a.employee_id = {{ .employee_id }}
  or (
    ifnull(a.employee_id, '') = ''
    and exists (
      select 1
      from travel_employee e
      where e.employee_id = {{ .employee_id }}
        and e.agency_id = a.agency_id
        and ifnull(e.phone, '') != ''
        and (a.phone_out_number = e.phone or a.phone_in_number = e.phone)
    )
  )
)
{{ end }}
{{ if .employee_scope_token }}
and instr({{ .employee_scope_token }}, ',' || ifnull(a.employee_id, '') || ',') > 0
{{ end }}
{{ if .start_time }}
and a.phone_start_time >= {{ .start_time }}
{{ end }}
{{ if .end_time }}
and a.phone_start_time <= {{ .end_time }}
{{ end }}
{{ if .no_record_text }}
and ifnull(a.phone_record_address,'') != ''
and ifnull(a.phone_record_text,'') = ''
{{ end }}
order by a.phone_start_time desc
limit {{ .limit }}
