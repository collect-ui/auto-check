-- 模型价格维护表（支持后续多模型接入）
CREATE TABLE IF NOT EXISTS travel_model_price (
  model_price_id varchar(50) primary key,
  provider varchar(64) default 'deepseek',
  model_name varchar(128) not null,
  currency varchar(16) default 'CNY',
  input_cache_hit_price_per_1m real default 0,
  input_cache_miss_price_per_1m real default 0,
  output_price_per_1m real default 0,
  description varchar(1000) default '',
  status varchar(32) default 'normal',
  create_time varchar(64) default '',
  create_user varchar(64) default '',
  modify_time varchar(64) default '',
  modify_user varchar(64) default ''
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_travel_model_price_model_name
  ON travel_model_price(model_name);

CREATE INDEX IF NOT EXISTS idx_travel_model_price_status
  ON travel_model_price(status);

-- 逃单分析日志补充模型名，支持按模型单价核算
ALTER TABLE travel_escape_analyze_log
  ADD COLUMN model_name TEXT DEFAULT '';

-- 初始化 deepseek-v4-flash 单价（CNY / 1M tokens）
INSERT INTO travel_model_price (
  model_price_id,
  provider,
  model_name,
  currency,
  input_cache_hit_price_per_1m,
  input_cache_miss_price_per_1m,
  output_price_per_1m,
  description,
  status,
  create_time,
  create_user,
  modify_time,
  modify_user
)
SELECT
  'mp_deepseek_v4_flash',
  'deepseek',
  'deepseek-v4-flash',
  'CNY',
  0.5,
  2,
  8,
  '默认初始化单价',
  'normal',
  datetime('now', 'localtime'),
  'system',
  datetime('now', 'localtime'),
  'system'
WHERE NOT EXISTS (
  SELECT 1 FROM travel_model_price WHERE model_name = 'deepseek-v4-flash'
);

