update travel_employee
set status = 'deleted',
    modify_time = {{if .modify_time}}{{.modify_time}}{{else}}''{{end}},
    modify_user = {{if .modify_user}}{{.modify_user}}{{else}}''{{end}}
where employee_id in ({{.employee_id_list}})