package base

const TableNameTravelAgencyUserRel = "travel_agency_user_rel"

type TravelAgencyUserRel struct {
	RelationID        string `gorm:"column:relation_id;primaryKey" json:"relation_id"`
	AgencyID          string `gorm:"column:agency_id" json:"agency_id"`
	UserID            string `gorm:"column:user_id" json:"user_id"`
	RoleType          string `gorm:"column:role_type" json:"role_type"`
	SupervisorUserID  string `gorm:"column:supervisor_user_id" json:"supervisor_user_id"`
	Status            string `gorm:"column:status" json:"status"`
	CreateTime        string `gorm:"column:create_time" json:"create_time"`
	CreateUser        string `gorm:"column:create_user" json:"create_user"`
	Description       string `gorm:"column:description" json:"description"`
}

func (*TravelAgencyUserRel) TableName() string {
	return TableNameTravelAgencyUserRel
}

func (*TravelAgencyUserRel) PrimaryKey() []string {
	return []string{"relation_id"}
}

