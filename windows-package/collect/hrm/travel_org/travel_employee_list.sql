select
  e.*,
  (
    select count(1)
    from travel_call_record r
    where r.agency_id = e.agency_id
      and ifnull(e.phone, '') != ''
      and (r.phone_out_number = e.phone or r.phone_in_number = e.phone)
      and r.phone_start_time >= (strftime('%s', 'now', '-30 day') * 1000)
  ) as call_count,
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
