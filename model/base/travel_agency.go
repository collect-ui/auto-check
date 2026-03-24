package base

const TableNameTravelAgency = "travel_agency"

type TravelAgency struct {
	AgencyID    string `gorm:"column:agency_id;primaryKey" json:"agency_id"`
	AgencyName  string `gorm:"column:agency_name" json:"agency_name"`
	AgencyCode  string `gorm:"column:agency_code" json:"agency_code"`
	LogoPath    string `gorm:"column:logo_path" json:"logo_path"`
	BizType     string `gorm:"column:biz_type" json:"biz_type"`
	CheckinStatus string `gorm:"column:checkin_status" json:"checkin_status"`
	Status      string `gorm:"column:status" json:"status"`
	CreateTime  string `gorm:"column:create_time" json:"create_time"`
	CreateUser  string `gorm:"column:create_user" json:"create_user"`
	Description string `gorm:"column:description" json:"description"`
}

func (*TravelAgency) TableName() string {
	return TableNameTravelAgency
}

func (*TravelAgency) PrimaryKey() []string {
	return []string{"agency_id"}
}
