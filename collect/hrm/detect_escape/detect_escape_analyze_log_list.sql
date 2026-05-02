select
  l.log_id,
  l.employee_id,
  l.agency_id,
  l.employee_name,
  l.analyze_source,
  l.model_name,
  l.is_escape,
  l.chat_count,
  l.call_count,
  l.chat_latest_message_time,
  l.call_latest_phone_time,
  l.chat_latest_analyze_time,
  l.call_latest_analyze_time,
  l.system_prompt,
  l.prompt_content,
  l.ai_result,
  ifnull(l.prompt_tokens, 0) as prompt_tokens,
  ifnull(l.completion_tokens, 0) as completion_tokens,
  ifnull(l.total_tokens, 0) as total_tokens,
  ifnull(l.prompt_cache_hit_tokens, 0) as prompt_cache_hit_tokens,
  ifnull(l.prompt_cache_miss_tokens, 0) as prompt_cache_miss_tokens,
  ifnull(mp.provider, '') as model_provider,
  ifnull(mp.currency, 'CNY') as model_currency,
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
where 1 = 1
  {{ if .employee_id }}
  and l.employee_id = {{ .employee_id }}
  {{ end }}
  {{ if .agency_id }}
  and l.agency_id = {{ .agency_id }}
  {{ end }}
order by l.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
