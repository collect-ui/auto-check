package base

const TableNameTravelAgencyEscapePromptRel = "travel_agency_escape_prompt_rel"

type TravelAgencyEscapePromptRel struct {
	RelID      string `gorm:"column:rel_id;primaryKey" json:"rel_id"`
	AgencyID   string `gorm:"column:agency_id" json:"agency_id"`
	PromptType string `gorm:"column:prompt_type" json:"prompt_type"`
	Keyword    string `gorm:"column:keyword" json:"keyword"`
	SortNo     int    `gorm:"column:sort_no" json:"sort_no"`
	Status     string `gorm:"column:status" json:"status"`
	CreateTime string `gorm:"column:create_time" json:"create_time"`
	CreateUser string `gorm:"column:create_user" json:"create_user"`
}

func (*TravelAgencyEscapePromptRel) TableName() string {
	return TableNameTravelAgencyEscapePromptRel
}

func (*TravelAgencyEscapePromptRel) PrimaryKey() []string {
	return []string{"rel_id"}
}
