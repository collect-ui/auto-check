-- 逃单分析日志表（SQLite）
-- 记录每轮大模型分析的输入、输出与关键元数据

CREATE TABLE IF NOT EXISTS travel_escape_analyze_log (
  log_id TEXT PRIMARY KEY,
  employee_id TEXT NOT NULL,
  agency_id TEXT DEFAULT '',
  employee_name TEXT DEFAULT '',
  analyze_source TEXT DEFAULT 'manual',
  system_prompt TEXT DEFAULT '',
  prompt_content TEXT DEFAULT '',
  ai_result TEXT DEFAULT '',
  is_escape INTEGER DEFAULT 0,
  chat_count INTEGER DEFAULT 0,
  call_count INTEGER DEFAULT 0,
  chat_latest_message_time BIGINT DEFAULT 0,
  call_latest_phone_time BIGINT DEFAULT 0,
  create_time TEXT,
  create_user TEXT DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_escape_analyze_log_employee_time
  ON travel_escape_analyze_log(employee_id, create_time DESC);
