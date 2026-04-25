package healthchunk

import "github.com/demdxx/gocast"

type DayStat struct {
	DayKey       string
	DayStartTime int64
	DayEndTime   int64
	ChatCount    int
	CallCount    int
	ChatEstChars int
	CallEstChars int
}

const DayMillis = int64(24 * 60 * 60 * 1000)

func GapDays(prevEnd int64, nextStart int64) int {
	if prevEnd <= 0 || nextStart <= 0 || nextStart <= prevEnd {
		return 0
	}
	return int((nextStart - prevEnd) / DayMillis)
}

func Plan(dayList []*DayStat, maxDays, maxChatCount, maxCallCount, maxChatChars, maxCallChars int) []map[string]interface{} {
	result := make([]map[string]interface{}, 0)
	if len(dayList) == 0 {
		return result
	}

	chunkNo := 1
	var current map[string]interface{}
	resetChunk := func(item *DayStat) map[string]interface{} {
		return map[string]interface{}{
			"chunk_no":         chunkNo,
			"chunk_start_time": item.DayStartTime,
			"chunk_end_time":   item.DayEndTime,
			"chunk_start_day":  item.DayKey,
			"chunk_end_day":    item.DayKey,
			"chunk_day_count":  1,
			"chat_count":       item.ChatCount,
			"call_count":       item.CallCount,
			"chat_est_chars":   item.ChatEstChars,
			"call_est_chars":   item.CallEstChars,
		}
	}

	for _, item := range dayList {
		if current == nil {
			current = resetChunk(item)
			continue
		}

		nextDayCount := gocast.ToInt(current["chunk_day_count"]) + 1
		nextChatCount := gocast.ToInt(current["chat_count"]) + item.ChatCount
		nextCallCount := gocast.ToInt(current["call_count"]) + item.CallCount
		nextChatChars := gocast.ToInt(current["chat_est_chars"]) + item.ChatEstChars
		nextCallChars := gocast.ToInt(current["call_est_chars"]) + item.CallEstChars
		dayGap := GapDays(gocast.ToInt64(current["chunk_end_time"]), item.DayStartTime)

		needSplit := dayGap > 1 ||
			(maxDays > 0 && nextDayCount > maxDays) ||
			nextChatCount > maxChatCount ||
			nextCallCount > maxCallCount ||
			nextChatChars > maxChatChars ||
			nextCallChars > maxCallChars

		if needSplit {
			result = append(result, current)
			chunkNo++
			current = resetChunk(item)
			continue
		}

		current["chunk_end_time"] = item.DayEndTime
		current["chunk_end_day"] = item.DayKey
		current["chunk_day_count"] = nextDayCount
		current["chat_count"] = nextChatCount
		current["call_count"] = nextCallCount
		current["chat_est_chars"] = nextChatChars
		current["call_est_chars"] = nextCallChars
	}
	if current != nil {
		result = append(result, current)
	}

	return result
}
