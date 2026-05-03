select
  ifnull(max(a.contact_id), '') as contact_id,
  max(
    case
      when ifnull(a.group_user_wx_nick_name, '') != '' then 1
      when ifnull(a.contact_wx_id, '') like '%@chatroom' then 1
      else 0
    end
  ) as is_group,
  max(coalesce(nullif(a.contact_nick_name, ''), nullif(a.contact_wx_id, ''), '未知联系人')) as contact_name,
  max(ifnull(a.message_time, 0)) as contact_last_message_time,
  datetime(max(ifnull(a.message_time, 0)) / 1000, 'unixepoch', '+8 hours') as contact_last_message_time_formatted,
  group_concat(
    datetime(ifnull(a.message_time, 0) / 1000, 'unixepoch', '+8 hours')
    || ' '
    || ifnull(
      case
        when ifnull(a.group_user_wx_nick_name, '') != '' then a.group_user_wx_nick_name
        when ifnull(a.message_type, 0) = 0 then ifnull(a.contact_nick_name, coalesce(nullif(a.contact_wx_id, ''), '未知'))
        else ifnull(a.owner_nick_name, '我')
      end,
      '未知'
    )
    || ': '
    || ifnull(
      case
        when ifnull(a.end_call_time, 0) > 0 and ifnull(a.message_status, 0) in (3, 6)
          then '[语音未接通]'
        when ifnull(a.file_url, '') != '' and (
          lower(a.file_url) like '%.jpg'
          or lower(a.file_url) like '%.jpeg'
          or lower(a.file_url) like '%.png'
          or lower(a.file_url) like '%.gif'
          or lower(a.file_url) like '%.webp'
        )
          then '[图片]' || case when ifnull(a.content, '') != '' then ' ' || a.content else '' end
        when ifnull(a.file_url, '') != '' and (
          lower(a.file_url) like '%.mp3'
          or lower(a.file_url) like '%.wav'
          or lower(a.file_url) like '%.amr'
          or lower(a.file_url) like '%.m4a'
        )
          then case
            when ifnull(a.file_text, '') != '' then '[语音已转写] ' || a.file_text
            else '[语音未转写]' || case when ifnull(a.content, '') != '' then ' ' || a.content else '' end
          end
        when ifnull(a.file_url, '') != '' or ifnull(a.file_name, '') != ''
          then '[文件]' || case when ifnull(a.content, '') != '' then ' ' || a.content else '' end
        when ifnull(a.content, '') != '' then a.content
        else '[空消息]'
      end,
      '[空消息]'
    ),
    char(10)
  ) as chat_lines,
  (
    select count(1)
    from (
      select 1
      from travel_chat_record
      where employee_id = {{ .employee_id }}
      order by ifnull(message_time, 0) desc, uid desc
      limit {{ if .limit }}{{ .limit }}{{ else }}300{{ end }}
    ) c
  ) as total_message_count,
  (
    select ifnull(max(ifnull(m.message_time, 0)), 0)
    from (
      select message_time
      from travel_chat_record
      where employee_id = {{ .employee_id }}
      order by ifnull(message_time, 0) desc, uid desc
      limit {{ if .limit }}{{ .limit }}{{ else }}300{{ end }}
    ) m
  ) as global_latest_message_time
from (
  select *
  from (
    select *
    from travel_chat_record
    where employee_id = {{ .employee_id }}
    order by ifnull(message_time, 0) desc, uid desc
    limit {{ if .limit }}{{ .limit }}{{ else }}300{{ end }}
  ) latest_rows
  order by ifnull(message_time, 0) asc, uid asc
) a
group by
  case
    when ifnull(a.contact_id, '') != '' then 'cid:' || a.contact_id
    else 'wx:' || ifnull(a.contact_wx_id, '') || '|owner:' || ifnull(a.owner_wx_id, '')
  end
order by max(ifnull(a.message_time, 0)) desc;
