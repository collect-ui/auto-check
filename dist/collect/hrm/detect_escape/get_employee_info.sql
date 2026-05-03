select
  e.employee_id,
  e.nick_name as employee_name,
  e.alias as employee_alias,
  e.phone as employee_phone,
  e.wx_id as employee_wx_id,
  a.agency_id,
  a.agency_name,
  a.deepseek_api_key,
  a.escape_system_prompt,
  a.escape_user_prompt,
  a.escape_repeat_ad_keywords,
  (
    select group_concat(t.keyword, '\n')
    from (
      select r.keyword
      from travel_agency_escape_prompt_rel r
      where r.agency_id = a.agency_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.prompt_type = 'system'
      order by r.sort_no asc, r.create_time asc
    ) t
  ) as escape_system_keyword_text,
  (
    select group_concat(t.keyword, '\n')
    from (
      select r.keyword
      from travel_agency_escape_prompt_rel r
      where r.agency_id = a.agency_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.prompt_type = 'user'
      order by r.sort_no asc, r.create_time asc
    ) t
  ) as escape_user_keyword_text,
  (
    select group_concat(t.keyword, '\n')
    from (
      select r.keyword
      from travel_agency_escape_prompt_rel r
      where r.agency_id = a.agency_id
        and ifnull(r.status, 'normal') = 'normal'
        and r.prompt_type in ('system', 'user')
      order by
        case when r.prompt_type = 'system' then 0 else 1 end asc,
        r.sort_no asc,
        r.create_time asc
    ) t
  ) as escape_merge_keyword_text
from travel_employee e
left join travel_agency a on e.agency_id = a.agency_id
where e.employee_id = {{ .employee_id }}
