-- 逃单增量兼容：新增分析时间字段（年月日时分秒）
-- 注意：该脚本为一次性迁移脚本，请勿重复执行。

ALTER TABLE travel_chat_record ADD COLUMN analyze_time TEXT;
ALTER TABLE travel_call_record ADD COLUMN analyze_time TEXT;
ALTER TABLE travel_escape_analyze_log ADD COLUMN chat_latest_analyze_time TEXT;
ALTER TABLE travel_escape_analyze_log ADD COLUMN call_latest_analyze_time TEXT;

-- 历史数据回填：首次按事件时间写入分析时间
UPDATE travel_chat_record
SET analyze_time = datetime(message_time / 1000, 'unixepoch', '+8 hours')
WHERE ifnull(analyze_time, '') = ''
  AND ifnull(message_time, 0) > 0;

UPDATE travel_call_record
SET analyze_time = datetime(phone_start_time / 1000, 'unixepoch', '+8 hours')
WHERE ifnull(analyze_time, '') = ''
  AND ifnull(phone_start_time, 0) > 0;
