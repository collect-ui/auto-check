package base

const TableNameTravelChatContact = "travel_chat_contact"

type TravelChatContact struct {
	ContactID       string `gorm:"column:contact_id;primaryKey" json:"contact_id"`
	AgencyID        string `gorm:"column:agency_id" json:"agency_id"`
	EmployeeID      string `gorm:"column:employee_id" json:"employee_id"`
	WxID            string `gorm:"column:wx_id" json:"wx_id"`
	ContactNickName string `gorm:"column:contact_nick_name" json:"contact_nick_name"`
	NickName        string `gorm:"column:nick_name" json:"nick_name"`
	Head            string `gorm:"column:head" json:"head"`
	Content         string `gorm:"column:content" json:"content"`
	MessageTime     int64  `gorm:"column:message_time" json:"message_time"`
	OwnerWxID       string `gorm:"column:owner_wx_id" json:"owner_wx_id"`
	PersonCount     int    `gorm:"column:person_count" json:"person_count"`
	Type            int    `gorm:"column:type" json:"type"`
	WxAlias         string `gorm:"column:wx_alias" json:"wx_alias"`
	IsGroup         int    `gorm:"column:is_group" json:"is_group"`
	CreateTime      string `gorm:"column:create_time" json:"create_time"`
	ModifyTime      string `gorm:"column:modify_time" json:"modify_time"`
}

func (*TravelChatContact) TableName() string {
	return TableNameTravelChatContact
}

func (*TravelChatContact) PrimaryKey() []string {
	return []string{"contact_id"}
}
