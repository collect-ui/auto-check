select count(1) as count
from travel_model_price p
where 1 = 1
  and ifnull(p.status, 'normal') = 'normal'
  {{ if .provider }}
  and p.provider = {{.provider}}
  {{ end }}
  {{ if .currency }}
  and p.currency = {{.currency}}
  {{ end }}
  {{ if .search }}
  and (
    p.model_name like {{.search}}
    or p.provider like {{.search}}
    or ifnull(p.description, '') like {{.search}}
  )
  {{ end }}

