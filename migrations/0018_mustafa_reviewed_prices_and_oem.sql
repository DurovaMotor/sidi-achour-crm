PRAGMA foreign_keys = ON;

CREATE TABLE rollback_0018_reviewed_price_updates (
  record_id TEXT PRIMARY KEY,
  product_code TEXT NOT NULL,
  reviewed_new_price_cny REAL NOT NULL,
  source_row INTEGER NOT NULL
);

INSERT INTO rollback_0018_reviewed_price_updates(
  record_id,
  product_code,
  reviewed_new_price_cny,
  source_row
) VALUES
  ('bobines-et-allumage-15', '31120-F8-HCE-8', 38, 50),
  ('demarreurs-16', '3121A-FID-ZF', 27, 54),
  ('jantes-6', '42601-ASC-PT', 63, 63),
  ('cables-et-durites-19', '45126-93-PT', 8, 73),
  ('moteurs-9', '50110-GY6-FC-A', 680, 84),
  ('fourches-avant-6', '51350-FX100-ZF', 61, 85),
  ('amortisseurs-6', '52400-AR1-PT-BL', 28, 90),
  ('bougies-6', '98056-10MM-HONDA', 1.3, 107);

CREATE TABLE rollback_0018_oem_targets (
  record_id TEXT PRIMARY KEY,
  product_code TEXT NOT NULL,
  source_row INTEGER NOT NULL
);

INSERT INTO rollback_0018_oem_targets(record_id, product_code, source_row) VALUES
  ('cylindres-et-carters-6', '12100-A61-PTSY-A', 12),
  ('pistons-6', '13010-A6A-PTSY', 19),
  ('chaines-de-distribution-8', '14401-F6C-HJ', 22),
  ('chaines-de-distribution-7', '14401-KV7-HJ', 23),
  ('chaines-de-distribution-6', '14401-V02-HJ', 24),
  ('filtres-a-air-6', '17211-H6B-PTDC', 40),
  ('embrayages-9', '22300-F6A-XS-SYM', 48),
  ('bobines-et-allumage-15', '31120-F8-HCE-8', 50),
  ('jantes-11', '42611-3J3-PT', 67),
  ('vis-boulons-et-bagues-15', '42611-3J3-PT', 68);

CREATE TABLE rollback_0018_primary_order_state AS
SELECT state.*
FROM product_order_state state
WHERE state.record_id IN (
  SELECT record_id FROM rollback_0018_reviewed_price_updates
  UNION
  SELECT record_id FROM rollback_0018_oem_targets
);

CREATE TABLE rollback_0018_priority_order_state AS
SELECT state.*
FROM sidi_priority_order_state state
JOIN rollback_0018_oem_targets target
  ON target.record_id = state.record_id;

INSERT INTO product_order_state(
  record_id,
  new_price_cny,
  ordered_quantity,
  remark,
  updated_at
)
SELECT
  update_row.record_id,
  update_row.reviewed_new_price_cny,
  0,
  '',
  strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
FROM rollback_0018_reviewed_price_updates update_row
WHERE 1 = 1
ON CONFLICT(record_id) DO UPDATE SET
  new_price_cny = excluded.new_price_cny,
  updated_at = excluded.updated_at;

INSERT INTO product_order_state(
  record_id,
  new_price_cny,
  ordered_quantity,
  remark,
  updated_at
)
SELECT
  target.record_id,
  NULL,
  0,
  'OEM ',
  strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
FROM rollback_0018_oem_targets target
WHERE 1 = 1
ON CONFLICT(record_id) DO UPDATE SET
  remark = CASE
    WHEN product_order_state.remark = 'OEM' THEN 'OEM '
    WHEN product_order_state.remark LIKE 'OEM %' THEN product_order_state.remark
    ELSE 'OEM ' || product_order_state.remark
  END,
  updated_at = excluded.updated_at;

INSERT INTO sidi_priority_order_state(
  record_id,
  ordered_quantity,
  remark,
  updated_at
)
SELECT
  target.record_id,
  0,
  'OEM ',
  strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
FROM rollback_0018_oem_targets target
WHERE 1 = 1
ON CONFLICT(record_id) DO UPDATE SET
  remark = CASE
    WHEN sidi_priority_order_state.remark = 'OEM' THEN 'OEM '
    WHEN sidi_priority_order_state.remark LIKE 'OEM %' THEN sidi_priority_order_state.remark
    ELSE 'OEM ' || sidi_priority_order_state.remark
  END,
  updated_at = excluded.updated_at;
