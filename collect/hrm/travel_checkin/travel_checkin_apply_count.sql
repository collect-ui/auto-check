select count(1)
from travel_agency_checkin_apply a
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
