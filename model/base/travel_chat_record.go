package base

const TableNameTravelChatRecord = "travel_chat_record"

type TravelChatRecord struct {
	// 主键：消息唯一标识
	UID string `gorm:"column:uid;primaryKey" json:"uid"`

	// 关联字段
	AgencyID   string `gorm:"column:agency_id" json:"agency_id"`
	EmployeeID string `gorm:"column:employee_id" json:"employee_id"`
	ContactID  string `gorm:"column:contact_id" json:"contact_id"`

	// 微信相关字段
	ContactWxID     string `gorm:"column:contact_wx_id" json:"contact_wx_id"`
	WxID            string `gorm:"column:wx_id;primaryKey" json:"wx_id"`
	OwnerWxID       string `gorm:"column:owner_wx_id" json:"owner_wx_id"`
	OwnerHead       string `gorm:"column:owner_head" json:"owner_head"`
	OwnerNickName   string `gorm:"column:owner_nick_name" json:"owner_nick_name"`
	ContactNickName string `gorm:"column:contact_nick_name" json:"contact_nick_name"`
	NickName        string `gorm:"column:nick_name" json:"nick_name"`
	Head            string `gorm:"column:head" json:"head"`
	WxAlias         string `gorm:"column:wx_alias" json:"wx_alias"`

	// 群聊相关字段
	IsGroup             int     `gorm:"column:is_group" json:"is_group"`
	GroupUserWxID       string  `gorm:"column:group_user_wx_id" json:"group_user_wx_id"`
	GroupUserWxNickName string  `gorm:"column:group_user_wx_nick_name" json:"group_user_wx_nick_name"`
	GroupUserWxHead     string  `gorm:"column:group_user_wx_head" json:"group_user_wx_head"`
	GroupUserWxRoomName *string `gorm:"column:group_user_wx_room_name" json:"group_user_wx_room_name"`

	// 消息内容字段
	MessageType   int    `gorm:"column:message_type" json:"message_type"`
	Content       string `gorm:"column:content" json:"content"`
	MessageTime   int64  `gorm:"column:message_time" json:"message_time"`
	MessageStatus int    `gorm:"column:message_status" json:"message_status"`
	WxMsgID       int64  `gorm:"column:wx_msg_id" json:"wx_msg_id"`

	// 文件相关字段
	FileName   *string `gorm:"column:file_name" json:"file_name"`
	FileSize   *int64  `gorm:"column:file_size" json:"file_size"`
	FileStatus *int    `gorm:"column:file_status" json:"file_status"`
	FileURL    *string `gorm:"column:file_url" json:"file_url"`
	FileText   *string `gorm:"column:file_text" json:"file_text"`

	// 链接相关字段
	LinkURL *string `gorm:"column:link_url" json:"link_url"`

	// 转账相关字段
	TransferMoney       *float64 `gorm:"column:transfer_money" json:"transfer_money"`
	TransferStatus      *int     `gorm:"column:transfer_status" json:"transfer_status"`
	ReceiveTransferTime *int64   `gorm:"column:receive_transfer_time" json:"receive_transfer_time"`
	TranscationId       *string  `gorm:"column:transcation_id" json:"transcation_id"`

	// 红包相关字段
	RedPacket               *string `gorm:"column:red_packet" json:"red_packet"`
	RedPacketType           *int    `gorm:"column:red_packet_type" json:"red_packet_type"`
	RedPacketStatus         *int    `gorm:"column:red_packet_status" json:"red_packet_status"`
	RedPacketCount          *int    `gorm:"column:red_packet_count" json:"red_packet_count"`
	RedPacketEndTime        *int64  `gorm:"column:red_packet_end_time" json:"red_packet_end_time"`
	RedPacketFromWxId       *string `gorm:"column:red_packet_from_wx_id" json:"red_packet_from_wx_id"`
	RedPacketFromWxNickName *string `gorm:"column:red_packet_from_wx_nick_name" json:"red_packet_from_wx_nick_name"`

	// 通话相关字段
	CallTime      *int64 `gorm:"column:call_time" json:"call_time"`
	StartCallTime *int64 `gorm:"column:start_call_time" json:"start_call_time"`
	EndCallTime   *int64 `gorm:"column:end_call_time" json:"end_call_time"`

	// 其他字段
	MessageCheckTime *int64  `gorm:"column:message_check_time" json:"message_check_time"`
	WithdrawTime     *int64  `gorm:"column:withdraw_time" json:"withdraw_time"`
	UserNickName     *string `gorm:"column:user_nick_name" json:"user_nick_name"`
	CompanyId        *int64  `gorm:"column:company_id" json:"company_id"`
	DepId            *int64  `gorm:"column:dep_id" json:"dep_id"`
	UserId           *int64  `gorm:"column:user_id" json:"user_id"`

	// 系统字段
	CreateTime string `gorm:"column:create_time" json:"create_time"`
	ModifyTime string `gorm:"column:modify_time" json:"modify_time"`
}

func (*TravelChatRecord) TableName() string {
	return TableNameTravelChatRecord
}

func (*TravelChatRecord) PrimaryKey() []string {
	return []string{"uid", "wx_id"}
}
