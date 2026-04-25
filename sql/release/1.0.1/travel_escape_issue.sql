create table if not exists travel_escape_issue (
  issue_id varchar(64) primary key,
  employee_id varchar(64) not null default '',
  agency_id varchar(64) not null default '',
  employee_name varchar(128) not null default '',
  issue_status varchar(32) not null default 'pending',
  issue_reason text not null default '',
  issue_detail text not null default '',
  source_log_id varchar(64) not null default '',
  process_result text not null default '',
  process_time varchar(32) not null default '',
  process_user varchar(64) not null default '',
  create_time varchar(32) not null default '',
  create_user varchar(64) not null default '',
  last_modify_time varchar(32) not null default '',
  last_modify_user varchar(64) not null default ''
);

create index if not exists idx_travel_escape_issue_employee_status
  on travel_escape_issue(employee_id, issue_status);

create index if not exists idx_travel_escape_issue_agency_status
  on travel_escape_issue(agency_id, issue_status);
