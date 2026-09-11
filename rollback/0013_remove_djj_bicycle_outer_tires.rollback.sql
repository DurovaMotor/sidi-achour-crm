PRAGMA foreign_keys = ON;

INSERT INTO products(
  record_id, product_code, product_code_normalized, unit_price_cny, price_basis,
  sales_unit_code, sales_unit_fr, sales_unit_zh, unit_weight_kg,
  unit_weight_source, source_kind, created_at, updated_at
)
SELECT
  record_id, product_code, product_code_normalized, unit_price_cny, price_basis,
  sales_unit_code, sales_unit_fr, sales_unit_zh, unit_weight_kg,
  unit_weight_source, source_kind, created_at, updated_at
FROM rollback_0013_djj_outer_products;

INSERT INTO category_products(
  category_id, record_id, sort_order, source_row,
  fields_fr_json, fields_zh_json, search_fr, search_zh
)
SELECT
  category_id, record_id, sort_order, source_row,
  fields_fr_json, fields_zh_json, search_fr, search_zh
FROM rollback_0013_djj_outer_category_products;

INSERT INTO product_images(
  id, record_id, r2_key, source, is_primary, width, height,
  bytes, sha256, alt_fr, alt_zh, sort_order
)
SELECT
  id, record_id, r2_key, source, is_primary, width, height,
  bytes, sha256, alt_fr, alt_zh, sort_order
FROM rollback_0013_djj_outer_images;

INSERT INTO product_order_state(record_id, ordered_quantity, remark, updated_at, new_price_cny)
SELECT record_id, ordered_quantity, remark, updated_at, new_price_cny
FROM rollback_0013_djj_outer_order_state;

INSERT INTO sidi_priority_order_state(record_id, ordered_quantity, remark, updated_at)
SELECT record_id, ordered_quantity, remark, updated_at
FROM rollback_0013_djj_outer_priority_state;

DROP TABLE rollback_0013_djj_outer_priority_state;
DROP TABLE rollback_0013_djj_outer_order_state;
DROP TABLE rollback_0013_djj_outer_images;
DROP TABLE rollback_0013_djj_outer_category_products;
DROP TABLE rollback_0013_djj_outer_products;
