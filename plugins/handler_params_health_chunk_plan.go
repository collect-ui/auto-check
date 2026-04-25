package plugins

import (
	"sort"
	"time"

	"moon/internal/healthchunk"

	common "github.com/collect-ui/collect/src/collect/common"
	config "github.com/collect-ui/collect/src/collect/config"
	templateService "github.com/collect-ui/collect/src/collect/service_imp"
	utils "github.com/collect-ui/collect/src/collect/utils"
	"github.com/demdxx/gocast"
)

type HealthChunkPlan struct {
	templateService.BaseHandler
}

type healthDayStat struct {
	DayKey       string
	DayStartTime int64
	DayEndTime   int64
	ChatCount    int
	CallCount    int
	ChatEstChars int
	CallEstChars int
}

func dayBounds(ts int64) (string, int64, int64) {
	t := time.UnixMilli(ts).In(time.FixedZone("CST", 8*3600))
	start := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
	end := time.Date(t.Year(), t.Month(), t.Day(), 23, 59, 59, int(time.Millisecond*999), t.Location())
	return start.Format("2006-01-02"), start.UnixMilli(), end.UnixMilli()
}

func toInt(v interface{}, def int) int {
	if utils.IsValueEmpty(v) {
		return def
	}
	return gocast.ToInt(v)
}

func addChatDay(dayMap map[string]*healthDayStat, item map[string]interface{}) {
	ts := gocast.ToInt64(item["message_time"])
	if ts <= 0 {
		return
	}
	dayKey, start, end := dayBounds(ts)
	if _, ok := dayMap[dayKey]; !ok {
		dayMap[dayKey] = &healthDayStat{
			DayKey:       dayKey,
			DayStartTime: start,
			DayEndTime:   end,
		}
	}
	stat := dayMap[dayKey]
	stat.ChatCount++
	stat.ChatEstChars += len(utils.Strval(item["content"])) + len(utils.Strval(item["file_text"])) + 80
}

func addCallDay(dayMap map[string]*healthDayStat, item map[string]interface{}) {
	ts := gocast.ToInt64(item["phone_start_time"])
	if ts <= 0 {
		return
	}
	dayKey, start, end := dayBounds(ts)
	if _, ok := dayMap[dayKey]; !ok {
		dayMap[dayKey] = &healthDayStat{
			DayKey:       dayKey,
			DayStartTime: start,
			DayEndTime:   end,
		}
	}
	stat := dayMap[dayKey]
	stat.CallCount++
	stat.CallEstChars += len(utils.Strval(item["phone_record_text"])) + len(utils.Strval(item["parsed_text"])) + 80
}

func (si *HealthChunkPlan) HandlerData(template *config.Template, handlerParam *config.HandlerParam, ts *templateService.TemplateService) *common.Result {
	params := template.GetParams()

	chatList, errMsg := utils.RenderVarToArrMap(handlerParam.Foreach, params)
	if !utils.IsValueEmpty(errMsg) {
		return common.NotOk(handlerParam.Foreach + errMsg)
	}
	callList, errMsg := utils.RenderVarToArrMap(handlerParam.Right, params)
	if !utils.IsValueEmpty(errMsg) {
		return common.NotOk(handlerParam.Right + errMsg)
	}

	maxDays := toInt(params["max_days_per_chunk"], 0)
	maxChatCount := toInt(params["max_chat_count_per_chunk"], 120)
	maxCallCount := toInt(params["max_call_count_per_chunk"], 20)
	maxChatChars := toInt(params["max_chat_chars_per_chunk"], 12000)
	maxCallChars := toInt(params["max_call_chars_per_chunk"], 6000)

	dayMap := make(map[string]*healthDayStat)
	for _, item := range chatList {
		addChatDay(dayMap, item)
	}
	for _, item := range callList {
		addCallDay(dayMap, item)
	}

	dayList := make([]*healthDayStat, 0, len(dayMap))
	for _, item := range dayMap {
		dayList = append(dayList, item)
	}
	sort.Slice(dayList, func(i, j int) bool {
		return dayList[i].DayStartTime < dayList[j].DayStartTime
	})

	if len(dayList) == 0 {
		return common.Ok([]map[string]interface{}{}, "无可分片数据")
	}

	planInput := make([]*healthchunk.DayStat, 0, len(dayList))
	for _, item := range dayList {
		planInput = append(planInput, &healthchunk.DayStat{
			DayKey:       item.DayKey,
			DayStartTime: item.DayStartTime,
			DayEndTime:   item.DayEndTime,
			ChatCount:    item.ChatCount,
			CallCount:    item.CallCount,
			ChatEstChars: item.ChatEstChars,
			CallEstChars: item.CallEstChars,
		})
	}
	result := healthchunk.Plan(planInput, maxDays, maxChatCount, maxCallCount, maxChatChars, maxCallChars)

	return common.Ok(result, "生成体检分片成功")
}
