alter table travel_agency
  add column deepseek_api_key text default '';

alter table travel_escape_analyze_log
  add column prompt_tokens integer default 0;

alter table travel_escape_analyze_log
  add column completion_tokens integer default 0;

alter table travel_escape_analyze_log
  add column total_tokens integer default 0;

alter table travel_escape_analyze_log
  add column usage_json text default '';
