CREATE TABLE sidi_priority_order_state (
  record_id TEXT PRIMARY KEY REFERENCES products(record_id) ON DELETE CASCADE,
  ordered_quantity REAL NOT NULL DEFAULT 0 CHECK (ordered_quantity >= 0),
  remark TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE VIEW v_sidi_priority_category_stats AS
WITH
order_totals AS (
  SELECT
    cp.category_id,
    SUM(COALESCE(priority.ordered_quantity, 0)) AS ordered_quantity_raw,
    SUM(
      CASE WHEN p.unit_weight_kg IS NOT NULL
        THEN COALESCE(priority.ordered_quantity, 0) * p.unit_weight_kg
        ELSE 0
      END
    ) AS ordered_weight_kg_known,
    SUM(COALESCE(priority.ordered_quantity, 0) * COALESCE(price.new_price_cny, p.unit_price_cny, 0)) AS ordered_amount_cny,
    SUM(
      CASE WHEN COALESCE(priority.ordered_quantity, 0) > 0
                  AND p.unit_weight_kg IS NULL THEN 1 ELSE 0 END
    ) AS ordered_lines_missing_weight,
    SUM(
      CASE WHEN COALESCE(priority.ordered_quantity, 0) > 0
                  AND COALESCE(price.new_price_cny, p.unit_price_cny) IS NULL THEN 1 ELSE 0 END
    ) AS ordered_lines_missing_price
  FROM category_products cp
  JOIN products p ON p.record_id = cp.record_id
  LEFT JOIN sidi_priority_order_state priority ON priority.record_id = p.record_id
  LEFT JOIN product_order_state price ON price.record_id = p.record_id
  GROUP BY cp.category_id
),
quota_totals AS (
  SELECT
    category_id,
    SUM(requested_quantity) AS quota_quantity,
    MIN(quota_unit_code) AS quota_unit_code,
    COUNT(DISTINCT quota_unit_code) AS quota_unit_count,
    SUM(quota_value_usd) AS quota_value_usd,
    SUM(quota_value_usd * fx_rate_usd_cny_snapshot) AS quota_value_cny_snapshot
  FROM category_quotas
  GROUP BY category_id
),
rate AS (
  SELECT CAST(value AS REAL) AS usd_cny_rate
  FROM app_settings
  WHERE key = 'usd_cny_rate'
)
SELECT
  c.id AS category_id,
  c.quantity_mode,
  CASE c.quantity_mode
    WHEN 'weight_kg' THEN COALESCE(o.ordered_weight_kg_known, 0)
    ELSE COALESCE(o.ordered_quantity_raw, 0)
  END AS ordered_quantity,
  COALESCE(o.ordered_quantity_raw, 0) AS ordered_quantity_raw,
  COALESCE(o.ordered_weight_kg_known, 0) AS ordered_weight_kg_known,
  COALESCE(q.quota_quantity, 0) AS quota_quantity,
  q.quota_unit_code,
  COALESCE(o.ordered_amount_cny, 0) AS ordered_amount_cny,
  COALESCE(q.quota_value_usd, 0) AS quota_value_usd,
  COALESCE(q.quota_value_usd, 0) * rate.usd_cny_rate AS quota_value_cny,
  q.quota_value_cny_snapshot,
  rate.usd_cny_rate,
  COALESCE(o.ordered_lines_missing_weight, 0) AS ordered_lines_missing_weight,
  COALESCE(o.ordered_lines_missing_price, 0) AS ordered_lines_missing_price,
  COALESCE(q.quota_unit_count, 0) AS quota_unit_count
FROM categories c
LEFT JOIN order_totals o ON o.category_id = c.id
LEFT JOIN quota_totals q ON q.category_id = c.id
CROSS JOIN rate;

CREATE TABLE rollback_0006_tire_fields (
  record_id TEXT PRIMARY KEY,
  fields_fr_json TEXT NOT NULL,
  fields_zh_json TEXT NOT NULL,
  search_fr TEXT NOT NULL,
  search_zh TEXT NOT NULL
);

INSERT INTO rollback_0006_tire_fields(record_id, fields_fr_json, fields_zh_json, search_fr, search_zh)
SELECT record_id, fields_fr_json, fields_zh_json, search_fr, search_zh
FROM category_products
WHERE category_id = 'pneumatiques' AND record_id = 'pneumatiques-47';

CREATE TABLE catalog_change_provenance (
  change_id TEXT PRIMARY KEY,
  record_id TEXT NOT NULL REFERENCES products(record_id) ON DELETE CASCADE,
  field_name TEXT NOT NULL,
  previous_value TEXT,
  next_value TEXT NOT NULL,
  source TEXT NOT NULL,
  changed_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

INSERT INTO catalog_change_provenance(change_id, record_id, field_name, previous_value, next_value, source)
SELECT
  '0006-pneumatiques-47-remarks',
  record_id,
  'remarks',
  json_extract(fields_fr_json, '$.remarks'),
  'B0553: tubeless tire 49; standard tire 42.',
  'user_request_2026-09-09'
FROM category_products
WHERE category_id = 'pneumatiques' AND record_id = 'pneumatiques-47';

UPDATE category_products
SET fields_fr_json = json_set(fields_fr_json, '$.remarks', 'B0553: tubeless tire 49; standard tire 42.'),
    fields_zh_json = json_set(fields_zh_json, '$.remarks', 'B0553: tubeless tire 49; standard tire 42.'),
    search_fr = replace(search_fr, 'B0553: tubeless tire 44; standard tire 37.', 'B0553: tubeless tire 49; standard tire 42.'),
    search_zh = replace(search_zh, 'B0553: tubeless tire 44; standard tire 37.', 'B0553: tubeless tire 49; standard tire 42.')
WHERE category_id = 'pneumatiques' AND record_id = 'pneumatiques-47';

CREATE TABLE catalog_product_provenance (
  record_id TEXT PRIMARY KEY REFERENCES products(record_id) ON DELETE CASCADE,
  transcription_workbook TEXT NOT NULL,
  transcription_sheet TEXT NOT NULL,
  transcription_row INTEGER NOT NULL,
  source_workbook TEXT NOT NULL,
  source_sheet TEXT NOT NULL,
  source_row INTEGER NOT NULL,
  price_source_column TEXT NOT NULL,
  source_latest_price_cny REAL NOT NULL,
  source_latest_price_at TEXT,
  imported_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

INSERT INTO products(record_id, product_code, product_code_normalized, unit_price_cny, price_basis, sales_unit_code, sales_unit_fr, sales_unit_zh, unit_weight_kg, unit_weight_source, source_kind) VALUES
  ('chambres-a-air-10', '42170-24-1.75-1.95-FC', '42170-24-1.75-1.95-FC', 4.5, 'unit', 'unit', 'pièce', '个', 0.26, 'carton_derived', 'excel'),
  ('chambres-a-air-11', '42170-26-1.75-1.95-FC', '42170-26-1.75-1.95-FC', 4.6, 'unit', 'unit', 'pièce', '个', 0.28, 'carton_derived', 'excel');

INSERT INTO category_products(category_id, record_id, sort_order, source_row, fields_fr_json, fields_zh_json, search_fr, search_zh) VALUES
  ('chambres-a-air', 'chambres-a-air-10', 4, 654,
   '{"reference":"42170-24-1.75-1.95-FC","designation":"24*1.75-1.95\nINNER TUBE","compatibleModels":"ALL","specification":"24*1.75-1.95","unit":"pièce","salePriceCny":4.5,"unitsPerCarton":100,"weightKg":26,"cartonDimensionsCm":"3 × 100 × 100","volumeM3":null,"description":null}',
   '{"reference":"42170-24-1.75-1.95-FC","designation":"24*1.75-1.95内胎","compatibleModels":"ALL","specification":"24*1.75-1.95","unit":"个","salePriceCny":4.5,"unitsPerCarton":100,"weightKg":26,"cartonDimensionsCm":"3 × 100 × 100","volumeM3":null,"description":null}',
   '42170-24-1.75-1.95-FC 24*1.75-1.95 INNER TUBE ALL 24*1.75-1.95 pièce 4.5 100 26 3 × 100 × 100',
   '42170-24-1.75-1.95-FC 24*1.75-1.95内胎 ALL 24*1.75-1.95 个 4.5 100 26 3 × 100 × 100'),
  ('chambres-a-air', 'chambres-a-air-11', 5, 655,
   '{"reference":"42170-26-1.75-1.95-FC","designation":"26*1.75-1.95\nINNER TUBE","compatibleModels":"ALL","specification":"26*1.75-1.95","unit":"pièce","salePriceCny":4.6,"unitsPerCarton":100,"weightKg":28,"cartonDimensionsCm":"3.3333 × 100 × 100","volumeM3":null,"description":null}',
   '{"reference":"42170-26-1.75-1.95-FC","designation":"26*1.75-1.95内胎","compatibleModels":"ALL","specification":"26*1.75-1.95","unit":"个","salePriceCny":4.6,"unitsPerCarton":100,"weightKg":28,"cartonDimensionsCm":"3.3333 × 100 × 100","volumeM3":null,"description":null}',
   '42170-26-1.75-1.95-FC 26*1.75-1.95 INNER TUBE ALL 26*1.75-1.95 pièce 4.6 100 28 3.3333 × 100 × 100',
   '42170-26-1.75-1.95-FC 26*1.75-1.95内胎 ALL 26*1.75-1.95 个 4.6 100 28 3.3333 × 100 × 100');

INSERT INTO catalog_product_provenance(record_id, transcription_workbook, transcription_sheet, transcription_row, source_workbook, source_sheet, source_row, price_source_column, source_latest_price_cny, source_latest_price_at) VALUES
  ('chambres-a-air-10', '产品编码转录.xlsx', '产品编码', 2, '产品数据库.xlsx', 'sheet1', 654, 'K', 4.5, '2026-08-22T14:17:33+08:00'),
  ('chambres-a-air-11', '产品编码转录.xlsx', '产品编码', 3, '产品数据库.xlsx', 'sheet1', 655, 'K', 4.6, '2026-08-22T14:17:33+08:00');

INSERT INTO product_weight_provenance(record_id, match_method, source_workbook, source_sheet, source_row, source_product_code, source_product_name_zh, gross_weight_kg, units_per_carton, unit_weight_kg, name_similarity_score, source_in_license, source_code_contains_sym) VALUES
  ('chambres-a-air-10', 'exact_code', '产品数据库.xlsx', 'sheet1', 654, '42170-24-1.75-1.95-FC', '24*1.75-1.95内胎', 26, 100, 0.26, 1, 1, 0),
  ('chambres-a-air-11', 'exact_code', '产品数据库.xlsx', 'sheet1', 655, '42170-26-1.75-1.95-FC', '26*1.75-1.95内胎', 28, 100, 0.28, 1, 1, 0);

INSERT INTO product_images(id, record_id, r2_key, source, is_primary, width, height, bytes, sha256, alt_fr, alt_zh, sort_order) VALUES
  ('img_0006_inner_tube_24', 'chambres-a-air-10', 'catalog/v1/jiandaoyun/jdy-df076ecf49e60b49b5.webp', 'jiandaoyun', 1, 414, 414, 20944, 'df076ecf49e60b49b5cc6dbae8dc3449f3f0b3ab6f54b34252077739ef17bce5', '42170-24-1.75-1.95-FC', '42170-24-1.75-1.95-FC', 0),
  ('img_0006_inner_tube_26', 'chambres-a-air-11', 'catalog/v1/jiandaoyun/jdy-df076ecf49e60b49b5.webp', 'jiandaoyun', 1, 414, 414, 20944, 'df076ecf49e60b49b5cc6dbae8dc3449f3f0b3ab6f54b34252077739ef17bce5', '42170-26-1.75-1.95-FC', '42170-26-1.75-1.95-FC', 0);
