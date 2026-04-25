package base

const TableNameTravelCallRecord = "travel_call_record"

type TravelCallRecord struct {
	UID string `gorm:"column:uid;primaryKey" json:"uid"`

	AgencyID   string `gorm:"column:agency_id" json:"agency_id"`
	EmployeeID string `gorm:"column:employee_id" json:"employee_id"`

	PhoneID            int64  `gorm:"column:phone_id" json:"phone_id"`
	Name               string `gorm:"column:name" json:"name"`
	PhoneOutNumber     string `gorm:"column:phone_out_number" json:"phone_out_number"`
	PhoneInNumber      string `gorm:"column:phone_in_number" json:"phone_in_number"`
	Relegation         string `gorm:"column:relegation" json:"relegation"`
	PhoneOperator      int    `gorm:"column:phone_operator" json:"phone_operator"`
	PhoneCallType      int    `gorm:"column:phone_call_type" json:"phone_call_type"`
	PhoneClientType    int    `gorm:"column:phone_client_type" json:"phone_client_type"`
	RingTimeLength     int    `gorm:"column:ring_time_length" json:"ring_time_length"`
	PhoneRingTime      int64  `gorm:"column:phone_ring_time" json:"phone_ring_time"`
	PhoneEndTime       int64  `gorm:"column:phone_end_time" json:"phone_end_time"`
	PhoneStatus        int    `gorm:"column:phone_status" json:"phone_status"`
	CallTimeLength     int    `gorm:"column:call_time_length" json:"call_time_length"`
	PhoneRecordAddress string `gorm:"column:phone_record_address" json:"phone_record_address"`
	PhoneStartTime     int64  `gorm:"column:phone_start_time" json:"phone_start_time"`
	GroupID            int64  `gorm:"column:group_id" json:"group_id"`
	UserID             int64  `gorm:"column:user_id" json:"user_id"`
	PhoneType          int    `gorm:"column:phone_type" json:"phone_type"`
	ParsedText         string `gorm:"column:parsed_text" json:"parsed_text"`
	PhoneRecordText    string `gorm:"column:phone_record_text" json:"phone_record_text"`

	CreateTime  string  `gorm:"column:create_time" json:"create_time"`
	ModifyTime  string  `gorm:"column:modify_time" json:"modify_time"`
	AnalyzeTime *string `gorm:"column:analyze_time" json:"analyze_time"`
}

func (*TravelCallRecord) TableName() string {
	return TableNameTravelCallRecord
}

func (*TravelCallRecord) PrimaryKey() []string {
	return []string{"uid"}
}
