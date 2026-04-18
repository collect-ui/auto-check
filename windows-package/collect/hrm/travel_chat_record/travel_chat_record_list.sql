select
datetime(a.message_time / 1000, 'unixepoch', '+8 hours') AS message_time_formatted,
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
and (
  a.contact_id = {{ .contact_id }}
  or (
    a.contact_wx_id = (
      select c.wx_id
      from travel_chat_contact c
      where c.contact_id = {{ .contact_id }}
      limit 1
    )
    and a.owner_wx_id = (
      select c.owner_wx_id
      from travel_chat_contact c
      where c.contact_id = {{ .contact_id }}
      limit 1
    )
  )
)
{{ end }}
{{ if .message_time_from }}
and a.message_time >= {{ .message_time_from }}
{{ end }}
{{ if .message_time_to }}
and a.message_time <= {{ .message_time_to }}
{{ end }}
{{ if .no_file_text }}
and ifnull(a.file_text,'') = '' and ifnull(a.file_name,'') != ''
{{ end }}
order by a.message_time
limit {{.limit}}
