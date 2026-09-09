UPDATE products
SET unit_weight_kg = (
      SELECT b.unit_weight_kg FROM rollback_0003_product_weights b
      WHERE b.record_id = products.record_id
    ),
    unit_weight_source = (
      SELECT b.unit_weight_source FROM rollback_0003_product_weights b
      WHERE b.record_id = products.record_id
    ),
    updated_at = (
      SELECT b.updated_at FROM rollback_0003_product_weights b
      WHERE b.record_id = products.record_id
    )
WHERE record_id IN (SELECT record_id FROM rollback_0003_product_weights);

UPDATE categories
SET quantity_mode = (
  SELECT b.quantity_mode FROM rollback_0003_category_modes b
  WHERE b.id = categories.id
)
WHERE id IN (SELECT id FROM rollback_0003_category_modes);

DROP TABLE product_weight_provenance;
DROP TABLE rollback_0003_product_weights;
DROP TABLE rollback_0003_category_modes;
