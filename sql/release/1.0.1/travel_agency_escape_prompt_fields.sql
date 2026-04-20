-- 为 travel_agency 增加逃单分析提示词配置字段（SQLite）
-- 若字段已存在，执行会报 duplicate column，可忽略。

ALTER TABLE travel_agency ADD COLUMN escape_system_prompt TEXT DEFAULT '';
ALTER TABLE travel_agency ADD COLUMN escape_user_prompt TEXT DEFAULT '';
