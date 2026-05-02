select
  a.*,
  ifnull(u.today_prompt_tokens, 0) as today_prompt_tokens,
  ifnull(u.today_completion_tokens, 0) as today_completion_tokens,
  ifnull(u.today_total_tokens, 0) as today_total_tokens,
  round(ifnull(u.today_cost_cny, 0), 6) as today_cost_cny,
  (
    select count(1)
    from travel_employee e
    where e.agency_id = a.agency_id
      and ifnull(e.status, 'normal') = 'normal'
  ) as employee_count,
  (
    select r.user_id
    from travel_agency_user_rel r
    where r.agency_id = a.agency_id
      and ifnull(r.status, 'normal') = 'normal'
      and r.role_type = 'admin'
    order by r.create_time desc
    limit 1
  ) as relation_user_id,
  (
    select u.username
    from user_account u
    where u.user_id = (
      select r.user_id
      from travel_agency_user_rel r
      where r.agency_id = a.agency_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.role_type = 'admin'
      order by r.create_time desc
      limit 1
    )
      and ifnull(u.is_delete, '0') = '0'
    limit 1
  ) as relation_username,
  (
    select u.nick
    from user_account u
    where u.user_id = (
      select r.user_id
      from travel_agency_user_rel r
      where r.agency_id = a.agency_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.role_type = 'admin'
      order by r.create_time desc
      limit 1
    )
      and ifnull(u.is_delete, '0') = '0'
    limit 1
  ) as relation_nick
from travel_agency a
left join (
  select
    l.agency_id,
    sum(ifnull(l.prompt_tokens, 0)) as today_prompt_tokens,
    sum(ifnull(l.completion_tokens, 0)) as today_completion_tokens,
    sum(ifnull(l.total_tokens, 0)) as today_total_tokens,
    sum(
      (
        ifnull(
          case
            when json_valid(l.usage_json) then json_extract(l.usage_json, '$.prompt_cache_hit_tokens')
            else 0
          end,
          0
        ) * (
          case
            when mp.input_cache_hit_price_per_1m is not null then mp.input_cache_hit_price_per_1m
            when (
              case
                when ifnull(l.model_name, '') <> '' then l.model_name
                else 'deepseek-v4-flash'
              end
            ) like '%deepseek-v4-flash%' then 0.5
            else 0
          end
        )
        + ifnull(
            case
              when json_valid(l.usage_json) then json_extract(l.usage_json, '$.prompt_cache_miss_tokens')
              else null
            end,
            case
              when ifnull(l.prompt_tokens, 0) > ifnull(
                case
                  when json_valid(l.usage_json) then json_extract(l.usage_json, '$.prompt_cache_hit_tokens')
                  else 0
                end,
                0
              )
                then ifnull(l.prompt_tokens, 0) - ifnull(
                  case
                    when json_valid(l.usage_json) then json_extract(l.usage_json, '$.prompt_cache_hit_tokens')
                    else 0
                  end,
                  0
                )
              else ifnull(l.prompt_tokens, 0)
            end
          ) * (
            case
              when mp.input_cache_miss_price_per_1m is not null then mp.input_cache_miss_price_per_1m
              when (
                case
                  when ifnull(l.model_name, '') <> '' then l.model_name
                  else 'deepseek-v4-flash'
                end
              ) like '%deepseek-v4-flash%' then 2
              else 0
            end
          )
        + ifnull(l.completion_tokens, 0) * (
            case
              when mp.output_price_per_1m is not null then mp.output_price_per_1m
              when (
                case
                  when ifnull(l.model_name, '') <> '' then l.model_name
                  else 'deepseek-v4-flash'
                end
              ) like '%deepseek-v4-flash%' then 8
              else 0
            end
          )
      ) / 1000000.0
    ) as today_cost_cny
  from travel_escape_analyze_log l
  left join travel_model_price mp
    on mp.model_name = (
      case
        when ifnull(l.model_name, '') <> '' then l.model_name
        else 'deepseek-v4-flash'
      end
    )
   and ifnull(mp.status, 'normal') = 'normal'
  where strftime('%Y-%m-%d', l.create_time) = strftime('%Y-%m-%d', 'now', 'localtime')
  group by l.agency_id
) u on u.agency_id = a.agency_id
where 1=1
  and ifnull(nullif(a.status, ''), 'normal') = 'normal'
  {{ if .agency_id }}
  and a.agency_id = {{.agency_id}}
  {{ end }}
  {{ if .agency_code }}
  and a.agency_code = {{.agency_code}}
  {{ end }}
  {{ if .checkin_status }}
  and a.checkin_status = {{.checkin_status}}
  {{ end }}
  {{ if .wx_sync_enabled }}
  and a.wx_sync_enabled = {{.wx_sync_enabled}}
  {{ end }}
  {{ if .search }}
  and (a.agency_name like {{.search}} or a.agency_code like {{.search}})
  {{ end }}
order by a.create_time desc
{{ if .pagination }}
limit {{.start}} , {{.size}}
{{ end }}
