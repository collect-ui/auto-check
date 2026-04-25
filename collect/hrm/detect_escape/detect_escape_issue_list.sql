select
  i.*,
  case
    when ifnull(i.issue_status, 'pending') = 'pending' then '待处理'
    when i.issue_status = 'processed' then '已处理'
    when i.issue_status = 'ignored' then '已忽略'
    else ifnull(i.issue_status, '-')
  end as issue_status_name
from travel_escape_issue i
where 1 = 1
  {{ if .employee_id }}
  and i.employee_id = {{.employee_id}}
  {{ end }}
  {{ if .agency_id }}
  and i.agency_id = {{.agency_id}}
  {{ end }}
  {{ if .issue_status }}
  and i.issue_status = {{.issue_status}}
  {{ end }}
order by
  case when ifnull(i.issue_status, 'pending') = 'pending' then 0 else 1 end asc,
  ifnull(i.create_time, '') desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
