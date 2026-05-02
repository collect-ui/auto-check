//go:build ignore

package main

import (
	"encoding/json"
	"fmt"
	"os"
	"strconv"

	collectBase "github.com/collect-ui/collect/src/collect/service_imp"
	templateService "github.com/collect-ui/collect/src/collect/service_imp"
	collectUtils "github.com/collect-ui/collect/src/collect/utils"
	"moon/model"
)

func main() {
	wd, _ := os.Getwd()
	fmt.Println("WD=" + wd)
	fmt.Println("DSN=" + collectUtils.GetAppKey("dataSourceName"))
	templateService.SetDatabaseModel(&model.TableData{})

	agencyID := os.Getenv("AGENCY_ID")
	if agencyID == "" {
		agencyID = "UT_CLEANUP_AG_20260424"
	}
	cutoffTime := int64(1772294400000)
	if raw := os.Getenv("CUTOFF_TIME"); raw != "" {
		if parsed, err := strconv.ParseInt(raw, 10, 64); err == nil {
			cutoffTime = parsed
		}
	}

	base := collectBase.BaseHandler{}
	db := base.GetGormDb()
	type dbInfo struct {
		Seq  int
		Name string
		File string
	}
	var dbList []dbInfo
	db.Raw("pragma database_list").Scan(&dbList)
	var beforeChat int64
	var beforeCall int64
	var beforeContact int64
	db.Table("travel_chat_record").Where("agency_id = ?", agencyID).Count(&beforeChat)
	db.Table("travel_call_record").Where("agency_id = ?", agencyID).Count(&beforeCall)
	db.Table("travel_chat_contact").Where("agency_id = ?", agencyID).Count(&beforeContact)
	fmt.Printf("DBLIST=%+v\n", dbList)
	fmt.Printf("AGENCY_ID=%s\n", agencyID)
	fmt.Printf("CUTOFF_TIME=%d\n", cutoffTime)
	fmt.Printf("BEFORE=chat:%d call:%d contact:%d\n", beforeChat, beforeCall, beforeContact)

	ts := templateService.TemplateService{OpUser: "test"}
	params := map[string]interface{}{
		"service":     "hrm.cleanup_travel_history_data",
		"agency_id":   agencyID,
		"cutoff_time": cutoffTime,
	}
	result := ts.ResultInner(params)
	data, _ := json.Marshal(result)
	fmt.Println(string(data))

	var afterChat int64
	var afterCall int64
	var afterContact int64
	db.Table("travel_chat_record").Where("agency_id = ?", agencyID).Count(&afterChat)
	db.Table("travel_call_record").Where("agency_id = ?", agencyID).Count(&afterCall)
	db.Table("travel_chat_contact").Where("agency_id = ?", agencyID).Count(&afterContact)
	fmt.Printf("AFTER=chat:%d call:%d contact:%d\n", afterChat, afterCall, afterContact)
}
