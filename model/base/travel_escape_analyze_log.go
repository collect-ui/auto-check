package base

const TableNameTravelEscapeAnalyzeLog = "travel_escape_analyze_log"

type TravelEscapeAnalyzeLog struct {
	LogID                 string `gorm:"column:log_id;primaryKey" json:"log_id"`
	EmployeeID            string `gorm:"column:employee_id" json:"employee_id"`
	AgencyID              string `gorm:"column:agency_id" json:"agency_id"`
	EmployeeName          string `gorm:"column:employee_name" json:"employee_name"`
	AnalyzeSource         string `gorm:"column:analyze_source" json:"analyze_source"`
	ModelName             string `gorm:"column:model_name" json:"model_name"`
	SystemPrompt          string `gorm:"column:system_prompt" json:"system_prompt"`
	PromptContent         string `gorm:"column:prompt_content" json:"prompt_content"`
	AiResult              string `gorm:"column:ai_result" json:"ai_result"`
	IsEscape              int    `gorm:"column:is_escape" json:"is_escape"`
	PromptTokens          int    `gorm:"column:prompt_tokens" json:"prompt_tokens"`
	CompletionTokens      int    `gorm:"column:completion_tokens" json:"completion_tokens"`
	TotalTokens           int    `gorm:"column:total_tokens" json:"total_tokens"`
	UsageJSON             string `gorm:"column:usage_json" json:"usage_json"`
	ChatCount             int    `gorm:"column:chat_count" json:"chat_count"`
	CallCount             int    `gorm:"column:call_count" json:"call_count"`
	ChatLatestMessageTime int64  `gorm:"column:chat_latest_message_time" json:"chat_latest_message_time"`
	CallLatestPhoneTime   int64  `gorm:"column:call_latest_phone_time" json:"call_latest_phone_time"`
	ChatLatestAnalyzeTime string `gorm:"column:chat_latest_analyze_time" json:"chat_latest_analyze_time"`
	CallLatestAnalyzeTime string `gorm:"column:call_latest_analyze_time" json:"call_latest_analyze_time"`
	CreateTime            string `gorm:"column:create_time" json:"create_time"`
	CreateUser            string `gorm:"column:create_user" json:"create_user"`
}

func (*TravelEscapeAnalyzeLog) TableName() string {
	return TableNameTravelEscapeAnalyzeLog
}

func (*TravelEscapeAnalyzeLog) PrimaryKey() []string {
	return []string{"log_id"}
}
