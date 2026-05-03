select
  case
    when ifnull({{.quick_type}}, '') = 'month'
      then strftime('%Y-%m-01', 'now', 'localtime')
    when ifnull({{.quick_type}}, '') = 'last_month'
      then strftime('%Y-%m-01', 'now', 'localtime', 'start of month', '-1 month')
    else strftime('%Y-%m-%d', 'now', 'localtime')
  end as start_date,
  case
    when ifnull({{.quick_type}}, '') = 'last_month'
      then strftime('%Y-%m-%d', 'now', 'localtime', 'start of month', '-1 day')
    else strftime('%Y-%m-%d', 'now', 'localtime')
  end as end_date
