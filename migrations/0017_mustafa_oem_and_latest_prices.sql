PRAGMA foreign_keys = ON;

CREATE TABLE rollback_0017_oem_codes (
  product_code TEXT PRIMARY KEY
);

INSERT INTO rollback_0017_oem_codes(product_code) VALUES
  ('12100-A61-PTSY-A'),
  ('22300-F6A-XS-SYM'),
  ('31120-F8-HCE-8'),
  ('42611-3J3-PT');

CREATE TABLE rollback_0017_price_map (
  product_code TEXT PRIMARY KEY,
  new_price_cny REAL NOT NULL,
  source_row INTEGER NOT NULL
);

INSERT INTO rollback_0017_price_map(product_code, new_price_cny, source_row) VALUES
  ('11100-ARA-PT', 80, 6),
  ('11210-FID150-PT', 7, 271),
  ('11210-VMS-PT', 10, 270),
  ('12100-A61-PTSY-A', 53, 15),
  ('12100-YMH100-51-PT', 60, 21),
  ('1210A-3K3-PT', 80, 8),
  ('1210A-ZF150-WYZC', 58, 7),
  ('12200-ANL-PT', 100, 22),
  ('12209-H6B-FC', 0.25, 256),
  ('1225A-A31-PT', 1.5, 24),
  ('1225A-GR150-PT', 3, 19),
  ('13000-HHA-PT', 90, 26),
  ('13010-A6A-PTSY', 14, 29),
  ('13011-FID150-PT', 4, 31),
  ('13101-A61-PT', 12, 28),
  ('13101-FID150-FC', 8, 32),
  ('14401-F6C-HJ', 10, 34),
  ('14401-KV7-HJ', 10, 35),
  ('14401-V02-HJ', 10, 36),
  ('14711-ADB-PT', 7, 41),
  ('14711-F8A-PT', 7, 42),
  ('1471A-F6A-PT', 6, 43),
  ('14721-GY6-FC', 5, 44),
  ('15100-ATA-PT', 15, 46),
  ('15100-F6C-PT', 10, 45),
  ('15100-KUDU-FC', 4.2, 47),
  ('1610K-ASC-PT', 125, 50),
  ('1610K-FID150-FC', 48, 51),
  ('1610K-YMH100-FTK', 60.5, 52),
  ('16510-PAG-AF', 5, 55),
  ('16510-RK2-PT', 4, 57),
  ('17211-CJY-PT', 4, 59),
  ('17211-GEM-PT', 4.6, 58),
  ('17211-H6B-PTDC', 7.5, 60),
  ('17211-TMAX500-ZT', 6, 61),
  ('17910-ABA-PT', 4.5, 65),
  ('17910-FY100-ZC', 4.5, 66),
  ('17910-SM-F8-PT', 4.5, 67),
  ('22121-FIDDLE-HM-SQ', 6.5, 77),
  ('22121-YMH100-SQ', 5, 79),
  ('22300-F6A-XS-SYM', 78, 85),
  ('22300-FY100-FYMH-NW', 22, 83),
  ('30700-SPN-PT', 1.6, 100),
  ('31120-F6N-XD', 35, 103),
  ('31120-F8-HCE-8', 34, 101),
  ('31120-X1A-XD', 35, 102),
  ('31209-KCW100-FC', 14, 113),
  ('3120A-ARA-PT', 30, 104),
  ('31210-FX100-ZF', 29, 106),
  ('3121A-FID-ZF', 25, 105),
  ('33100-APA-PT', 44, 114),
  ('35010-CRL-PT', 22, 126),
  ('35010-F6C-PT', 22, 124),
  ('35010-XRA-PT', 21, 127),
  ('3501A-ABA-PT', 21, 128),
  ('35100-GH-HT-YA', 16, 125),
  ('42601-ASC-PT', 60, 133),
  ('42601-X3A-PT', 145, 135),
  ('42601-X9A-PT', 150, 136),
  ('42611-3J3-PT', 1.8, 137),
  ('42650-FX100-LMP-18T', 34, 138),
  ('42650-FX100-LMP19T', 34, 145),
  ('42650-N10-PT', 146, 134),
  ('43105-6-ARB-XS-SYM', 9.2, 285),
  ('43105-ARB-ZFZK', 2.8, 164),
  ('43120-ZY-FYMH', 5, 146),
  ('44301-AAA-PT', 3.2, 156),
  ('44650-FX100-L-LMP', 36, 144),
  ('45105-FA140-PTHJ', 3.65, 163),
  ('45105-LFC2-FA305-PTA', 3, 171),
  ('45120-CM125-FC', 3.65, 165),
  ('45120-FKCW-FA888', 2.7, 166),
  ('45120-GS125-FC-YS', 3, 172),
  ('45126-93-PT', 10, 155),
  ('45150-APA-ZFZK', 3, 168),
  ('45150-FA298-FC', 3.2, 169),
  ('45150-L9H-FCYS3007', 3, 170),
  ('50110-GY6-FC-A', 655, 187),
  ('51350-FX100-ZF', 55, 202),
  ('51400-ALA-PTZC', 85, 203),
  ('51400-APA-PT-BL', 85, 204),
  ('51400-F8-XH', 98, 205),
  ('51400-JOG-JC', 67, 206),
  ('52400-ABA-PT', 30, 210),
  ('52400-AR1-PT-BL', 25, 207),
  ('52400-D340-PT', 25, 212),
  ('52400-N9-PT', 35, 209),
  ('52400-S6-PT', 19, 211),
  ('52400-VMS-PT-B', 26, 208),
  ('53100-S5-PT', 20, 231),
  ('53100-S9-PT', 23, 232),
  ('53270-ALA-34CM-PT', 15, 234),
  ('53270-XPA-PT', 44, 239),
  ('53270-XPA-PT50CM', 40, 237),
  ('83710-VMAX-PT', 8, 249),
  ('90304-XJA-PT', 1, 251),
  ('90911-6200-FC', 3, 276),
  ('90912-6201-FC', 1.2, 260),
  ('91201-HHA-FC', 6, 255),
  ('91205-FX100-ZC', 1, 277),
  ('91206-26_48_7-FC', 1, 278),
  ('9580A-06095-06100-06030', 4.5, 254),
  ('96100-62030-AOF', 2, 279),
  ('96100-62040-AOF', 2, 280),
  ('96100-6303-AOF', 3, 259),
  ('98056-10MM-HONDA', 1.9, 258);

CREATE TABLE rollback_0017_target_records AS
SELECT
  p.record_id,
  p.product_code_normalized AS product_code,
  CASE WHEN o.product_code IS NULL THEN 0 ELSE 1 END AS is_oem,
  prices.new_price_cny
FROM products p
LEFT JOIN rollback_0017_oem_codes o
  ON o.product_code = p.product_code_normalized
LEFT JOIN rollback_0017_price_map prices
  ON prices.product_code = p.product_code_normalized
WHERE o.product_code IS NOT NULL OR prices.product_code IS NOT NULL;

CREATE TABLE rollback_0017_primary_order_state AS
SELECT state.*
FROM product_order_state state
JOIN rollback_0017_target_records target
  ON target.record_id = state.record_id;

CREATE TABLE rollback_0017_priority_order_state AS
SELECT state.*
FROM sidi_priority_order_state state
JOIN rollback_0017_target_records target
  ON target.record_id = state.record_id
WHERE target.is_oem = 1;

INSERT INTO product_order_state(
  record_id,
  new_price_cny,
  ordered_quantity,
  remark,
  updated_at
)
SELECT
  target.record_id,
  target.new_price_cny,
  0,
  '',
  strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
FROM rollback_0017_target_records target
WHERE target.new_price_cny IS NOT NULL
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
FROM rollback_0017_target_records target
WHERE target.is_oem = 1
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
FROM rollback_0017_target_records target
WHERE target.is_oem = 1
ON CONFLICT(record_id) DO UPDATE SET
  remark = CASE
    WHEN sidi_priority_order_state.remark = 'OEM' THEN 'OEM '
    WHEN sidi_priority_order_state.remark LIKE 'OEM %' THEN sidi_priority_order_state.remark
    ELSE 'OEM ' || sidi_priority_order_state.remark
  END,
  updated_at = excluded.updated_at;

