package model

import (
	"fmt"

	baseModel "moon/model/base"

	templateService "github.com/collect-ui/collect/src/collect/service_imp"
	utils "github.com/collect-ui/collect/src/collect/utils"
)

var travelCallRecordUIDScopeStatements = []string{
	`UPDATE travel_call_record
SET uid = agency_id || '::' || uid
WHERE ifnull(uid, '') != ''
  AND ifnull(agency_id, '') != ''
  AND instr(uid, '::') = 0
  AND NOT EXISTS (
    SELECT 1
    FROM travel_call_record t2
    WHERE t2.uid = travel_call_record.agency_id || '::' || travel_call_record.uid
  )`,
	`DELETE FROM travel_call_record
WHERE ifnull(uid, '') != ''
  AND ifnull(agency_id, '') != ''
  AND instr(uid, '::') = 0
  AND EXISTS (
    SELECT 1
    FROM travel_call_record t2
    WHERE t2.uid = travel_call_record.agency_id || '::' || travel_call_record.uid
  )`,
}

// EnsureTravelCallRecordUIDScope migrates call-record uid to agency-scoped uid for multi-agency isolation.
func EnsureTravelCallRecordUIDScope() error {
	driverName := utils.GetAppKey("driverName")
	if driverName != "sqlite3" {
		return nil
	}

	base := templateService.BaseHandler{}
	gormDB := base.GetGormDb()
	if gormDB == nil {
		return fmt.Errorf("迁移travel_call_record.uid失败: gorm db未初始化")
	}

	var tableCount int64
	if err := gormDB.Raw(
		"SELECT count(1) FROM sqlite_master WHERE type='table' AND name=?",
		baseModel.TableNameTravelCallRecord,
	).Scan(&tableCount).Error; err != nil {
		return fmt.Errorf("迁移travel_call_record.uid失败: 查询表信息异常: %w", err)
	}
	if tableCount == 0 {
		return nil
	}

	for _, sql := range travelCallRecordUIDScopeStatements {
		if err := gormDB.Exec(sql).Error; err != nil {
			return fmt.Errorf("迁移travel_call_record.uid失败: %w", err)
		}
	}

	return nil
}
