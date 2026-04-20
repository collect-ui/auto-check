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
      when length(ifnull(r.content, '')) > 200
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
        then substr(ifnull(r.content, ''), 1, 200) || '...[文本过长已截断]'
      when ifnull(r.content, '') != ''
        then r.content
      when length(ifnull(r.file_text, '')) > 120
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
        then substr(ifnull(r.file_text, ''), 1, 120) || '...[附件文本过长已截断]'
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
    r.create_time,
    r.modify_time,
    datetime(ifnull(r.message_time, 0) / 1000, 'unixepoch', '+8 hours') as message_time_formatted,
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
    ) as contact_name
  from travel_chat_record r
  where r.employee_id = {{ .employee_id }}
    and ifnull(r.message_time, 0) >= cast(strftime('%s', 'now', printf('-%d day', {{ if .days }}{{ .days }}{{ else }}7{{ end }})) as integer) * 1000
),
ranked as (
  select
    b.*,
    max(ifnull(b.message_time, 0)) over (partition by b.contact_key) as group_last_message_time
  from base b
)
select *
from ranked
order by ifnull(group_last_message_time, 0) desc, ifnull(message_time, 0) desc, uid desc
{{ if and .limit (gt .limit 0) }}
limit {{ .limit }}
{{ end }}
