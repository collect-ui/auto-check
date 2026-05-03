select
  coalesce(a.agency_id, fallback_agency.agency_id, '') as agency_id,
  coalesce(a.agency_name, fallback_agency.agency_name, '') as agency_name,
  coalesce(a.agency_code, fallback_agency.agency_code, '') as agency_code,
  u.user_id,
  u.username,
  u.nick,
  case
    when ifnull(u.nick, '') <> '' then u.nick
    else u.username
  end as applicant_name
from user_account u
left join travel_agency_user_rel r
  on r.user_id = u.user_id
 and ifnull(nullif(r.status, ''), 'normal') = 'normal'
left join travel_agency a
  on a.agency_id = r.agency_id
left join (
  select
    agency_id,
    agency_name,
    agency_code
  from travel_agency
  where ifnull(nullif(status, ''), 'normal') = 'normal'
  order by
    ifnull(create_time, '') asc,
    agency_id asc
  limit 1
) fallback_agency
where u.user_id = {{.session_user_id}}
  and ifnull(u.is_delete, '0') = '0'
  and (
    a.agency_id is null
    or ifnull(nullif(a.status, ''), 'normal') = 'normal'
  )
order by
  case when ifnull(r.role_type, '') = 'admin' then 0 else 1 end asc,
  ifnull(r.create_time, '') desc
limit 1
