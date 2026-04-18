select
  e.employee_id,
  e.agency_id,
  max(r.message_time) as last_message_time,
  e.escape_last_analyze_time,
  a.agency_name,
  e.nick_name as employee_name
from travel_employee e
inner join travel_agency a on a.agency_id = e.agency_id
inner join travel_chat_record r on r.employee_id = e.employee_id
where ifnull(e.status, 'normal') = 'normal'
  and ifnull(a.wx_sync_enabled, 'no') = 'yes'
  and (a.checkin_status = 'checked_in' or a.checkin_status = 'active')
group by
  e.employee_id,
  e.agency_id,
  e.escape_last_analyze_time,
  a.agency_name,
  e.nick_name
having max(r.message_time) > ifnull(cast(strftime('%s', e.escape_last_analyze_time) as integer) * 1000, 0)
order by max(r.message_time) desc
limit {{.limit}}
