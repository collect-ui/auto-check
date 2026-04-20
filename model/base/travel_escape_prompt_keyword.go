package base

const TableNameTravelEscapePromptKeyword = "travel_escape_prompt_keyword"

type TravelEscapePromptKeyword struct {
	Keyword    string `gorm:"column:keyword;primaryKey" json:"keyword"`
	Status     string `gorm:"column:status" json:"status"`
	CreateTime string `gorm:"column:create_time" json:"create_time"`
	CreateUser string `gorm:"column:create_user" json:"create_user"`
}

func (*TravelEscapePromptKeyword) TableName() string {
	return TableNameTravelEscapePromptKeyword
}

func (*TravelEscapePromptKeyword) PrimaryKey() []string {
	return []string{"keyword"}
}
