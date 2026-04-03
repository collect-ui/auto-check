select
  e.employee_id,
  e.nick_name as employee_name,
  e.alias as employee_alias,
  e.phone as employee_phone,
  e.wx_id as employee_wx_id,
  a.agency_id,
  a.agency_name
from travel_employee e
left join travel_agency a on e.agency_id = a.agency_id
where e.employee_id = {{ .employee_id }}
