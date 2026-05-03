select count(1) as count
from customer_lead_pool l
where ifnull(l.status, 'normal') = 'normal'
  {{ if .assign_date_filter_enabled }}
  and exists (
    select 1
    from customer_lead_assign ca
    where ca.lead_id = l.lead_id
      and ifnull(ca.status, 'normal') = 'normal'
      and ca.assign_date between {{.assign_date_start}} and {{.assign_date_end}}
  )
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
