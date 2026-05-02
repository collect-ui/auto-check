package plugins

import (
	"encoding/json"
	"strings"

	common "github.com/collect-ui/collect/src/collect/common"
	config "github.com/collect-ui/collect/src/collect/config"
	templateService "github.com/collect-ui/collect/src/collect/service_imp"
	utils "github.com/collect-ui/collect/src/collect/utils"
	"github.com/demdxx/gocast"
)

type HealthUsageSummary struct {
	templateService.BaseHandler
}

func isScalarValue(v interface{}) bool {
	switch v.(type) {
	case nil:
		return false
	case string, bool, int, int8, int16, int32, int64, float32, float64, uint, uint8, uint16, uint32, uint64:
		return true
	default:
		return false
	}
}

func toMap(data interface{}) map[string]interface{} {
	if data == nil {
		return nil
	}
	if result, ok := data.(*common.Result); ok && result != nil {
		if resultMap, ok := result.GetData().(map[string]interface{}); ok {
			return resultMap
		}
	}
	if obj, ok := data.(map[string]interface{}); ok {
		return obj
	}
	return nil
}

func getAnalyzeResultData(item map[string]interface{}) map[string]interface{} {
	if item == nil {
		return nil
	}
	analyzeResult := toMap(item["analyze_result"])
	if analyzeResult == nil {
		return nil
	}
	if dataObj := toMap(analyzeResult["Data"]); dataObj != nil {
		return dataObj
	}
	if dataObj := toMap(analyzeResult["data"]); dataObj != nil {
		return dataObj
	}
	return nil
}

func getChunkTokenData(item map[string]interface{}) map[string]interface{} {
	if item == nil {
		return nil
	}
	// 优先使用原始 analyze_result.Data，避免 update_array 的路径表达式把整个 data map 写进字段
	if data := getAnalyzeResultData(item); data != nil {
		return data
	}
	if data := toMap(item["Data"]); data != nil {
		return data
	}
	if data := toMap(item["data"]); data != nil {
		return data
	}
	return item
}

func pickModelName(current string, data map[string]interface{}) string {
	if !utils.IsValueEmpty(current) {
		return current
	}
	if data == nil {
		return current
	}
	modelName, ok := data["model_name"].(string)
	if !ok || utils.IsValueEmpty(modelName) {
		modelName, ok = data["model"].(string)
		if !ok {
			return current
		}
	}
	modelName = strings.TrimSpace(modelName)
	if utils.IsValueEmpty(modelName) {
		return current
	}
	return modelName
}

func parseJSONMap(value interface{}) map[string]interface{} {
	if value == nil {
		return nil
	}
	if obj := toMap(value); obj != nil {
		return obj
	}
	text, ok := value.(string)
	if !ok || utils.IsValueEmpty(text) {
		return nil
	}
	var m map[string]interface{}
	if err := json.Unmarshal([]byte(text), &m); err != nil {
		return nil
	}
	return m
}

func getInt64(data map[string]interface{}, key string) int64 {
	if data == nil {
		return 0
	}
	value, ok := data[key]
	if !ok || !isScalarValue(value) {
		return 0
	}
	return gocast.ToInt64(value)
}

func parseTokens(data map[string]interface{}) (int64, int64, int64, int64, int64) {
	if data == nil {
		return 0, 0, 0, 0, 0
	}
	promptTokens := getInt64(data, "prompt_tokens")
	completionTokens := getInt64(data, "completion_tokens")
	totalTokens := getInt64(data, "total_tokens")
	promptCacheHitTokens := getInt64(data, "prompt_cache_hit_tokens")
	promptCacheMissTokens := getInt64(data, "prompt_cache_miss_tokens")

	usageMap := parseJSONMap(data["usage"])
	if usageMap == nil {
		usageMap = parseJSONMap(data["usage_json"])
	}
	if usageMap != nil {
		if promptTokens == 0 {
			promptTokens = getInt64(usageMap, "prompt_tokens")
		}
		if completionTokens == 0 {
			completionTokens = getInt64(usageMap, "completion_tokens")
		}
		if totalTokens == 0 {
			totalTokens = getInt64(usageMap, "total_tokens")
		}
		if promptCacheHitTokens == 0 {
			promptCacheHitTokens = getInt64(usageMap, "prompt_cache_hit_tokens")
		}
		if promptCacheMissTokens == 0 {
			promptCacheMissTokens = getInt64(usageMap, "prompt_cache_miss_tokens")
		}
	}
	if totalTokens == 0 && (promptTokens > 0 || completionTokens > 0) {
		totalTokens = promptTokens + completionTokens
	}
	return promptTokens, completionTokens, totalTokens, promptCacheHitTokens, promptCacheMissTokens
}

func (si *HealthUsageSummary) HandlerData(template *config.Template, handlerParam *config.HandlerParam, ts *templateService.TemplateService) *common.Result {
	params := template.GetParams()
	chunkResultList, errMsg := utils.RenderVarToArrMap(handlerParam.Foreach, params)
	if !utils.IsValueEmpty(errMsg) {
		return common.NotOk(handlerParam.Foreach + errMsg)
	}

	var mergeResult map[string]interface{}
	if !utils.IsValueEmpty(handlerParam.Right) {
		mergeObj := utils.RenderVar(handlerParam.Right, params)
		if obj, ok := mergeObj.(map[string]interface{}); ok {
			mergeResult = obj
		}
	}

	var (
		promptTokens          int64 = 0
		completionTokens      int64 = 0
		totalTokens           int64 = 0
		promptCacheHitTokens  int64 = 0
		promptCacheMissTokens int64 = 0
	)
	modelName := ""

	for _, item := range chunkResultList {
		tokenData := getChunkTokenData(item)
		prompt, completion, total, hit, miss := parseTokens(tokenData)
		promptTokens += prompt
		completionTokens += completion
		totalTokens += total
		promptCacheHitTokens += hit
		promptCacheMissTokens += miss
		modelName = pickModelName(modelName, tokenData)
	}

	if mergeResult != nil {
		prompt, completion, total, hit, miss := parseTokens(mergeResult)
		promptTokens += prompt
		completionTokens += completion
		totalTokens += total
		promptCacheHitTokens += hit
		promptCacheMissTokens += miss
		modelName = pickModelName(modelName, mergeResult)
	}

	if utils.IsValueEmpty(modelName) && totalTokens > 0 {
		modelName = "deepseek-v4-flash"
	}

	usageMap := map[string]interface{}{
		"prompt_tokens":            promptTokens,
		"completion_tokens":        completionTokens,
		"total_tokens":             totalTokens,
		"prompt_cache_hit_tokens":  promptCacheHitTokens,
		"prompt_cache_miss_tokens": promptCacheMissTokens,
	}
	usageJSONBytes, _ := json.Marshal(usageMap)

	result := map[string]interface{}{
		"prompt_tokens":            promptTokens,
		"completion_tokens":        completionTokens,
		"total_tokens":             totalTokens,
		"prompt_cache_hit_tokens":  promptCacheHitTokens,
		"prompt_cache_miss_tokens": promptCacheMissTokens,
		"usage_json":               string(usageJSONBytes),
		"model_name":               modelName,
	}

	return common.Ok(result, "汇总月度token成功")
}
