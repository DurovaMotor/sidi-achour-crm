PRAGMA foreign_keys = ON;

CREATE TABLE access_control_settings (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  enabled INTEGER NOT NULL CHECK (enabled IN (0, 1)),
  block_chinese_language INTEGER NOT NULL CHECK (block_chinese_language IN (0, 1)),
  block_china_timezone INTEGER NOT NULL CHECK (block_china_timezone IN (0, 1)),
  block_china_ip INTEGER NOT NULL CHECK (block_china_ip IN (0, 1)),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

INSERT INTO access_control_settings(
  id,
  enabled,
  block_chinese_language,
  block_china_timezone,
  block_china_ip
) VALUES (1, 1, 1, 1, 1);
