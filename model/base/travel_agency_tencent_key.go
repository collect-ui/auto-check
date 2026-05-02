package base

const TableNameTravelAgencyTencentKey = "travel_agency_tencent_key"

type TravelAgencyTencentKey struct {
	KeyID                     string `gorm:"column:key_id;primaryKey" json:"key_id"`
	AgencyID                  string `gorm:"column:agency_id" json:"agency_id"`
	AccountName               string `gorm:"column:account_name" json:"account_name"`
	Region                    string `gorm:"column:region" json:"region"`
	MonthlyQuotaSeconds       int64  `gorm:"column:monthly_quota_seconds" json:"monthly_quota_seconds"`
	SourceType                string `gorm:"column:source_type" json:"source_type"`
	RemoteRequestID           string `gorm:"column:remote_request_id" json:"remote_request_id"`
	RemoteCreatedAt           string `gorm:"column:remote_created_at" json:"remote_created_at"`
	RemoteReviewedAt          string `gorm:"column:remote_reviewed_at" json:"remote_reviewed_at"`
	RemoteStatus              string `gorm:"column:remote_status" json:"remote_status"`
	RemoteReviewComment       string `gorm:"column:remote_review_comment" json:"remote_review_comment"`
	Status                    string `gorm:"column:status" json:"status"`
	Remark                    string `gorm:"column:remark" json:"remark"`
	LastHealthStatus          string `gorm:"column:last_health_status" json:"last_health_status"`
	LastHealthMessage         string `gorm:"column:last_health_message" json:"last_health_message"`
	LastUsedDurationSeconds   int64  `gorm:"column:last_used_duration_seconds" json:"last_used_duration_seconds"`
	LastRemainingQuotaSeconds int64  `gorm:"column:last_remaining_quota_seconds" json:"last_remaining_quota_seconds"`
	LastSyncTime              string `gorm:"column:last_sync_time" json:"last_sync_time"`
	CreateTime                string `gorm:"column:create_time" json:"create_time"`
	CreateUser                string `gorm:"column:create_user" json:"create_user"`
	ModifyTime                string `gorm:"column:modify_time" json:"modify_time"`
	ModifyUser                string `gorm:"column:modify_user" json:"modify_user"`
	IsDelete                  string `gorm:"column:is_delete" json:"is_delete"`
}

func (*TravelAgencyTencentKey) TableName() string {
	return TableNameTravelAgencyTencentKey
}

func (*TravelAgencyTencentKey) PrimaryKey() []string {
	return []string{"key_id"}
}
