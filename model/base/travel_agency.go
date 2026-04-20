package base

const TableNameTravelAgency = "travel_agency"

type TravelAgency struct {
	AgencyID           string `gorm:"column:agency_id;primaryKey" json:"agency_id"`
	AgencyName         string `gorm:"column:agency_name" json:"agency_name"`
	AgencyCode         string `gorm:"column:agency_code" json:"agency_code"`
	LogoPath           string `gorm:"column:logo_path" json:"logo_path"`
	BizType            string `gorm:"column:biz_type" json:"biz_type"`
	Status             string `gorm:"column:status" json:"status"`
	CreateTime         string `gorm:"column:create_time" json:"create_time"`
	CreateUser         string `gorm:"column:create_user" json:"create_user"`
	Description        string `gorm:"column:description" json:"description"`
	CheckinStatus      string `gorm:"column:checkin_status" json:"checkin_status"`
	WxSyncEnabled      string `gorm:"column:wx_sync_enabled" json:"wx_sync_enabled"`
	WxSyncAccount      string `gorm:"column:wx_sync_account" json:"wx_sync_account"`
	WxSyncPassword     string `gorm:"column:wx_sync_password" json:"wx_sync_password"`
	WxSyncAccessToken  string `gorm:"column:wx_sync_access_token" json:"wx_sync_access_token"`
	WxSyncExpireTime   int64  `gorm:"column:wx_sync_expire_time" json:"wx_sync_expire_time"`
	WxSyncUserID       string `gorm:"column:wx_sync_user_id" json:"wx_sync_user_id"`
	WxSyncDepartmentID string `gorm:"column:wx_sync_department_id" json:"wx_sync_department_id"`
	WxSyncRoleID       string `gorm:"column:wx_sync_role_id" json:"wx_sync_role_id"`
	WxSyncCompanyID    string `gorm:"column:wx_sync_company_id" json:"wx_sync_company_id"`
	WxLastSyncTime     string `gorm:"column:wx_last_sync_time" json:"wx_last_sync_time"`
	WxSyncErrorCount   int    `gorm:"column:wx_sync_error_count" json:"wx_sync_error_count"`
	EscapeSystemPrompt string `gorm:"column:escape_system_prompt" json:"escape_system_prompt"`
	EscapeUserPrompt   string `gorm:"column:escape_user_prompt" json:"escape_user_prompt"`
}

func (*TravelAgency) TableName() string {
	return TableNameTravelAgency
}

func (*TravelAgency) PrimaryKey() []string {
	return []string{"agency_id"}
}
