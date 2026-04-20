package base

const TableNameTravelEscapeAnalyzeLog = "travel_escape_analyze_log"

type TravelEscapeAnalyzeLog struct {
	LogID                 string `gorm:"column:log_id;primaryKey" json:"log_id"`
	EmployeeID            string `gorm:"column:employee_id" json:"employee_id"`
	AgencyID              string `gorm:"column:agency_id" json:"agency_id"`
	EmployeeName          string `gorm:"column:employee_name" json:"employee_name"`
	AnalyzeSource         string `gorm:"column:analyze_source" json:"analyze_source"`
	SystemPrompt          string `gorm:"column:system_prompt" json:"system_prompt"`
	PromptContent         string `gorm:"column:prompt_content" json:"prompt_content"`
	AiResult              string `gorm:"column:ai_result" json:"ai_result"`
	IsEscape              int    `gorm:"column:is_escape" json:"is_escape"`
	ChatCount             int    `gorm:"column:chat_count" json:"chat_count"`
	CallCount             int    `gorm:"column:call_count" json:"call_count"`
	ChatLatestMessageTime int64  `gorm:"column:chat_latest_message_time" json:"chat_latest_message_time"`
	CallLatestPhoneTime   int64  `gorm:"column:call_latest_phone_time" json:"call_latest_phone_time"`
	CreateTime            string `gorm:"column:create_time" json:"create_time"`
	CreateUser            string `gorm:"column:create_user" json:"create_user"`
}

func (*TravelEscapeAnalyzeLog) TableName() string {
	return TableNameTravelEscapeAnalyzeLog
}

func (*TravelEscapeAnalyzeLog) PrimaryKey() []string {
	return []string{"log_id"}
}
