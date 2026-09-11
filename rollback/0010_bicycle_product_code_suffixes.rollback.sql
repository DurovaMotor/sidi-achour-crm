PRAGMA foreign_keys = ON;

UPDATE category_products
SET fields_fr_json = (
      SELECT previous.fields_fr_json
      FROM rollback_0010_bicycle_product_codes previous
      WHERE previous.category_id = category_products.category_id
        AND previous.record_id = category_products.record_id
    ),
    fields_zh_json = (
      SELECT previous.fields_zh_json
      FROM rollback_0010_bicycle_product_codes previous
      WHERE previous.category_id = category_products.category_id
        AND previous.record_id = category_products.record_id
    ),
    search_fr = (
      SELECT previous.search_fr
      FROM rollback_0010_bicycle_product_codes previous
      WHERE previous.category_id = category_products.category_id
        AND previous.record_id = category_products.record_id
    ),
    search_zh = (
      SELECT previous.search_zh
      FROM rollback_0010_bicycle_product_codes previous
      WHERE previous.category_id = category_products.category_id
        AND previous.record_id = category_products.record_id
    )
WHERE category_id = 'devis-sur-demande'
  AND record_id IN (
    SELECT record_id
    FROM rollback_0010_bicycle_product_codes
    WHERE category_id = 'devis-sur-demande'
  );

UPDATE products
SET product_code = (
      SELECT previous.product_code
      FROM rollback_0010_bicycle_product_codes previous
      WHERE previous.record_id = products.record_id
    ),
    product_code_normalized = (
      SELECT previous.product_code_normalized
      FROM rollback_0010_bicycle_product_codes previous
      WHERE previous.record_id = products.record_id
    ),
    updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE record_id IN (SELECT record_id FROM rollback_0010_bicycle_product_codes);

DROP TABLE rollback_0010_bicycle_product_codes;
