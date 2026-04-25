with emp_scope as (
  select
    e.employee_id,
    e.agency_id,
    e.nick_name as employee_name,
    ifnull(e.phone, '') as phone
  from travel_employee e
  inner join travel_agency a on a.agency_id = e.agency_id
  where ifnull(e.status, 'normal') = 'normal'
    and ifnull(a.wx_sync_enabled, 'no') = 'yes'
    and (a.checkin_status = 'checked_in' or a.checkin_status = 'active')
    {{ if .agency_id }}
    and e.agency_id = {{ .agency_id }}
    {{ end }}
),
last_log as (
  select
    l.employee_id,
    max(
      max(
        ifnull(l.chat_latest_message_time, 0),
        ifnull(l.call_latest_phone_time, 0),
        case
          when ifnull(l.chat_latest_message_time, 0) > 0
            or ifnull(l.call_latest_phone_time, 0) > 0
            then 0
          else cast(strftime('%s', l.create_time, '-8 hours') as integer) * 1000
        end
      )
    ) as last_analyze_time_ms
  from travel_escape_analyze_log l
  inner join emp_scope e on e.employee_id = l.employee_id
  group by l.employee_id
),
last_log_time as (
  select
    l.employee_id,
    max(
      max(
        case
          when ifnull(l.chat_latest_analyze_time, '') glob '????-??-?? ??:??:??'
            then l.chat_latest_analyze_time
          else ''
        end,
        case
          when ifnull(l.call_latest_analyze_time, '') glob '????-??-?? ??:??:??'
            then l.call_latest_analyze_time
          else ''
        end,
        case
          when ifnull(l.chat_latest_message_time, 0) > 0
            then datetime(l.chat_latest_message_time / 1000, 'unixepoch', '+8 hours')
          else ''
        end,
        case
          when ifnull(l.call_latest_phone_time, 0) > 0
            then datetime(l.call_latest_phone_time / 1000, 'unixepoch', '+8 hours')
          else ''
        end,
        ifnull(l.create_time, '')
      )
    ) as last_analyze_time
  from travel_escape_analyze_log l
  inner join emp_scope e on e.employee_id = l.employee_id
  group by l.employee_id
),
chat_latest as (
  select
    r.employee_id,
    max(ifnull(r.message_time, 0)) as chat_latest_message_time,
    max(ifnull(r.analyze_time, '')) as chat_latest_analyze_time
  from travel_chat_record r
  inner join emp_scope e on e.employee_id = r.employee_id
  group by r.employee_id
),
call_by_employee as (
  select
    c.employee_id,
    max(ifnull(c.phone_start_time, 0)) as call_latest_phone_time,
    max(ifnull(c.analyze_time, '')) as call_latest_analyze_time
  from travel_call_record c
  inner join emp_scope e on e.employee_id = c.employee_id
  where ifnull(c.employee_id, '') != ''
  group by c.employee_id
),
call_by_phone as (
  select
    e.employee_id,
    max(ifnull(c.phone_start_time, 0)) as call_latest_phone_time,
    max(ifnull(c.analyze_time, '')) as call_latest_analyze_time
  from emp_scope e
  inner join travel_call_record c
    on c.agency_id = e.agency_id
    and ifnull(c.employee_id, '') = ''
    and e.phone != ''
    and (c.phone_out_number = e.phone or c.phone_in_number = e.phone)
  group by e.employee_id
),
call_latest as (
  select
    t.employee_id,
    max(t.call_latest_phone_time) as call_latest_phone_time,
    max(t.call_latest_analyze_time) as call_latest_analyze_time
  from (
    select employee_id, call_latest_phone_time, call_latest_analyze_time from call_by_employee
    union all
    select employee_id, call_latest_phone_time, call_latest_analyze_time from call_by_phone
  ) t
  group by t.employee_id
)
select
  e.employee_id,
  e.agency_id,
  a.agency_name,
  e.employee_name,
  ifnull(cl.chat_latest_message_time, 0) as chat_latest_message_time,
  ifnull(cal.call_latest_phone_time, 0) as call_latest_phone_time,
  ifnull(cl.chat_latest_analyze_time, '') as chat_latest_analyze_time,
  ifnull(cal.call_latest_analyze_time, '') as call_latest_analyze_time,
  ifnull(ll.last_analyze_time_ms, 0) as last_analyze_time_ms,
  ifnull(llt.last_analyze_time, '') as last_analyze_time,
  max(ifnull(cl.chat_latest_message_time, 0), ifnull(cal.call_latest_phone_time, 0)) as latest_event_time,
  max(ifnull(cl.chat_latest_analyze_time, ''), ifnull(cal.call_latest_analyze_time, '')) as latest_analyze_time
from emp_scope e
inner join travel_agency a on a.agency_id = e.agency_id
left join chat_latest cl on cl.employee_id = e.employee_id
left join call_latest cal on cal.employee_id = e.employee_id
left join last_log ll on ll.employee_id = e.employee_id
left join last_log_time llt on llt.employee_id = e.employee_id
where
  max(ifnull(cl.chat_latest_message_time, 0), ifnull(cal.call_latest_phone_time, 0)) > ifnull(ll.last_analyze_time_ms, 0)
  or (
    max(ifnull(cl.chat_latest_analyze_time, ''), ifnull(cal.call_latest_analyze_time, '')) != ''
    and max(ifnull(cl.chat_latest_analyze_time, ''), ifnull(cal.call_latest_analyze_time, '')) > ifnull(llt.last_analyze_time, '')
  )
order by latest_event_time desc
limit {{.limit}}
