select
  a.*,
  (
    select count(1)
    from travel_employee e
    where e.agency_id = a.agency_id
      and ifnull(e.status, 'normal') = 'normal'
  ) as employee_count
from travel_agency a
where 1=1
  and ifnull(nullif(a.status, ''), 'normal') = 'normal'
  and (
    exists(
      select 1
      from user_role_id_list ur
      where ur.user_id = {{.session_user_id}}
        and ur.role_id = 'admin'
    )
    or exists(
      select 1
      from travel_agency_user_rel r
      where r.agency_id = a.agency_id
        and r.user_id = {{.session_user_id}}
        and ifnull(r.status, 'normal') = 'normal'
    )
  )
  {{ if .agency_id }}
  and a.agency_id = {{.agency_id}}
  {{ end }}
  {{ if .agency_code }}
  and a.agency_code = {{.agency_code}}
  {{ end }}
  {{ if .checkin_status }}
  and a.checkin_status = {{.checkin_status}}
  {{ end }}
  {{ if .wx_sync_enabled }}
  and a.wx_sync_enabled = {{.wx_sync_enabled}}
  {{ end }}
  {{ if .search }}
  and (a.agency_name like {{.search}} or a.agency_code like {{.search}})
  {{ end }}
order by
  case
    when exists(
      select 1
      from travel_agency_user_rel r1
      where r1.agency_id = a.agency_id
        and r1.user_id = {{.session_user_id}}
        and ifnull(r1.status, 'normal') = 'normal'
    ) then 0
    else 1
  end,
  a.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
