package base

const TableNameCustomerLeadPool = "customer_lead_pool"

type CustomerLeadPool struct {
	LeadID         string `gorm:"column:lead_id;primaryKey" json:"lead_id"`
	AgencyID       string `gorm:"column:agency_id" json:"agency_id"`
	CustomerName   string `gorm:"column:customer_name" json:"customer_name"`
	Contact        string `gorm:"column:contact" json:"contact"`
	WechatAccount  string `gorm:"column:wechat_account" json:"wechat_account"`
	SourcePlatform string `gorm:"column:source_platform" json:"source_platform"`
	Status         string `gorm:"column:status" json:"status"`
	Description    string `gorm:"column:description" json:"description"`
	CreateTime     string `gorm:"column:create_time" json:"create_time"`
	CreateUser     string `gorm:"column:create_user" json:"create_user"`
}

func (*CustomerLeadPool) TableName() string {
	return TableNameCustomerLeadPool
}

func (*CustomerLeadPool) PrimaryKey() []string {
	return []string{"lead_id"}
}
