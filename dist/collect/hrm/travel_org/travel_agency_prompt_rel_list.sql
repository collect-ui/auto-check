select
  r.rel_id,
  r.agency_id,
  r.prompt_type,
  r.keyword,
  r.sort_no
from travel_agency_escape_prompt_rel r
where r.agency_id = {{.agency_id}}
  and ifnull(r.status, 'normal') = 'normal'
  {{if .search}}and r.keyword like {{.search}}{{end}}
order by r.prompt_type asc, r.sort_no asc, r.create_time asc
