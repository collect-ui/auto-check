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
  max(ifnull(a.analyze_time, '')) over () as global_latest_analyze_time,
  a.*
from travel_call_record a
where 1=1
{{ if and .start_time (ne (printf "%v" .start_time) "0") }}
and ifnull(a.phone_start_time, 0) >= {{ .start_time }}
{{ else }}
and ifnull(a.phone_start_time, 0) >= cast(strftime('%s', 'now', printf('-%d day', {{ if .days }}{{ .days }}{{ else }}7{{ end }})) as integer) * 1000
{{ end }}
{{ if and .end_time (ne (printf "%v" .end_time) "0") }}
and ifnull(a.phone_start_time, 0) <= {{ .end_time }}
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
order by a.phone_start_time desc
limit {{ .limit }}
