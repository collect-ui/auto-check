with recursive chat_daily as (
  select
    date(datetime(r.message_time / 1000, 'unixepoch', '+8 hours')) as day_key,
    min(r.message_time) as chat_start_time,
    max(r.message_time) as chat_end_time,
    count(1) as chat_count,
    sum(length(ifnull(r.content, '')) + length(ifnull(r.file_text, '')) + 80) as chat_est_chars
  from travel_chat_record r
  where r.employee_id = {{ .employee_id }}
    and ifnull(r.message_time, 0) >= {{ .start_time }}
    and ifnull(r.message_time, 0) <= {{ .end_time }}
  group by date(datetime(r.message_time / 1000, 'unixepoch', '+8 hours'))
),
call_daily as (
  select
    date(datetime(a.phone_start_time / 1000, 'unixepoch', '+8 hours')) as day_key,
    min(a.phone_start_time) as call_start_time,
    max(a.phone_start_time) as call_end_time,
    count(1) as call_count,
    sum(length(ifnull(a.phone_record_text, '')) + length(ifnull(a.parsed_text, '')) + 80) as call_est_chars
  from travel_call_record a
  where (
      a.employee_id = {{ .employee_id }}
      or (
        ifnull(a.employee_id, '') = ''
        and exists (
          select 1
          from travel_employee e
          where e.employee_id = {{ .employee_id }}
            and e.agency_id = a.agency_id
            and ifnull(e.phone, '') != ''
            and (a.phone_out_number = e.phone or a.phone_in_number = e.phone)
        )
      )
    )
    and ifnull(a.phone_start_time, 0) >= {{ .start_time }}
    and ifnull(a.phone_start_time, 0) <= {{ .end_time }}
  group by date(datetime(a.phone_start_time / 1000, 'unixepoch', '+8 hours'))
),
all_days as (
  select day_key from chat_daily
  union
  select day_key from call_daily
),
daily as (
  select
    d.day_key,
    cast(strftime('%s', d.day_key || ' 00:00:00', '+8 hours') as integer) * 1000 as day_start_time,
    cast(strftime('%s', d.day_key || ' 23:59:59', '+8 hours') as integer) * 1000 + 999 as day_end_time,
    ifnull(c.chat_count, 0) as chat_count,
    ifnull(c.chat_est_chars, 0) as chat_est_chars,
    ifnull(k.call_count, 0) as call_count,
    ifnull(k.call_est_chars, 0) as call_est_chars,
    row_number() over (order by d.day_key asc) as rn
  from all_days d
  left join chat_daily c on c.day_key = d.day_key
  left join call_daily k on k.day_key = d.day_key
),
rec as (
  select
    rn,
    day_key,
    day_start_time,
    day_end_time,
    chat_count,
    chat_est_chars,
    call_count,
    call_est_chars,
    1 as chunk_no,
    1 as chunk_day_count,
    chat_count as chunk_chat_count,
    chat_est_chars as chunk_chat_chars,
    call_count as chunk_call_count,
    call_est_chars as chunk_call_chars
  from daily
  where rn = 1

  union all

  select
    d.rn,
    d.day_key,
    d.day_start_time,
    d.day_end_time,
    d.chat_count,
    d.chat_est_chars,
    d.call_count,
    d.call_est_chars,
    case
      when r.chunk_day_count >= {{ .max_days_per_chunk }}
        or r.chunk_chat_count + d.chat_count > {{ .max_chat_count_per_chunk }}
        or r.chunk_call_count + d.call_count > {{ .max_call_count_per_chunk }}
        or r.chunk_chat_chars + d.chat_est_chars > {{ .max_chat_chars_per_chunk }}
        or r.chunk_call_chars + d.call_est_chars > {{ .max_call_chars_per_chunk }}
      then r.chunk_no + 1
      else r.chunk_no
    end as chunk_no,
    case
      when r.chunk_day_count >= {{ .max_days_per_chunk }}
        or r.chunk_chat_count + d.chat_count > {{ .max_chat_count_per_chunk }}
        or r.chunk_call_count + d.call_count > {{ .max_call_count_per_chunk }}
        or r.chunk_chat_chars + d.chat_est_chars > {{ .max_chat_chars_per_chunk }}
        or r.chunk_call_chars + d.call_est_chars > {{ .max_call_chars_per_chunk }}
      then 1
      else r.chunk_day_count + 1
    end as chunk_day_count,
    case
      when r.chunk_day_count >= {{ .max_days_per_chunk }}
        or r.chunk_chat_count + d.chat_count > {{ .max_chat_count_per_chunk }}
        or r.chunk_call_count + d.call_count > {{ .max_call_count_per_chunk }}
        or r.chunk_chat_chars + d.chat_est_chars > {{ .max_chat_chars_per_chunk }}
        or r.chunk_call_chars + d.call_est_chars > {{ .max_call_chars_per_chunk }}
      then d.chat_count
      else r.chunk_chat_count + d.chat_count
    end as chunk_chat_count,
    case
      when r.chunk_day_count >= {{ .max_days_per_chunk }}
        or r.chunk_chat_count + d.chat_count > {{ .max_chat_count_per_chunk }}
        or r.chunk_call_count + d.call_count > {{ .max_call_count_per_chunk }}
        or r.chunk_chat_chars + d.chat_est_chars > {{ .max_chat_chars_per_chunk }}
        or r.chunk_call_chars + d.call_est_chars > {{ .max_call_chars_per_chunk }}
      then d.chat_est_chars
      else r.chunk_chat_chars + d.chat_est_chars
    end as chunk_chat_chars,
    case
      when r.chunk_day_count >= {{ .max_days_per_chunk }}
        or r.chunk_chat_count + d.chat_count > {{ .max_chat_count_per_chunk }}
        or r.chunk_call_count + d.call_count > {{ .max_call_count_per_chunk }}
        or r.chunk_chat_chars + d.chat_est_chars > {{ .max_chat_chars_per_chunk }}
        or r.chunk_call_chars + d.call_est_chars > {{ .max_call_chars_per_chunk }}
      then d.call_count
      else r.chunk_call_count + d.call_count
    end as chunk_call_count,
    case
      when r.chunk_day_count >= {{ .max_days_per_chunk }}
        or r.chunk_chat_count + d.chat_count > {{ .max_chat_count_per_chunk }}
        or r.chunk_call_count + d.call_count > {{ .max_call_count_per_chunk }}
        or r.chunk_chat_chars + d.chat_est_chars > {{ .max_chat_chars_per_chunk }}
        or r.chunk_call_chars + d.call_est_chars > {{ .max_call_chars_per_chunk }}
      then d.call_est_chars
      else r.chunk_call_chars + d.call_est_chars
    end as chunk_call_chars
  from rec r
  join daily d on d.rn = r.rn + 1
)
select
  chunk_no,
  min(day_start_time) as chunk_start_time,
  max(day_end_time) as chunk_end_time,
  min(day_key) as chunk_start_day,
  max(day_key) as chunk_end_day,
  count(1) as chunk_day_count,
  sum(chat_count) as chat_count,
  sum(call_count) as call_count,
  sum(chat_est_chars) as chat_est_chars,
  sum(call_est_chars) as call_est_chars
from rec
group by chunk_no
order by chunk_no asc;
