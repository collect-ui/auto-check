package base

const TableNameTravelEscapeIssue = "travel_escape_issue"

type TravelEscapeIssue struct {
	IssueID        string `gorm:"column:issue_id;primaryKey" json:"issue_id"`
	EmployeeID     string `gorm:"column:employee_id" json:"employee_id"`
	AgencyID       string `gorm:"column:agency_id" json:"agency_id"`
	EmployeeName   string `gorm:"column:employee_name" json:"employee_name"`
	IssueStatus    string `gorm:"column:issue_status" json:"issue_status"`
	IssueReason    string `gorm:"column:issue_reason" json:"issue_reason"`
	IssueDetail    string `gorm:"column:issue_detail" json:"issue_detail"`
	SourceLogID    string `gorm:"column:source_log_id" json:"source_log_id"`
	ProcessResult  string `gorm:"column:process_result" json:"process_result"`
	ProcessTime    string `gorm:"column:process_time" json:"process_time"`
	ProcessUser    string `gorm:"column:process_user" json:"process_user"`
	CreateTime     string `gorm:"column:create_time" json:"create_time"`
	CreateUser     string `gorm:"column:create_user" json:"create_user"`
	LastModifyTime string `gorm:"column:last_modify_time" json:"last_modify_time"`
	LastModifyUser string `gorm:"column:last_modify_user" json:"last_modify_user"`
}

func (*TravelEscapeIssue) TableName() string {
	return TableNameTravelEscapeIssue
}

func (*TravelEscapeIssue) PrimaryKey() []string {
	return []string{"issue_id"}
}
