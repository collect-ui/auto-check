package base

const TableNameCustomerLeadAssignLog = "customer_lead_assign_log"

type CustomerLeadAssignLog struct {
	LogID          string `gorm:"column:log_id;primaryKey" json:"log_id"`
	AssignID       string `gorm:"column:assign_id" json:"assign_id"`
	LeadID         string `gorm:"column:lead_id" json:"lead_id"`
	ActionType     string `gorm:"column:action_type" json:"action_type"`
	OldSalesUserID string `gorm:"column:old_sales_user_id" json:"old_sales_user_id"`
	NewSalesUserID string `gorm:"column:new_sales_user_id" json:"new_sales_user_id"`
	AssignDate     string `gorm:"column:assign_date" json:"assign_date"`
	Description    string `gorm:"column:description" json:"description"`
	CreateTime     string `gorm:"column:create_time" json:"create_time"`
	CreateUser     string `gorm:"column:create_user" json:"create_user"`
}

func (*CustomerLeadAssignLog) TableName() string {
	return TableNameCustomerLeadAssignLog
}

func (*CustomerLeadAssignLog) PrimaryKey() []string {
	return []string{"log_id"}
}
