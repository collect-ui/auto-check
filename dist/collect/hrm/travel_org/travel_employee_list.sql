select
  e.*,
  (
    select count(1)
    from travel_call_record r
    where r.agency_id = e.agency_id
      and (
        r.employee_id = e.employee_id
        or (
          ifnull(r.employee_id, '') = ''
          and ifnull(e.phone, '') != ''
          and (r.phone_out_number = e.phone or r.phone_in_number = e.phone)
        )
      )
      and r.phone_start_time >= (strftime('%s', 'now', '-30 day') * 1000)
  ) as call_count,
  (
    select count(1)
    from travel_chat_contact c
    where c.agency_id = e.agency_id
      and c.employee_id = e.employee_id
      and ifnull(c.is_group, 0) = 0
  ) as chat_person_count,
  (
    select count(1)
    from travel_chat_contact c
    where c.agency_id = e.agency_id
      and c.employee_id = e.employee_id
      and ifnull(c.is_group, 0) = 1
  ) as chat_group_count,
  (
    select count(1)
    from travel_escape_issue i
    where i.employee_id = e.employee_id
      and ifnull(i.issue_status, 'pending') = 'pending'
  ) as pending_issue_count,
  a.agency_name
from travel_employee e
left join travel_agency a on a.agency_id = e.agency_id
where e.agency_id = {{.agency_id}}
  and ifnull(e.status, 'normal') = 'normal'
  {{ if .search }}
  and (
    e.nick_name like {{.search}}
    or e.phone like {{.search}}
    or e.ower_wx_alias like {{.search}}
    or e.wx_id like {{.search}}
  )
  {{ end }}
{{ if .employee_id}}  
and e.employee_id = {{.employee_id}}
{{ end }}
order by e.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
