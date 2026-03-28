-- SQL script to add WeChat fields to travel_agency table
-- Run this if the table already exists and needs to be updated

-- Check if columns exist before adding them
-- Note: SQLite doesn't support IF NOT EXISTS for ALTER TABLE ADD COLUMN
-- We need to catch errors or check schema differently

-- For SQLite, you can run these commands:
-- ALTER TABLE travel_agency ADD COLUMN checkin_status TEXT DEFAULT 'pending';
-- ALTER TABLE travel_agency ADD COLUMN wx_sync_enabled TEXT DEFAULT 'no';
-- ALTER TABLE travel_agency ADD COLUMN wx_sync_account TEXT;
-- ALTER TABLE travel_agency ADD COLUMN wx_sync_password TEXT;
-- ALTER TABLE travel_agency ADD COLUMN wx_sync_access_token TEXT;
-- ALTER TABLE travel_agency ADD COLUMN wx_sync_expire_time INTEGER DEFAULT 0;
-- ALTER TABLE travel_agency ADD COLUMN wx_sync_user_id TEXT;
-- ALTER TABLE travel_agency ADD COLUMN wx_sync_department_id TEXT;
-- ALTER TABLE travel_agency ADD COLUMN wx_sync_role_id TEXT;
-- ALTER TABLE travel_agency ADD COLUMN wx_sync_company_id TEXT;
-- ALTER TABLE travel_agency ADD COLUMN wx_last_sync_time TEXT;
-- ALTER TABLE travel_agency ADD COLUMN wx_sync_error_count INTEGER DEFAULT 0;

-- Alternatively, you can recreate the table with all columns:
/*
CREATE TABLE travel_agency_new (
    agency_id TEXT PRIMARY KEY,
    agency_name TEXT,
    agency_code TEXT,
    logo_path TEXT,
    biz_type TEXT,
    status TEXT,
    create_time TEXT,
    create_user TEXT,
    description TEXT,
    checkin_status TEXT DEFAULT 'pending',
    wx_sync_enabled TEXT DEFAULT 'no',
    wx_sync_account TEXT,
    wx_sync_password TEXT,
    wx_sync_access_token TEXT,
    wx_sync_expire_time INTEGER DEFAULT 0,
    wx_sync_user_id TEXT,
    wx_sync_department_id TEXT,
    wx_sync_role_id TEXT,
    wx_sync_company_id TEXT,
    wx_last_sync_time TEXT,
    wx_sync_error_count INTEGER DEFAULT 0
);

INSERT INTO travel_agency_new 
SELECT 
    agency_id, agency_name, agency_code, logo_path, biz_type, status, 
    create_time, create_user, description,
    'pending' as checkin_status,
    'no' as wx_sync_enabled,
    '' as wx_sync_account,
    '' as wx_sync_password,
    '' as wx_sync_access_token,
    0 as wx_sync_expire_time,
    '' as wx_sync_user_id,
    '' as wx_sync_department_id,
    '' as wx_sync_role_id,
    '' as wx_sync_company_id,
    '' as wx_last_sync_time,
    0 as wx_sync_error_count
FROM travel_agency;

DROP TABLE travel_agency;
ALTER TABLE travel_agency_new RENAME TO travel_agency;
*/