PRAGMA foreign_keys = ON;

CREATE TABLE rollback_0012_bicycle_supplier_codes (
  category_id TEXT NOT NULL,
  record_id TEXT NOT NULL,
  fields_fr_json TEXT NOT NULL,
  fields_zh_json TEXT NOT NULL,
  search_fr TEXT NOT NULL,
  search_zh TEXT NOT NULL,
  PRIMARY KEY (category_id, record_id)
);

INSERT INTO rollback_0012_bicycle_supplier_codes(
  category_id, record_id, fields_fr_json, fields_zh_json, search_fr, search_zh
)
SELECT category_id, record_id, fields_fr_json, fields_zh_json, search_fr, search_zh
FROM category_products
WHERE category_id = 'devis-sur-demande';

CREATE TABLE migration_0012_bicycle_supplier_codes (
  record_id TEXT PRIMARY KEY,
  supplier_code TEXT NOT NULL
);

INSERT INTO migration_0012_bicycle_supplier_codes(record_id, supplier_code)
SELECT
  record_id,
  CASE
    WHEN record_id LIKE 'bicycle-inner-a-%' THEN 'A1154'
    WHEN record_id LIKE 'bicycle-inner-b-%' OR record_id LIKE 'bicycle-outer-%' THEN 'A1155'
  END
FROM category_products
WHERE category_id = 'devis-sur-demande'
  AND (
    record_id LIKE 'bicycle-inner-a-%'
    OR record_id LIKE 'bicycle-inner-b-%'
    OR record_id LIKE 'bicycle-outer-%'
  );

UPDATE category_products
SET fields_fr_json = json_set(
      fields_fr_json,
      '$.compatibleModels',
      (SELECT mapping.supplier_code
       FROM migration_0012_bicycle_supplier_codes mapping
       WHERE mapping.record_id = category_products.record_id)
    ),
    fields_zh_json = json_set(
      fields_zh_json,
      '$.compatibleModels',
      (SELECT mapping.supplier_code
       FROM migration_0012_bicycle_supplier_codes mapping
       WHERE mapping.record_id = category_products.record_id)
    ),
    search_fr = trim(
      COALESCE(json_extract(fields_fr_json, '$.reference'), '') || ' ' ||
      COALESCE(json_extract(fields_fr_json, '$.designation'), '') || ' ' ||
      (SELECT mapping.supplier_code
       FROM migration_0012_bicycle_supplier_codes mapping
       WHERE mapping.record_id = category_products.record_id) || ' ' ||
      COALESCE(json_extract(fields_fr_json, '$.specification'), '') || ' ' ||
      COALESCE(json_extract(fields_fr_json, '$.unit'), '') || ' ' ||
      COALESCE(json_extract(fields_fr_json, '$.salePriceCny'), '') || ' ' ||
      COALESCE(json_extract(fields_fr_json, '$.description'), '')
    ),
    search_zh = trim(
      COALESCE(json_extract(fields_zh_json, '$.reference'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.designation'), '') || ' ' ||
      (SELECT mapping.supplier_code
       FROM migration_0012_bicycle_supplier_codes mapping
       WHERE mapping.record_id = category_products.record_id) || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.specification'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.unit'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.salePriceCny'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.description'), '')
    )
WHERE category_id = 'devis-sur-demande'
  AND record_id IN (SELECT record_id FROM migration_0012_bicycle_supplier_codes);

DROP TABLE migration_0012_bicycle_supplier_codes;
