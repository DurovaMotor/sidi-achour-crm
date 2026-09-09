UPDATE category_products
SET fields_fr_json = (
      SELECT b.fields_fr_json FROM rollback_0004_tire_fields b
      WHERE b.record_id = category_products.record_id
    ),
    fields_zh_json = (
      SELECT b.fields_zh_json FROM rollback_0004_tire_fields b
      WHERE b.record_id = category_products.record_id
    )
WHERE category_id = 'pneumatiques'
  AND record_id IN (SELECT record_id FROM rollback_0004_tire_fields);

DROP TABLE tire_remarks_provenance;
DROP TABLE rollback_0004_tire_fields;
