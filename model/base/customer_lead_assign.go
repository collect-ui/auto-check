package base

const TableNameCustomerLeadAssign = "customer_lead_assign"

type CustomerLeadAssign struct {
	AssignID         string `gorm:"column:assign_id;primaryKey" json:"assign_id"`
	LeadID           string `gorm:"column:lead_id" json:"lead_id"`
	AgencyID         string `gorm:"column:agency_id" json:"agency_id"`
	AssignDate       string `gorm:"column:assign_date" json:"assign_date"`
	SalesUserID      string `gorm:"column:sales_user_id" json:"sales_user_id"`
	RouteID          string `gorm:"column:route_id" json:"route_id"`
	SupervisorUserID string `gorm:"column:supervisor_user_id" json:"supervisor_user_id"`
	Status           string `gorm:"column:status" json:"status"`
	Description      string `gorm:"column:description" json:"description"`
	CreateTime       string `gorm:"column:create_time" json:"create_time"`
	CreateUser       string `gorm:"column:create_user" json:"create_user"`
	UpdateTime       string `gorm:"column:update_time" json:"update_time"`
	UpdateUser       string `gorm:"column:update_user" json:"update_user"`
}

func (*CustomerLeadAssign) TableName() string {
	return TableNameCustomerLeadAssign
}

func (*CustomerLeadAssign) PrimaryKey() []string {
	return []string{"assign_id"}
}
