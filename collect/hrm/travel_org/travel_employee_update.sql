update travel_employee
set alias = {{if .alias}}{{.alias}}{{else}}NULL{{end}},
    head = {{if .head}}{{.head}}{{else}}''{{end}},
    nick_name = {{if .nick_name}}{{.nick_name}}{{else}}''{{end}},
    ower_wx_alias = {{if .ower_wx_alias}}{{.ower_wx_alias}}{{else}}''{{end}},
    phone = {{if .phone}}{{.phone}}{{else}}''{{end}},
    phone_user = {{if .phone_user}}{{.phone_user}}{{else}}0{{end}},
    user_id = {{if .user_id}}{{.user_id}}{{else}}0{{end}},
    wx_id = {{if .wx_id}}{{.wx_id}}{{else}}''{{end}},
    wx_target = {{if .wx_target}}{{.wx_target}}{{else}}1{{end}},
    status = {{if .status}}{{.status}}{{else}}'normal'{{end}},
    description = {{if .description}}{{.description}}{{else}}''{{end}},
    modify_time = {{if .modify_time}}{{.modify_time}}{{else}}''{{end}},
    modify_user = {{if .modify_user}}{{.modify_user}}{{else}}''{{end}}
where employee_id = {{.employee_id}}