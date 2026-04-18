select
  l.lead_id,
  l.agency_id,
  a.agency_name,
  l.customer_name,
  l.contact,
  l.wechat_account,
  l.source_platform,
  l.status,
  l.description,
  l.create_time,
  ca.assign_id,
  ca.assign_date,
  ca.sales_user_id,
  su.nick as sales_nick,
  su.username as sales_username,
  ca.route_id,
  tr.route_code,
  tr.route_name,
  ca.supervisor_user_id,
  spu.nick as supervisor_nick
from customer_lead_pool l
left join travel_agency a on a.agency_id = l.agency_id
left join customer_lead_assign ca
  on ca.assign_id = (
    select ca2.assign_id
    from customer_lead_assign ca2
    where ca2.lead_id = l.lead_id
      and ifnull(ca2.status, 'normal') = 'normal'
      and ca2.assign_date between {{.assign_date_start}} and {{.assign_date_end}}
    order by ca2.assign_date desc, ca2.update_time desc
    limit 1
  )
left join user_account su on su.user_id = ca.sales_user_id and ifnull(su.is_delete, '0') = '0'
left join travel_agency_route tr on tr.route_id = ca.route_id and ifnull(tr.status,'normal')='normal'
left join user_account spu on spu.user_id = ca.supervisor_user_id and ifnull(spu.is_delete, '0') = '0'
where ifnull(l.status, 'normal') = 'normal'
  {{ if .assign_date_filter_enabled }}
  and ca.assign_id is not null
  {{ end }}
  {{ if .agency_id }}
  and l.agency_id = {{.agency_id}}
  {{ end }}
  {{ if .search }}
  and (
    l.customer_name like {{.search}}
    or l.contact like {{.search}}
    or l.wechat_account like {{.search}}
  )
  {{ end }}
order by l.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
