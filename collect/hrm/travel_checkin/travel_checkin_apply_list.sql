select
  a.apply_id,
  a.agency_name,
  a.agency_code,
  a.contact_name,
  a.contact_phone,
  a.username,
  a.login_username,
  a.password,
  a.user_id,
  a.status,
  a.reject_reason,
  a.agency_id,
  a.create_time,
  a.audit_time,
  a.audit_user,
  coalesce(lu.username, fallback_u.username, '') as relation_username,
  coalesce(lu.nick, fallback_u.nick, '') as relation_nick,
  au.username as audit_username,
  au.nick as audit_nick
from travel_agency_checkin_apply a
left join user_account lu on lu.user_id = a.user_id
left join user_account fallback_u
  on fallback_u.username = coalesce(nullif(a.login_username, ''), a.agency_code)
 and ifnull(fallback_u.is_delete, '0') = '0'
left join user_account au on au.user_id = a.audit_user
where 1=1
  {{ if .apply_id }}
  and a.apply_id = {{.apply_id}}
  {{ end }}
  {{ if .apply_id_list }}
  and a.apply_id in ({{.apply_id_list}})
  {{ end }}
  {{ if .exclude_apply_id }}
  and a.apply_id != {{.exclude_apply_id}}
  {{ end }}
  {{ if .agency_code }}
  and a.agency_code = {{.agency_code}}
  {{ end }}
  {{ if .username }}
  and a.username = {{.username}}
  {{ end }}
  {{ if .login_username }}
  and a.login_username = {{.login_username}}
  {{ end }}
  {{ if .user_id }}
  and a.user_id = {{.user_id}}
  {{ end }}
  {{ if .status }}
  and a.status = {{.status}}
  {{ end }}
  {{ if .status_list }}
  and a.status in ({{.status_list}})
  {{ end }}
  {{ if .active_only }}
  and (
    a.status = 'pending'
    or (
      a.status = 'approved'
      and exists (
        select 1
        from travel_agency ta
        where ta.agency_id = a.agency_id
          and ifnull(nullif(ta.status, ''), 'normal') = 'normal'
      )
    )
  )
  {{ end }}
  {{ if .search }}
  and (
    a.agency_name like {{.search}}
    or a.agency_code like {{.search}}
    or a.contact_name like {{.search}}
    or a.contact_phone like {{.search}}
    or a.username like {{.search}}
    or a.login_username like {{.search}}
  )
  {{ end }}
order by
  case a.status
    when 'pending' then 1
    when 'rejected' then 2
    when 'approved' then 3
    when 'revoked' then 4
    else 5
  end,
  a.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
