PRAGMA foreign_keys = ON;

UPDATE category_products
SET sort_order = (
  SELECT previous.sort_order
  FROM rollback_0011_bicycle_sort_order previous
  WHERE previous.category_id = category_products.category_id
    AND previous.record_id = category_products.record_id
)
WHERE category_id = 'devis-sur-demande'
  AND record_id IN (
    SELECT record_id
    FROM rollback_0011_bicycle_sort_order
    WHERE category_id = 'devis-sur-demande'
  );

DROP TABLE rollback_0011_bicycle_sort_order;
