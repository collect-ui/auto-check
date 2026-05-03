with base as (
  select
    r.uid,
    r.agency_id,
    r.employee_id,
    r.contact_id,
    r.contact_wx_id,
    r.wx_id,
    r.owner_wx_id,
    r.owner_head,
    r.owner_nick_name,
    r.contact_nick_name,
    r.nick_name,
    r.head,
    r.wx_alias,
    r.is_group,
    r.group_user_wx_id,
    r.group_user_wx_nick_name,
    r.group_user_wx_head,
    r.group_user_wx_room_name,
    r.message_type,
    r.content,
    r.message_time,
    r.message_status,
    r.wx_msg_id,
    r.file_name,
    r.file_size,
    r.file_status,
    r.file_url,
    r.file_text,
    r.link_url,
    r.transfer_money,
    r.transfer_status,
    r.receive_transfer_time,
    r.transcation_id,
    r.red_packet,
    r.red_packet_type,
    r.red_packet_status,
    r.red_packet_count,
    r.red_packet_end_time,
    r.red_packet_from_wx_id,
    r.red_packet_from_wx_nick_name,
    r.call_time,
    r.start_call_time,
    r.end_call_time,
    r.message_check_time,
    r.withdraw_time,
    r.user_nick_name,
    r.company_id,
    r.dep_id,
    r.user_id,
    ifnull(r.analyze_time, '') as analyze_time,
    r.create_time,
    r.modify_time,
    datetime(ifnull(r.message_time, 0) / 1000, 'unixepoch', '+8 hours') as message_time_formatted,
    date(ifnull(r.message_time, 0) / 1000, 'unixepoch', '+8 hours') as message_day,
    case
      when ifnull(r.contact_id, '') != '' then 'cid:' || r.contact_id
      else 'wx:' || ifnull(r.contact_wx_id, '') || '|owner:' || ifnull(r.owner_wx_id, '')
    end as contact_key,
    coalesce(
      (
        select coalesce(
          nullif(c.contact_nick_name, ''),
          nullif(c.nick_name, ''),
          nullif(c.wx_alias, ''),
          nullif(c.wx_id, '')
        )
        from travel_chat_contact c
        where c.employee_id = r.employee_id
          and (
            c.contact_id = r.contact_id
            or (
              ifnull(c.wx_id, '') = ifnull(r.contact_wx_id, '')
              and ifnull(c.owner_wx_id, '') = ifnull(r.owner_wx_id, '')
            )
          )
        order by ifnull(c.message_time, 0) desc
        limit 1
      ),
      nullif(r.contact_nick_name, ''),
      nullif(r.contact_wx_id, ''),
      '未知联系人'
    ) as contact_name,
    lower(
      replace(
        replace(
          replace(
            replace(
              replace(
                replace(
                  replace(
                    replace(
                      replace(
                        replace(
                          replace(
                            replace(
                              replace(
                                replace(
                                  replace(
                                    replace(
                                      replace(
                                        replace(
                                          replace(
                                            replace(
                                              replace(
                                                replace(
                                                  replace(
                                                    replace(
                                                      replace(
                                                        ifnull(r.content, ''),
                                                        '豆色AI生成',
                                                        ''
                                                      ),
                                                      char(10),
                                                      ''
                                                    ),
                                                    char(13),
                                                    ''
                                                  ),
                                                  ' ',
                                                  ''
                                                ),
                                                '　',
                                                ''
                                              ),
                                              '。',
                                              ''
                                            ),
                                            '，',
                                            ''
                                          ),
                                          ',',
                                          ''
                                        ),
                                        '.',
                                        ''
                                      ),
                                      '!',
                                      ''
                                    ),
                                    '！',
                                    ''
                                  ),
                                  '?',
                                  ''
                                ),
                                '？',
                                ''
                              ),
                              ':',
                              ''
                            ),
                            '：',
                            ''
                          ),
                          ';',
                          ''
                        ),
                        '；',
                        ''
                      ),
                      '(',
                      ''
                    ),
                    ')',
                    ''
                  ),
                  '（',
                  ''
                ),
                '）',
                ''
              ),
              '/',
              ''
            ),
            '-',
            ''
          ),
          '·',
          ''
        ),
        '…',
        ''
      )
    ) as normalized_repeat_key,
    case
      when ifnull(a.escape_repeat_ad_keywords, '') != ''
        then a.escape_repeat_ad_keywords
      else '换群,速来咨询,7*24小时服务,加微信,VX,vx,微信,注册,代记账,许可证,挂靠,退税,收户'
    end as escape_repeat_ad_keywords
  from travel_chat_record r
  left join travel_employee e on e.employee_id = r.employee_id
  left join travel_agency a on a.agency_id = e.agency_id
  where 1=1
    {{ if .employee_scope_token }}
    and instr({{ .employee_scope_token }}, ',' || ifnull(r.employee_id, '') || ',') > 0
    {{ else }}
    and r.employee_id = {{ .employee_id }}
    {{ end }}
    {{ if and .start_time (ne (printf "%v" .start_time) "0") }}
    and ifnull(r.message_time, 0) >= {{ .start_time }}
    {{ else }}
    and ifnull(r.message_time, 0) >= cast(strftime('%s', 'now', printf('-%d day', {{ if .days }}{{ .days }}{{ else }}7{{ end }})) as integer) * 1000
    {{ end }}
    {{ if and .end_time (ne (printf "%v" .end_time) "0") }}
    and ifnull(r.message_time, 0) <= {{ .end_time }}
    {{ end }}
),
ranked as (
  select
    b.*,
    max(ifnull(b.analyze_time, '')) over () as global_latest_analyze_time,
    max(ifnull(b.message_time, 0)) over (partition by b.contact_key) as group_last_message_time,
    count(*) over (
      partition by b.employee_id, b.message_day, ifnull(b.normalized_repeat_key, '')
    ) as same_day_content_repeat_count,
    row_number() over (
      partition by b.employee_id, b.message_day, ifnull(b.normalized_repeat_key, '')
      order by ifnull(b.message_time, 0), b.uid
    ) as same_day_content_repeat_index
  from base b
)
select
  r.uid,
  r.agency_id,
  r.employee_id,
  r.contact_id,
  r.contact_wx_id,
  r.wx_id,
  r.owner_wx_id,
  r.owner_head,
  r.owner_nick_name,
  r.contact_nick_name,
  r.nick_name,
  r.head,
  r.wx_alias,
  r.is_group,
  r.group_user_wx_id,
  r.group_user_wx_nick_name,
  r.group_user_wx_head,
  r.group_user_wx_room_name,
  r.message_type,
  r.content,
  r.message_time,
  r.message_status,
  r.wx_msg_id,
  r.file_name,
  r.file_size,
  r.file_status,
  r.file_url,
  r.file_text,
  case
    when (
      lower(ifnull(r.file_name, '')) like '%.xlsx'
      or lower(ifnull(r.file_name, '')) like '%.xls'
      or lower(ifnull(r.file_name, '')) like '%.csv'
      or lower(ifnull(r.file_url, '')) like '%.xlsx'
      or lower(ifnull(r.file_url, '')) like '%.xls'
      or lower(ifnull(r.file_url, '')) like '%.csv'
    )
      then
        '[表格附件内容已屏蔽' ||
        case
          when ifnull(r.file_name, '') != '' then '：' || r.file_name
          else ''
        end
        || ']'
    when (
      length(ifnull(r.content, '')) > 800
      and (
        instr(ifnull(r.content, ''), 'Sheet') > 0
        or instr(ifnull(r.content, ''), 'sheet') > 0
        or instr(ifnull(r.content, ''), '表格') > 0
        or instr(ifnull(r.content, ''), '问题类别') > 0
        or instr(ifnull(r.content, ''), '标准回复话术') > 0
        or instr(ifnull(r.content, ''), '是否需要人工转接') > 0
        or instr(ifnull(r.content, ''), '对应业务线') > 0
        or instr(ifnull(r.content, ''), '---') > 0
      )
    )
      then '[疑似表格/模板长文本已屏蔽，长度' || length(ifnull(r.content, '')) || ']'
    when ifnull(r.content, '') != ''
      and r.same_day_content_repeat_count > 1
      and r.same_day_content_repeat_index > 1
      and length(ifnull(r.content, '')) >= 120
      then '[疑似重复广告，已折叠] 当天第' || r.same_day_content_repeat_index || '次，首条时间：' ||
        (
          select datetime(min(ifnull(x.message_time, 0)) / 1000, 'unixepoch', '+8 hours')
          from base x
          where x.employee_id = r.employee_id
            and x.message_day = r.message_day
            and ifnull(x.normalized_repeat_key, '') = ifnull(r.normalized_repeat_key, '')
        )
    when length(ifnull(r.content, '')) > {{ if .single_chat_text_limit }}{{ .single_chat_text_limit }}{{ else }}200{{ end }}
      and not (
        lower(ifnull(r.file_url, '')) like '%.mp3'
        or lower(ifnull(r.file_url, '')) like '%.wav'
        or lower(ifnull(r.file_url, '')) like '%.amr'
        or lower(ifnull(r.file_url, '')) like '%.m4a'
        or lower(ifnull(r.file_name, '')) like '%.mp3'
        or lower(ifnull(r.file_name, '')) like '%.wav'
        or lower(ifnull(r.file_name, '')) like '%.amr'
        or lower(ifnull(r.file_name, '')) like '%.m4a'
      )
      then
        substr(ifnull(r.content, ''), 1, 300) ||
        '\n...[文本过长，已保留前后片段，中间省略]...\n' ||
        substr(
          ifnull(r.content, ''),
          case
            when length(ifnull(r.content, '')) > 300
              then length(ifnull(r.content, '')) - 300 + 1
            else 1
          end
        )
    when ifnull(r.content, '') != ''
      then r.content
    when length(ifnull(r.file_text, '')) > {{ if .single_chat_text_limit }}{{ .single_chat_text_limit }}{{ else }}120{{ end }}
      and not (
        lower(ifnull(r.file_url, '')) like '%.mp3'
        or lower(ifnull(r.file_url, '')) like '%.wav'
        or lower(ifnull(r.file_url, '')) like '%.amr'
        or lower(ifnull(r.file_url, '')) like '%.m4a'
        or lower(ifnull(r.file_name, '')) like '%.mp3'
        or lower(ifnull(r.file_name, '')) like '%.wav'
        or lower(ifnull(r.file_name, '')) like '%.amr'
        or lower(ifnull(r.file_name, '')) like '%.m4a'
      )
      then
        substr(ifnull(r.file_text, ''), 1, 300) ||
        '\n...[附件文本过长，已保留前后片段，中间省略]...\n' ||
        substr(
          ifnull(r.file_text, ''),
          case
            when length(ifnull(r.file_text, '')) > 300
              then length(ifnull(r.file_text, '')) - 300 + 1
            else 1
          end
        )
    when ifnull(r.file_text, '') != ''
      then r.file_text
    else '[空消息]'
  end as analysis_text,
  r.link_url,
  r.transfer_money,
  r.transfer_status,
  r.receive_transfer_time,
  r.transcation_id,
  r.red_packet,
  r.red_packet_type,
  r.red_packet_status,
  r.red_packet_count,
  r.red_packet_end_time,
  r.red_packet_from_wx_id,
  r.red_packet_from_wx_nick_name,
  r.call_time,
  r.start_call_time,
  r.end_call_time,
  r.message_check_time,
  r.withdraw_time,
  r.user_nick_name,
  r.company_id,
  r.dep_id,
  r.user_id,
  r.analyze_time,
  r.create_time,
  r.modify_time,
  r.message_time_formatted,
  r.message_day,
  r.contact_key,
  r.contact_name,
  r.normalized_repeat_key,
  r.escape_repeat_ad_keywords,
  r.global_latest_analyze_time,
  r.group_last_message_time,
  r.same_day_content_repeat_count,
  r.same_day_content_repeat_index
from ranked r
order by ifnull(message_day, '') desc, ifnull(group_last_message_time, 0) desc, ifnull(message_time, 0) desc, uid desc
{{ if and .limit (gt .limit 0) }}
limit {{ .limit }}
{{ end }}
