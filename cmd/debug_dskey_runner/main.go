package main

import (
	"fmt"
	"time"

	templateService "github.com/collect-ui/collect/src/collect/service_imp"
	"moon/model"
	"moon/plugins"
)

func main() {
	code := fmt.Sprintf("ZZ_DSKEY_%d", time.Now().Unix())
	templateService.SetDatabaseModel(&model.TableData{})
	templateService.SetOuterModuleRegister(plugins.GetRegisterList())
	ts := templateService.TemplateService{OpUser: "debug_dskey_runner"}

	saveParams := map[string]interface{}{
		"service":           "hrm.travel_agency_save",
		"agency_id":         code,
		"agency_name":       code,
		"agency_code":       code,
		"biz_type":          "travel",
		"status":            "normal",
		"checkin_status":    "checked_in",
		"wx_sync_enabled":   "yes",
		"wx_sync_account":   "debug-account",
		"wx_sync_password":  "debug-password",
		"deepseek_api_key":  "debug-deepseek-key",
		"description":       "debug deepseek save",
	}
	saveResult := ts.Result(saveParams, false)
	fmt.Printf("saveResult success=%v msg=%s data=%v\n", saveResult.Success, saveResult.Msg, saveResult.GetData())

	queryParams := map[string]interface{}{
		"service":     "hrm.travel_agency_list",
		"agency_code": code,
		"to_obj":      true,
		"pagination":  false,
		"count":       false,
	}
	queryResult := ts.ResultInner(queryParams)
	fmt.Printf("queryResult success=%v msg=%s data=%v\n", queryResult.Success, queryResult.Msg, queryResult.GetData())
}
