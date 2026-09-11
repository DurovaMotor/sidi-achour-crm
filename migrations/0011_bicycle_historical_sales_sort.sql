PRAGMA foreign_keys = ON;

-- Source order follows the matching rows in 自行车轮胎历史销量_合并去售价.xlsx.
-- Same-size 42710 groups are placed directly after their exact 42170 matches.
CREATE TABLE rollback_0011_bicycle_sort_order (
  category_id TEXT NOT NULL,
  record_id TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  PRIMARY KEY (category_id, record_id)
);

INSERT INTO rollback_0011_bicycle_sort_order(category_id, record_id, sort_order)
SELECT category_id, record_id, sort_order
FROM category_products
WHERE category_id = 'devis-sur-demande';

CREATE TABLE migration_0011_bicycle_sort_order (
  record_id TEXT PRIMARY KEY,
  sort_order INTEGER NOT NULL UNIQUE
);

INSERT INTO migration_0011_bicycle_sort_order(record_id, sort_order) VALUES
  ('bicycle-outer-42170-26-1-75-fc', 0),
  ('bicycle-inner-a-42170-26-1-75-fc', 1),
  ('bicycle-inner-b-42170-26-1-75-fc', 2),
  ('bicycle-outer-42710-26-1-75-djj', 3),
  ('bicycle-inner-a-42710-26-1-75-djj', 4),
  ('bicycle-inner-b-42710-26-1-75-djj', 5),
  ('bicycle-outer-42170-20-1-75-fc', 6),
  ('bicycle-inner-a-42170-20-1-75-fc', 7),
  ('bicycle-inner-b-42170-20-1-75-fc', 8),
  ('bicycle-outer-42710-20-1-75-djj', 9),
  ('bicycle-inner-a-42710-20-1-75-djj', 10),
  ('bicycle-inner-b-42710-20-1-75-djj', 11),
  ('bicycle-outer-42170-24-1-75-fc', 12),
  ('bicycle-inner-a-42170-24-1-75-fc', 13),
  ('bicycle-inner-b-42170-24-1-75-fc', 14),
  ('bicycle-outer-42710-24-1-75-djj', 15),
  ('bicycle-inner-a-42710-24-1-75-djj', 16),
  ('bicycle-inner-b-42710-24-1-75-djj', 17),
  ('bicycle-outer-42170-16-1-75-fc', 18),
  ('bicycle-inner-a-42170-16-1-75-fc', 19),
  ('bicycle-inner-b-42170-16-1-75-fc', 20),
  ('bicycle-outer-42170-27-5-2-125-fc', 21),
  ('bicycle-inner-a-42170-27-5-2-125-fc', 22),
  ('bicycle-inner-b-42170-27-5-2-125-fc', 23),
  ('bicycle-outer-42170-700x42-fc', 24),
  ('bicycle-inner-a-42170-700x42-fc', 25),
  ('bicycle-inner-b-42170-700x42-fc', 26);

UPDATE category_products
SET sort_order = (
  SELECT desired.sort_order
  FROM migration_0011_bicycle_sort_order desired
  WHERE desired.record_id = category_products.record_id
)
WHERE category_id = 'devis-sur-demande'
  AND record_id IN (SELECT record_id FROM migration_0011_bicycle_sort_order);

DROP TABLE migration_0011_bicycle_sort_order;
