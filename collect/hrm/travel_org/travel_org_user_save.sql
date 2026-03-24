insert into travel_agency_user_rel(
  relation_id,
  agency_id,
  user_id,
  role_type,
  supervisor_user_id,
  status,
  create_time,
  create_user,
  description
) values (
  {{.relation_id}},
  {{.agency_id}},
  {{.user_id}},
  {{.role_type}},
  {{if .supervisor_user_id}}{{.supervisor_user_id}}{{else}}''{{end}},
  {{if .status}}{{.status}}{{else}}'normal'{{end}},
  {{if .create_time}}{{.create_time}}{{else}}''{{end}},
  {{if .create_user}}{{.create_user}}{{else}}''{{end}},
  {{if .description}}{{.description}}{{else}}''{{end}}
)
