PRAGMA foreign_keys = ON;

DELETE FROM products
WHERE record_id IN (
  SELECT record_id
  FROM category_products
  WHERE category_id = 'devis-sur-demande'
);

UPDATE categories
SET display_template = (SELECT display_template FROM rollback_0007_bicycle_category),
    currency = (SELECT currency FROM rollback_0007_bicycle_category),
    intro_fr = (SELECT intro_fr FROM rollback_0007_bicycle_category),
    intro_zh = (SELECT intro_zh FROM rollback_0007_bicycle_category),
    columns_fr_json = (SELECT columns_fr_json FROM rollback_0007_bicycle_category),
    columns_zh_json = (SELECT columns_zh_json FROM rollback_0007_bicycle_category)
WHERE id = 'devis-sur-demande';

INSERT INTO products(
  record_id, product_code, product_code_normalized, unit_price_cny, price_basis,
  sales_unit_code, sales_unit_fr, sales_unit_zh, unit_weight_kg,
  unit_weight_source, source_kind, created_at, updated_at
)
SELECT
  record_id, product_code, product_code_normalized, unit_price_cny, price_basis,
  sales_unit_code, sales_unit_fr, sales_unit_zh, unit_weight_kg,
  unit_weight_source, source_kind, created_at, updated_at
FROM rollback_0007_bicycle_products;

INSERT INTO category_products(
  category_id, record_id, sort_order, source_row,
  fields_fr_json, fields_zh_json, search_fr, search_zh
)
SELECT
  category_id, record_id, sort_order, source_row,
  fields_fr_json, fields_zh_json, search_fr, search_zh
FROM rollback_0007_bicycle_category_products;

INSERT INTO product_order_state(record_id, ordered_quantity, remark, updated_at, new_price_cny)
SELECT record_id, ordered_quantity, remark, updated_at, new_price_cny
FROM rollback_0007_bicycle_order_state;

INSERT INTO sidi_priority_order_state(record_id, ordered_quantity, remark, updated_at)
SELECT record_id, ordered_quantity, remark, updated_at
FROM rollback_0007_bicycle_priority_state;

DROP TABLE rollback_0007_bicycle_priority_state;
DROP TABLE rollback_0007_bicycle_order_state;
DROP TABLE rollback_0007_bicycle_category_products;
DROP TABLE rollback_0007_bicycle_products;
DROP TABLE rollback_0007_bicycle_category;
