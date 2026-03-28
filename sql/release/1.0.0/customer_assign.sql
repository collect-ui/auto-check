create table if not exists customer_lead_pool (
  lead_id varchar(64) primary key,
  agency_id varchar(64) not null,
  customer_name varchar(128) not null,
  contact varchar(64) not null default '',
  wechat_account varchar(128) not null default '',
  source_platform varchar(32) not null default 'douyin',
  status varchar(32) not null default 'normal',
  description text,
  create_time datetime not null,
  create_user varchar(64) not null default ''
);

create index if not exists idx_customer_lead_pool_agency on customer_lead_pool(agency_id);
create index if not exists idx_customer_lead_pool_create_time on customer_lead_pool(create_time);

create table if not exists customer_lead_assign (
  assign_id varchar(64) primary key,
  lead_id varchar(64) not null,
  agency_id varchar(64) not null,
  assign_date varchar(16) not null,
  sales_user_id varchar(64) not null,
  route_id varchar(64) not null default '',
  supervisor_user_id varchar(64) not null default '',
  status varchar(32) not null default 'normal',
  description text,
  create_time datetime not null,
  create_user varchar(64) not null default '',
  update_time datetime not null,
  update_user varchar(64) not null default ''
);

create index if not exists idx_customer_lead_assign_lead on customer_lead_assign(lead_id);
create index if not exists idx_customer_lead_assign_agency_date on customer_lead_assign(agency_id, assign_date);
create unique index if not exists uq_customer_lead_assign_lead_date on customer_lead_assign(lead_id, assign_date);

create table if not exists travel_agency_route (
  route_id varchar(64) primary key,
  agency_id varchar(64) not null,
  route_code varchar(64) not null,
  route_name varchar(128) not null,
  status varchar(32) not null default 'normal',
  description text,
  create_time datetime not null,
  create_user varchar(64) not null default ''
);
create index if not exists idx_travel_agency_route_agency on travel_agency_route(agency_id);
create unique index if not exists uq_travel_agency_route_code on travel_agency_route(agency_id, route_code);

create table if not exists travel_agency_route_sales_rel (
  rel_id varchar(64) primary key,
  agency_id varchar(64) not null,
  route_id varchar(64) not null,
  sales_user_id varchar(64) not null,
  status varchar(32) not null default 'normal',
  create_time datetime not null,
  create_user varchar(64) not null default ''
);
create unique index if not exists uq_travel_agency_route_sales on travel_agency_route_sales_rel(route_id, sales_user_id);

create table if not exists customer_lead_assign_log (
  log_id varchar(64) primary key,
  assign_id varchar(64) not null,
  lead_id varchar(64) not null,
  action_type varchar(32) not null,
  old_sales_user_id varchar(64) not null default '',
  new_sales_user_id varchar(64) not null default '',
  assign_date varchar(16) not null,
  description text,
  create_time datetime not null,
  create_user varchar(64) not null default ''
);

create index if not exists idx_customer_lead_assign_log_assign on customer_lead_assign_log(assign_id);
create index if not exists idx_customer_lead_assign_log_lead_date on customer_lead_assign_log(lead_id, assign_date);
