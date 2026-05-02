CREATE TABLE IF NOT EXISTS travel_agency_tencent_key (
  key_id varchar(64) primary key,
  agency_id varchar(64) not null,
  account_name varchar(255) not null,
  region varchar(64) default 'ap-beijing',
  monthly_quota_seconds integer default 0,
  source_type varchar(32) default 'manual',
  remote_request_id varchar(64) default '',
  remote_created_at varchar(64) default '',
  remote_reviewed_at varchar(64) default '',
  remote_status varchar(32) default '',
  remote_review_comment varchar(1024) default '',
  status varchar(32) default 'normal',
  remark varchar(1024) default '',
  last_health_status varchar(32) default 'unknown',
  last_health_message varchar(1024) default '',
  last_used_duration_seconds integer default 0,
  last_remaining_quota_seconds integer default 0,
  last_sync_time varchar(64) default '',
  create_time varchar(64) default '',
  create_user varchar(64) default '',
  modify_time varchar(64) default '',
  modify_user varchar(64) default '',
  is_delete varchar(8) default '0'
);

CREATE UNIQUE INDEX IF NOT EXISTS uk_travel_agency_tencent_key_account_name
ON travel_agency_tencent_key(account_name);

CREATE INDEX IF NOT EXISTS idx_travel_agency_tencent_key_agency
ON travel_agency_tencent_key(agency_id);

CREATE INDEX IF NOT EXISTS idx_travel_agency_tencent_key_status
ON travel_agency_tencent_key(status);

CREATE INDEX IF NOT EXISTS idx_travel_agency_tencent_key_remote_request
ON travel_agency_tencent_key(remote_request_id);
