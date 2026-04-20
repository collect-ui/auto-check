CREATE TABLE IF NOT EXISTS travel_escape_prompt_keyword (
  keyword TEXT PRIMARY KEY,
  status varchar(32) NOT NULL DEFAULT 'normal',
  create_time datetime NOT NULL,
  create_user varchar(64) NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS travel_agency_escape_prompt_rel (
  rel_id varchar(64) PRIMARY KEY,
  agency_id varchar(64) NOT NULL,
  prompt_type varchar(32) NOT NULL,
  keyword TEXT NOT NULL,
  sort_no INT NOT NULL DEFAULT 0,
  status varchar(32) NOT NULL DEFAULT 'normal',
  create_time datetime NOT NULL,
  create_user varchar(64) NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_travel_agency_escape_prompt_rel_agency
  ON travel_agency_escape_prompt_rel(agency_id, prompt_type, sort_no);

CREATE UNIQUE INDEX IF NOT EXISTS uq_travel_agency_escape_prompt_rel
  ON travel_agency_escape_prompt_rel(agency_id, prompt_type, keyword);
