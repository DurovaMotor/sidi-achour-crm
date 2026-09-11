PRAGMA foreign_keys = ON;

CREATE TABLE rollback_0010_bicycle_product_codes (
  category_id TEXT NOT NULL,
  record_id TEXT NOT NULL,
  product_code TEXT,
  product_code_normalized TEXT,
  fields_fr_json TEXT NOT NULL,
  fields_zh_json TEXT NOT NULL,
  search_fr TEXT NOT NULL,
  search_zh TEXT NOT NULL,
  PRIMARY KEY (category_id, record_id)
);

INSERT INTO rollback_0010_bicycle_product_codes(
  category_id, record_id, product_code, product_code_normalized,
  fields_fr_json, fields_zh_json, search_fr, search_zh
)
SELECT
  cp.category_id, p.record_id, p.product_code, p.product_code_normalized,
  cp.fields_fr_json, cp.fields_zh_json, cp.search_fr, cp.search_zh
FROM category_products cp
JOIN products p ON p.record_id = cp.record_id
WHERE cp.category_id = 'devis-sur-demande';

CREATE TABLE migration_0010_bicycle_product_codes (
  record_id TEXT PRIMARY KEY,
  next_product_code TEXT NOT NULL
);

INSERT INTO migration_0010_bicycle_product_codes(record_id, next_product_code)
SELECT
  p.record_id,
  p.product_code || CASE
    WHEN p.record_id LIKE 'bicycle-outer-%' THEN '-WT'
    WHEN p.record_id LIKE 'bicycle-inner-a-%' THEN '-A'
    WHEN p.record_id LIKE 'bicycle-inner-b-%' THEN '-B'
  END
FROM category_products cp
JOIN products p ON p.record_id = cp.record_id
WHERE cp.category_id = 'devis-sur-demande'
  AND (
    p.record_id LIKE 'bicycle-outer-%'
    OR p.record_id LIKE 'bicycle-inner-a-%'
    OR p.record_id LIKE 'bicycle-inner-b-%'
  );

UPDATE category_products
SET fields_fr_json = json_set(
      fields_fr_json,
      '$.reference',
      (SELECT mapping.next_product_code
       FROM migration_0010_bicycle_product_codes mapping
       WHERE mapping.record_id = category_products.record_id)
    ),
    fields_zh_json = json_set(
      fields_zh_json,
      '$.reference',
      (SELECT mapping.next_product_code
       FROM migration_0010_bicycle_product_codes mapping
       WHERE mapping.record_id = category_products.record_id)
    ),
    search_fr = replace(
      search_fr,
      json_extract(fields_fr_json, '$.reference'),
      (SELECT mapping.next_product_code
       FROM migration_0010_bicycle_product_codes mapping
       WHERE mapping.record_id = category_products.record_id)
    ),
    search_zh = replace(
      search_zh,
      json_extract(fields_zh_json, '$.reference'),
      (SELECT mapping.next_product_code
       FROM migration_0010_bicycle_product_codes mapping
       WHERE mapping.record_id = category_products.record_id)
    )
WHERE category_id = 'devis-sur-demande'
  AND record_id IN (SELECT record_id FROM migration_0010_bicycle_product_codes);

UPDATE products
SET product_code = (
      SELECT mapping.next_product_code
      FROM migration_0010_bicycle_product_codes mapping
      WHERE mapping.record_id = products.record_id
    ),
    product_code_normalized = upper(
      (SELECT mapping.next_product_code
       FROM migration_0010_bicycle_product_codes mapping
       WHERE mapping.record_id = products.record_id)
    ),
    updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE record_id IN (SELECT record_id FROM migration_0010_bicycle_product_codes);

DROP TABLE migration_0010_bicycle_product_codes;
