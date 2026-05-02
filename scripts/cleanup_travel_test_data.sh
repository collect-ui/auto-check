#!/usr/bin/env bash
set -euo pipefail

DB_PATH="${1:-database/auto_check.db}"
KEEP_USERNAME="${KEEP_USERNAME:-admin}"

if [[ ! -f "$DB_PATH" ]]; then
  echo "数据库文件不存在: $DB_PATH" >&2
  exit 1
fi

# Escape single quote for SQL literal usage.
KEEP_USERNAME_SQL=${KEEP_USERNAME//\'/\'\'}

sqlite3 -cmd ".timeout 8000" "$DB_PATH" <<SQL
BEGIN TRANSACTION;

DELETE FROM customer_lead_assign_log;
DELETE FROM customer_lead_assign;
DELETE FROM customer_lead_pool;

DELETE FROM travel_chat_record;
DELETE FROM travel_chat_contact;
DELETE FROM travel_call_record;
DELETE FROM travel_escape_analyze_log;
DELETE FROM travel_escape_issue;
DELETE FROM travel_employee;
DELETE FROM travel_agency_route_sales_rel;
DELETE FROM travel_agency_route;
DELETE FROM travel_agency_user_rel;
DELETE FROM travel_agency_tencent_key;
DELETE FROM travel_agency_escape_prompt_rel;
DELETE FROM travel_agency_checkin_apply;
DELETE FROM travel_model_price;
DELETE FROM travel_escape_prompt_keyword;
DELETE FROM travel_agency;

DELETE FROM user_role_id_list
WHERE user_id NOT IN (
  SELECT user_id FROM user_account WHERE username='${KEEP_USERNAME_SQL}'
);

DELETE FROM user_change_history
WHERE ifnull(user_id, '') NOT IN (
    SELECT user_id FROM user_account WHERE username='${KEEP_USERNAME_SQL}'
  )
   OR ifnull(create_user, '') NOT IN (
    SELECT user_id FROM user_account WHERE username='${KEEP_USERNAME_SQL}'
  );

DELETE FROM user_account
WHERE username <> '${KEEP_USERNAME_SQL}';

COMMIT;
SQL

echo "清理完成: db=$DB_PATH, 保留账号=$KEEP_USERNAME"
