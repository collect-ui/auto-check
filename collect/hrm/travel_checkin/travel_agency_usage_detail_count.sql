select count(1)
from travel_escape_analyze_log l
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
