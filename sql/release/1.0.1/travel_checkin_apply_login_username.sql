ALTER TABLE travel_agency_checkin_apply ADD COLUMN login_username varchar(255) DEFAULT '';
CREATE INDEX IF NOT EXISTS idx_travel_checkin_apply_login_username ON travel_agency_checkin_apply(login_username);
UPDATE travel_agency_checkin_apply
SET login_username = agency_code
WHERE ifnull(login_username, '') = '';
