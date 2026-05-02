select count(1)
from travel_agency_tencent_key k
left join travel_agency a
  on a.agency_id = k.agency_id
where 1=1
  and ifnull(k.is_delete, '0') = '0'
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
      where r.agency_id = k.agency_id
        and r.user_id = {{.session_user_id}}
        and ifnull(r.status, 'normal') = 'normal'
    )
  )
  {{ if .key_id }}
  and k.key_id = {{.key_id}}
  {{ end }}
  {{ if .agency_id }}
  and k.agency_id = {{.agency_id}}
  {{ end }}
  {{ if .account_name }}
  and k.account_name = {{.account_name}}
  {{ end }}
  {{ if .status }}
  and k.status = {{.status}}
  {{ end }}
  {{ if .source_type }}
  and k.source_type = {{.source_type}}
  {{ end }}
  {{ if .search }}
  and (
    k.account_name like {{.search}}
    or ifnull(a.agency_name, '') like {{.search}}
    or ifnull(a.agency_code, '') like {{.search}}
  )
  {{ end }}
