package base

const TableNameTravelAgencyCheckinApply = "travel_agency_checkin_apply"

type TravelAgencyCheckinApply struct {
	ApplyID       string `gorm:"column:apply_id;primaryKey" json:"apply_id"`
	AgencyName    string `gorm:"column:agency_name" json:"agency_name"`
	AgencyCode    string `gorm:"column:agency_code" json:"agency_code"`
	ContactName   string `gorm:"column:contact_name" json:"contact_name"`
	ContactPhone  string `gorm:"column:contact_phone" json:"contact_phone"`
	Username      string `gorm:"column:username" json:"username"`
	LoginUsername string `gorm:"column:login_username" json:"login_username"`
	Password      string `gorm:"column:password" json:"password"`
	UserID        string `gorm:"column:user_id" json:"user_id"`
	Status        string `gorm:"column:status" json:"status"`
	RejectReason  string `gorm:"column:reject_reason" json:"reject_reason"`
	AgencyID      string `gorm:"column:agency_id" json:"agency_id"`
	CreateTime    string `gorm:"column:create_time" json:"create_time"`
	AuditTime     string `gorm:"column:audit_time" json:"audit_time"`
	AuditUser     string `gorm:"column:audit_user" json:"audit_user"`
}

func (*TravelAgencyCheckinApply) TableName() string {
	return TableNameTravelAgencyCheckinApply
}

func (*TravelAgencyCheckinApply) PrimaryKey() []string {
	return []string{"apply_id"}
}
