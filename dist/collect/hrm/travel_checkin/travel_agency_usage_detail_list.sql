select
  l.log_id,
  l.agency_id,
  l.employee_id,
  l.employee_name,
  l.analyze_source,
  ifnull(l.model_name, '') as model_name,
  case
    when ifnull(mp.provider, '') <> '' then mp.provider
    when instr(l.resolved_model_name, 'deepseek-v4-flash') > 0 then 'deepseek'
    else ''
  end as model_provider,
  ifnull(mp.currency, 'CNY') as model_currency,
  ifnull(l.prompt_tokens, 0) as prompt_tokens,
  ifnull(l.completion_tokens, 0) as completion_tokens,
  ifnull(l.total_tokens, 0) as total_tokens,
  ifnull(l.prompt_cache_hit_tokens, 0) as prompt_cache_hit_tokens,
  ifnull(l.prompt_cache_miss_tokens, 0) as prompt_cache_miss_tokens,
  case
    when mp.input_cache_hit_price_per_1m is not null then mp.input_cache_hit_price_per_1m
    when instr(l.resolved_model_name, 'deepseek-v4-flash') > 0 then 0.5
    else 0
  end as input_cache_hit_price_per_1m,
  case
    when mp.input_cache_miss_price_per_1m is not null then mp.input_cache_miss_price_per_1m
    when instr(l.resolved_model_name, 'deepseek-v4-flash') > 0 then 2
    else 0
  end as input_cache_miss_price_per_1m,
  case
    when mp.output_price_per_1m is not null then mp.output_price_per_1m
    when instr(l.resolved_model_name, 'deepseek-v4-flash') > 0 then 8
    else 0
  end as output_price_per_1m,
  round(
    (
      ifnull(l.prompt_cache_hit_tokens, 0) * (
        case
          when mp.input_cache_hit_price_per_1m is not null then mp.input_cache_hit_price_per_1m
          when instr(l.resolved_model_name, 'deepseek-v4-flash') > 0 then 0.5
          else 0
        end
      )
      + ifnull(l.prompt_cache_miss_tokens, 0) * (
          case
            when mp.input_cache_miss_price_per_1m is not null then mp.input_cache_miss_price_per_1m
            when instr(l.resolved_model_name, 'deepseek-v4-flash') > 0 then 2
            else 0
          end
        )
      + ifnull(l.completion_tokens, 0) * (
          case
            when mp.output_price_per_1m is not null then mp.output_price_per_1m
            when instr(l.resolved_model_name, 'deepseek-v4-flash') > 0 then 8
            else 0
          end
        )
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
    case
      when ifnull(t.model_name, '') <> '' then t.model_name
      else 'deepseek-v4-flash'
    end as resolved_model_name,
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
  on mp.model_name = l.resolved_model_name
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
