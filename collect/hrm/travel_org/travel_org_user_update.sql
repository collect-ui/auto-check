update travel_agency_user_rel
set role_type = {{.role_type}},
    supervisor_user_id = {{if .supervisor_user_id}}{{.supervisor_user_id}}{{else}}''{{end}},
    description = {{if .description}}{{.description}}{{else}}''{{end}}
where relation_id = {{.relation_id}}
