select
  count(1) as today_analyze_count,
  ifnull(sum(ifnull(l.prompt_tokens, 0)), 0) as today_prompt_tokens,
  ifnull(sum(ifnull(l.completion_tokens, 0)), 0) as today_completion_tokens,
  ifnull(sum(ifnull(l.total_tokens, 0)), 0) as today_total_tokens,
  ifnull(sum(ifnull(l.prompt_cache_hit_tokens, 0)), 0) as today_prompt_cache_hit_tokens,
  ifnull(sum(ifnull(l.prompt_cache_miss_tokens, 0)), 0) as today_prompt_cache_miss_tokens,
  round(
    ifnull(
      sum(
        (
          ifnull(l.prompt_cache_hit_tokens, 0) * ifnull(mp.input_cache_hit_price_per_1m, 0)
          + ifnull(l.prompt_cache_miss_tokens, 0) * ifnull(mp.input_cache_miss_price_per_1m, 0)
          + ifnull(l.completion_tokens, 0) * ifnull(mp.output_price_per_1m, 0)
        ) / 1000000.0
      ),
      0
    ),
    6
  ) as today_cost_cny,
  ifnull(max(mp.currency), 'CNY') as currency,
  ifnull(max(l.create_time), '') as latest_analyze_time
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
