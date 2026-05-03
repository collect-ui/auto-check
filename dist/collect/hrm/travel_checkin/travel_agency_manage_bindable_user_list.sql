select
  a.user_id,
  a.username,
  a.nick,
  (
    select r.relation_id
    from travel_agency_user_rel r
    where r.user_id = a.user_id
      and ifnull(r.status, 'normal') = 'normal'
      and r.role_type = 'admin'
    order by
      case when r.agency_id = {{.agency_id}} then 0 else 1 end,
      r.create_time desc
    limit 1
  ) as bound_relation_id,
  (
    select r.agency_id
    from travel_agency_user_rel r
    where r.user_id = a.user_id
      and ifnull(r.status, 'normal') = 'normal'
      and r.role_type = 'admin'
    order by
      case when r.agency_id = {{.agency_id}} then 0 else 1 end,
      r.create_time desc
    limit 1
  ) as bound_agency_id,
  (
    select ta.agency_code
    from travel_agency ta
    where ta.agency_id = (
      select r.agency_id
      from travel_agency_user_rel r
      where r.user_id = a.user_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.role_type = 'admin'
      order by
        case when r.agency_id = {{.agency_id}} then 0 else 1 end,
        r.create_time desc
      limit 1
    )
    limit 1
  ) as bound_agency_code,
  (
    select ta.agency_name
    from travel_agency ta
    where ta.agency_id = (
      select r.agency_id
      from travel_agency_user_rel r
      where r.user_id = a.user_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.role_type = 'admin'
      order by
        case when r.agency_id = {{.agency_id}} then 0 else 1 end,
        r.create_time desc
      limit 1
    )
    limit 1
  ) as bound_agency_name,
  (
    select ifnull(r.status, 'normal')
    from travel_agency_user_rel r
    where r.user_id = a.user_id
      and ifnull(r.status, 'normal') = 'normal'
      and r.role_type = 'admin'
    order by
      case when r.agency_id = {{.agency_id}} then 0 else 1 end,
      r.create_time desc
    limit 1
  ) as bound_relation_status,
  case
    when exists(
      select 1
      from travel_agency_user_rel r
      where r.user_id = a.user_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.role_type = 'admin'
        and r.agency_id = {{.agency_id}}
    ) then 'current'
    when exists(
      select 1
      from travel_agency_user_rel r
      where r.user_id = a.user_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.role_type = 'admin'
        and r.agency_id != {{.agency_id}}
    ) then 'other'
    else 'none'
  end as bind_status,
  'yes' as can_transfer,
  case
    when exists(
      select 1
      from travel_agency_user_rel r
      where r.user_id = a.user_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.role_type = 'admin'
        and r.agency_id = {{.agency_id}}
    ) then ifnull(a.nick, '-') || '(' || a.username || ') [当前已绑定]'
    when exists(
      select 1
      from travel_agency_user_rel r
      where r.user_id = a.user_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.role_type = 'admin'
        and r.agency_id != {{.agency_id}}
    ) then ifnull(a.nick, '-') || '(' || a.username || ') [当前绑定: '
      || ifnull((
        select ta.agency_code
        from travel_agency ta
        where ta.agency_id = (
          select r.agency_id
          from travel_agency_user_rel r
          where r.user_id = a.user_id
            and ifnull(r.status, 'normal') = 'normal'
            and r.role_type = 'admin'
            and r.agency_id != {{.agency_id}}
          order by r.create_time desc
          limit 1
        )
        limit 1
      ), '-') || '/' || ifnull((
        select ta.agency_name
        from travel_agency ta
        where ta.agency_id = (
          select r.agency_id
          from travel_agency_user_rel r
          where r.user_id = a.user_id
            and ifnull(r.status, 'normal') = 'normal'
            and r.role_type = 'admin'
            and r.agency_id != {{.agency_id}}
          order by r.create_time desc
          limit 1
        )
        limit 1
      ), '-') || ']'
    else ifnull(a.nick, '-') || '(' || a.username || ')'
  end as option_label
from user_account a
where ifnull(a.status, '1') != '0'
  and ifnull(a.is_delete, '0') = '0'
  {{ if .search }}
  and (
    a.username like {{.search}}
    or a.nick like {{.search}}
    or (ifnull(a.nick, '-') || '(' || a.username || ')') like {{.search}}
  )
  {{ end }}
order by
  case
    when exists(
      select 1
      from travel_agency_user_rel r
      where r.user_id = a.user_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.role_type = 'admin'
        and r.agency_id = {{.agency_id}}
    ) then 0
    when exists(
      select 1
      from travel_agency_user_rel r
      where r.user_id = a.user_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.role_type = 'admin'
        and r.agency_id != {{.agency_id}}
    ) then 1
    else 2
  end,
  a.username
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
