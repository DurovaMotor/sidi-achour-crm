PRAGMA foreign_keys = ON;

CREATE TABLE rollback_0013_djj_outer_products AS
SELECT p.*
FROM products p
WHERE p.record_id IN (
  'bicycle-outer-42710-20-1-75-djj',
  'bicycle-outer-42710-24-1-75-djj',
  'bicycle-outer-42710-26-1-75-djj'
);
CREATE TABLE rollback_0013_djj_outer_category_products AS
SELECT cp.*
FROM category_products cp
WHERE cp.record_id IN (
  'bicycle-outer-42710-20-1-75-djj',
  'bicycle-outer-42710-24-1-75-djj',
  'bicycle-outer-42710-26-1-75-djj'
);

CREATE TABLE rollback_0013_djj_outer_images AS
SELECT image.*
FROM product_images image
WHERE image.record_id IN (
  'bicycle-outer-42710-20-1-75-djj',
  'bicycle-outer-42710-24-1-75-djj',
  'bicycle-outer-42710-26-1-75-djj'
);

CREATE TABLE rollback_0013_djj_outer_order_state AS
SELECT state.*
FROM product_order_state state
WHERE state.record_id IN (
  'bicycle-outer-42710-20-1-75-djj',
  'bicycle-outer-42710-24-1-75-djj',
  'bicycle-outer-42710-26-1-75-djj'
);

CREATE TABLE rollback_0013_djj_outer_priority_state AS
SELECT state.*
FROM sidi_priority_order_state state
WHERE state.record_id IN (
  'bicycle-outer-42710-20-1-75-djj',
  'bicycle-outer-42710-24-1-75-djj',
  'bicycle-outer-42710-26-1-75-djj'
);

DELETE FROM products
WHERE record_id IN (
  'bicycle-outer-42710-20-1-75-djj',
  'bicycle-outer-42710-24-1-75-djj',
  'bicycle-outer-42710-26-1-75-djj'
);
