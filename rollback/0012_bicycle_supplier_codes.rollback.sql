PRAGMA foreign_keys = ON;

UPDATE category_products
SET fields_fr_json = (
      SELECT previous.fields_fr_json
      FROM rollback_0012_bicycle_supplier_codes previous
      WHERE previous.category_id = category_products.category_id
        AND previous.record_id = category_products.record_id
    ),
    fields_zh_json = (
      SELECT previous.fields_zh_json
      FROM rollback_0012_bicycle_supplier_codes previous
      WHERE previous.category_id = category_products.category_id
        AND previous.record_id = category_products.record_id
    ),
    search_fr = (
      SELECT previous.search_fr
      FROM rollback_0012_bicycle_supplier_codes previous
      WHERE previous.category_id = category_products.category_id
        AND previous.record_id = category_products.record_id
    ),
    search_zh = (
      SELECT previous.search_zh
      FROM rollback_0012_bicycle_supplier_codes previous
      WHERE previous.category_id = category_products.category_id
        AND previous.record_id = category_products.record_id
    )
WHERE category_id = 'devis-sur-demande'
  AND record_id IN (
    SELECT record_id
    FROM rollback_0012_bicycle_supplier_codes
    WHERE category_id = 'devis-sur-demande'
  );

DROP TABLE rollback_0012_bicycle_supplier_codes;
