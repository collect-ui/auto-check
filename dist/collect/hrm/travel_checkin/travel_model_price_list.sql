select
  p.model_price_id,
  p.provider,
  p.model_name,
  p.currency,
  ifnull(p.input_cache_hit_price_per_1m, 0) as input_cache_hit_price_per_1m,
  ifnull(p.input_cache_miss_price_per_1m, 0) as input_cache_miss_price_per_1m,
  ifnull(p.output_price_per_1m, 0) as output_price_per_1m,
  ifnull(p.description, '') as description,
  ifnull(p.status, 'normal') as status,
  p.create_time,
  p.create_user,
  ifnull(p.modify_time, '') as modify_time,
  ifnull(p.modify_user, '') as modify_user
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
order by ifnull(p.modify_time, p.create_time) desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}

