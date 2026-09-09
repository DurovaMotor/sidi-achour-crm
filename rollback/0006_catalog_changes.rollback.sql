UPDATE category_products
SET fields_fr_json = (
      SELECT b.fields_fr_json FROM rollback_0006_tire_fields b
      WHERE b.record_id = category_products.record_id
    ),
    fields_zh_json = (
      SELECT b.fields_zh_json FROM rollback_0006_tire_fields b
      WHERE b.record_id = category_products.record_id
    ),
    search_fr = (
      SELECT b.search_fr FROM rollback_0006_tire_fields b
      WHERE b.record_id = category_products.record_id
    ),
    search_zh = (
      SELECT b.search_zh FROM rollback_0006_tire_fields b
      WHERE b.record_id = category_products.record_id
    )
WHERE category_id = 'pneumatiques'
  AND record_id IN (SELECT record_id FROM rollback_0006_tire_fields);

DELETE FROM catalog_change_provenance
WHERE change_id = '0006-pneumatiques-47-remarks';

DROP TABLE rollback_0006_tire_fields;

-- The additive products and Sidi priority table intentionally remain in place.
-- This preserves any order or priority data entered after release. Use the full
-- pre-migration D1 export only when a complete database restore is required.
