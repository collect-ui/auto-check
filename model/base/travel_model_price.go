package base

const TableNameTravelModelPrice = "travel_model_price"

type TravelModelPrice struct {
	ModelPriceID             string  `gorm:"column:model_price_id;primaryKey" json:"model_price_id"`
	Provider                 string  `gorm:"column:provider" json:"provider"`
	ModelName                string  `gorm:"column:model_name" json:"model_name"`
	Currency                 string  `gorm:"column:currency" json:"currency"`
	InputCacheHitPricePer1m  float64 `gorm:"column:input_cache_hit_price_per_1m" json:"input_cache_hit_price_per_1m"`
	InputCacheMissPricePer1m float64 `gorm:"column:input_cache_miss_price_per_1m" json:"input_cache_miss_price_per_1m"`
	OutputPricePer1m         float64 `gorm:"column:output_price_per_1m" json:"output_price_per_1m"`
	Description              string  `gorm:"column:description" json:"description"`
	Status                   string  `gorm:"column:status" json:"status"`
	CreateTime               string  `gorm:"column:create_time" json:"create_time"`
	CreateUser               string  `gorm:"column:create_user" json:"create_user"`
	ModifyTime               string  `gorm:"column:modify_time" json:"modify_time"`
	ModifyUser               string  `gorm:"column:modify_user" json:"modify_user"`
}

func (*TravelModelPrice) TableName() string {
	return TableNameTravelModelPrice
}

func (*TravelModelPrice) PrimaryKey() []string {
	return []string{"model_price_id"}
}
