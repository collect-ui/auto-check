package healthchunk

import (
	"testing"
	"time"

	"github.com/demdxx/gocast"
)

func mustDayStat(t *testing.T, day string, chatCount, callCount, chatChars, callChars int) *DayStat {
	t.Helper()

	ts, err := time.ParseInLocation("2006-01-02", day, time.FixedZone("CST", 8*3600))
	if err != nil {
		t.Fatalf("parse day %s: %v", day, err)
	}

	return &DayStat{
		DayKey:       day,
		DayStartTime: ts.UnixMilli(),
		DayEndTime:   ts.Add(24*time.Hour - time.Millisecond).UnixMilli(),
		ChatCount:    chatCount,
		CallCount:    callCount,
		ChatEstChars: chatChars,
		CallEstChars: callChars,
	}
}

func TestPlanMergeContinuousDays(t *testing.T) {
	dayList := []*DayStat{
		mustDayStat(t, "2026-04-01", 10, 0, 1000, 0),
		mustDayStat(t, "2026-04-02", 20, 0, 1500, 0),
		mustDayStat(t, "2026-04-03", 30, 0, 1800, 0),
	}

	got := Plan(dayList, 0, 120, 20, 12000, 6000)
	if len(got) != 1 {
		t.Fatalf("expected 1 chunk, got %d", len(got))
	}

	chunk := got[0]
	if start := chunk["chunk_start_day"]; start != "2026-04-01" {
		t.Fatalf("expected start day 2026-04-01, got %v", start)
	}
	if end := chunk["chunk_end_day"]; end != "2026-04-03" {
		t.Fatalf("expected end day 2026-04-03, got %v", end)
	}
	if dayCount := gocast.ToInt(chunk["chunk_day_count"]); dayCount != 3 {
		t.Fatalf("expected day count 3, got %d", dayCount)
	}
}

func TestPlanSplitOnTimeGap(t *testing.T) {
	dayList := []*DayStat{
		mustDayStat(t, "2026-04-01", 10, 0, 1000, 0),
		mustDayStat(t, "2026-04-02", 20, 0, 1500, 0),
		mustDayStat(t, "2026-04-05", 15, 0, 1200, 0),
	}

	got := Plan(dayList, 0, 120, 20, 12000, 6000)
	if len(got) != 2 {
		t.Fatalf("expected 2 chunks, got %d", len(got))
	}

	if firstEnd := got[0]["chunk_end_day"]; firstEnd != "2026-04-02" {
		t.Fatalf("expected first chunk end day 2026-04-02, got %v", firstEnd)
	}
	if secondStart := got[1]["chunk_start_day"]; secondStart != "2026-04-05" {
		t.Fatalf("expected second chunk start day 2026-04-05, got %v", secondStart)
	}
}

func TestPlanSplitOnThreshold(t *testing.T) {
	dayList := []*DayStat{
		mustDayStat(t, "2026-04-01", 70, 0, 4000, 0),
		mustDayStat(t, "2026-04-02", 60, 0, 3500, 0),
		mustDayStat(t, "2026-04-03", 10, 0, 800, 0),
	}

	got := Plan(dayList, 0, 120, 20, 12000, 6000)
	if len(got) != 2 {
		t.Fatalf("expected 2 chunks, got %d", len(got))
	}

	if firstDays := gocast.ToInt(got[0]["chunk_day_count"]); firstDays != 1 {
		t.Fatalf("expected first chunk day count 1, got %d", firstDays)
	}
	if secondStart := got[1]["chunk_start_day"]; secondStart != "2026-04-02" {
		t.Fatalf("expected second chunk start day 2026-04-02, got %v", secondStart)
	}
	if secondDays := gocast.ToInt(got[1]["chunk_day_count"]); secondDays != 2 {
		t.Fatalf("expected second chunk day count 2, got %d", secondDays)
	}
}
