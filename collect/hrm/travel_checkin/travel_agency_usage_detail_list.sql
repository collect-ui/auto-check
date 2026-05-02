select
  l.log_id,
  l.agency_id,
  l.employee_id,
  l.employee_name,
  l.analyze_source,
  ifnull(l.model_name, '') as model_name,
  ifnull(mp.provider, '') as model_provider,
  ifnull(mp.currency, 'CNY') as model_currency,
  ifnull(l.prompt_tokens, 0) as prompt_tokens,
  ifnull(l.completion_tokens, 0) as completion_tokens,
  ifnull(l.total_tokens, 0) as total_tokens,
  ifnull(l.prompt_cache_hit_tokens, 0) as prompt_cache_hit_tokens,
  ifnull(l.prompt_cache_miss_tokens, 0) as prompt_cache_miss_tokens,
  ifnull(mp.input_cache_hit_price_per_1m, 0) as input_cache_hit_price_per_1m,
  ifnull(mp.input_cache_miss_price_per_1m, 0) as input_cache_miss_price_per_1m,
  ifnull(mp.output_price_per_1m, 0) as output_price_per_1m,
  round(
    (
      ifnull(l.prompt_cache_hit_tokens, 0) * ifnull(mp.input_cache_hit_price_per_1m, 0)
      + ifnull(l.prompt_cache_miss_tokens, 0) * ifnull(mp.input_cache_miss_price_per_1m, 0)
      + ifnull(l.completion_tokens, 0) * ifnull(mp.output_price_per_1m, 0)
    ) / 1000000.0,
    6
  ) as cost_cny,
  ifnull(l.usage_json, '') as usage_json,
  ifnull(l.ai_result, '') as ai_result,
  l.create_time,
  l.create_user
from (
  select
    t.*,
    ifnull(
      case
        when json_valid(t.usage_json) then json_extract(t.usage_json, '$.prompt_cache_hit_tokens')
        else 0
      end,
      0
    ) as prompt_cache_hit_tokens,
    ifnull(
      case
        when json_valid(t.usage_json) then json_extract(t.usage_json, '$.prompt_cache_miss_tokens')
        else null
      end,
      case
        when ifnull(t.prompt_tokens, 0) > ifnull(
          case
            when json_valid(t.usage_json) then json_extract(t.usage_json, '$.prompt_cache_hit_tokens')
            else 0
          end,
          0
        )
          then ifnull(t.prompt_tokens, 0) - ifnull(
            case
              when json_valid(t.usage_json) then json_extract(t.usage_json, '$.prompt_cache_hit_tokens')
              else 0
            end,
            0
          )
        else ifnull(t.prompt_tokens, 0)
      end
    ) as prompt_cache_miss_tokens
  from travel_escape_analyze_log t
) l
left join travel_model_price mp
  on mp.model_name = (
    case
      when ifnull(l.model_name, '') <> '' then l.model_name
      else 'deepseek-v4-flash'
    end
  )
 and ifnull(mp.status, 'normal') = 'normal'
where l.agency_id = {{.agency_id}}
  and date(l.create_time) >= date(
    {{ if .start_date }}
      {{.start_date}}
    {{ else }}
      strftime('%Y-%m-%d', 'now', 'localtime')
    {{ end }}
  )
  and date(l.create_time) <= date(
    {{ if .end_date }}
      {{.end_date}}
    {{ else }}
      strftime('%Y-%m-%d', 'now', 'localtime')
    {{ end }}
  )
order by l.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
