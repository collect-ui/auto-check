package base

const TableNameTravelEmployee = "travel_employee"

type TravelEmployee struct {
	EmployeeID  string  `gorm:"column:employee_id;primaryKey" json:"employee_id"`
	AgencyID    string  `gorm:"column:agency_id" json:"agency_id"`
	Alias       *string `gorm:"column:alias" json:"alias"`
	Head        string  `gorm:"column:head" json:"head"`
	NickName    string  `gorm:"column:nick_name" json:"nick_name"`
	OwerWxAlias string  `gorm:"column:ower_wx_alias" json:"ower_wx_alias"`
	Phone       string  `gorm:"column:phone" json:"phone"`
	PhoneUser   int     `gorm:"column:phone_user" json:"phone_user"`
	UserID      int     `gorm:"column:user_id" json:"user_id"`
	WxID        string  `gorm:"column:wx_id" json:"wx_id"`
	WxTarget    int     `gorm:"column:wx_target" json:"wx_target"`
	Status      string  `gorm:"column:status" json:"status"`
	Description string  `gorm:"column:description" json:"description"`
	CreateTime  string  `gorm:"column:create_time" json:"create_time"`
	CreateUser  string  `gorm:"column:create_user" json:"create_user"`
	ModifyTime  string  `gorm:"column:modify_time" json:"modify_time"`
	ModifyUser  string  `gorm:"column:modify_user" json:"modify_user"`
}

func (*TravelEmployee) TableName() string {
	return TableNameTravelEmployee
}

func (*TravelEmployee) PrimaryKey() []string {
	return []string{"employee_id"}
}
