-- 为 travel_escape_analyze_log 补充 token 用量字段
-- 适配 detect_escape_analyze_log_save / detect_escape_analyze_log_list

ALTER TABLE travel_escape_analyze_log
  ADD COLUMN prompt_tokens INTEGER DEFAULT 0;

ALTER TABLE travel_escape_analyze_log
  ADD COLUMN completion_tokens INTEGER DEFAULT 0;

ALTER TABLE travel_escape_analyze_log
  ADD COLUMN total_tokens INTEGER DEFAULT 0;

ALTER TABLE travel_escape_analyze_log
  ADD COLUMN usage_json TEXT DEFAULT '';

