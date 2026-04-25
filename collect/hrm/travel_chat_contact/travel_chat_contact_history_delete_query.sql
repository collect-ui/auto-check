select a.contact_id
from travel_chat_contact a
where 1=1
{{ if .agency_id }}
and a.agency_id = {{ .agency_id }}
{{ end }}
and ifnull(a.message_time, 0) > 0
and ifnull(a.message_time, 0) < {{ .cutoff_time }}
and not exists (
  select 1
  from travel_chat_record r
  where r.agency_id = a.agency_id
    and ifnull(r.message_time, 0) >= {{ .cutoff_time }}
    and (
      r.contact_id = a.contact_id
      or (
        ifnull(a.wx_id, '') != ''
        and ifnull(a.owner_wx_id, '') != ''
        and ifnull(r.contact_wx_id, '') = ifnull(a.wx_id, '')
        and ifnull(r.owner_wx_id, '') = ifnull(a.owner_wx_id, '')
      )
    )
)
order by a.message_time
