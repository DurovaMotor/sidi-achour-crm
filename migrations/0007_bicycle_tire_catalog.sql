PRAGMA foreign_keys = ON;

-- Preserve the replaced rows and category metadata for a targeted rollback.
CREATE TABLE rollback_0007_bicycle_category AS
SELECT id, display_template, currency, intro_fr, intro_zh, columns_fr_json, columns_zh_json
FROM categories
WHERE id = 'devis-sur-demande';

CREATE TABLE rollback_0007_bicycle_products AS
SELECT p.*
FROM products p
JOIN category_products cp ON cp.record_id = p.record_id
WHERE cp.category_id = 'devis-sur-demande';

CREATE TABLE rollback_0007_bicycle_category_products AS
SELECT cp.*
FROM category_products cp
WHERE cp.category_id = 'devis-sur-demande';

CREATE TABLE rollback_0007_bicycle_order_state AS
SELECT state.*
FROM product_order_state state
JOIN category_products cp ON cp.record_id = state.record_id
WHERE cp.category_id = 'devis-sur-demande';

CREATE TABLE rollback_0007_bicycle_priority_state AS
SELECT state.*
FROM sidi_priority_order_state state
JOIN category_products cp ON cp.record_id = state.record_id
WHERE cp.category_id = 'devis-sur-demande';

DELETE FROM products
WHERE record_id IN (
  SELECT record_id
  FROM category_products
  WHERE category_id = 'devis-sur-demande'
);

UPDATE categories
SET display_template = 'standardParts',
    currency = 'CNY',
    intro_fr = 'Prix en CNY hors taxes pour pneus et chambres à air de bicyclettes.',
    intro_zh = '自行车外胎和内胎报价，币种为人民币，价格不含税。',
    columns_fr_json = '[{"key":"reference","header":"Référence produit"},{"key":"designation","header":"Désignation"},{"key":"compatibleModels","header":"Modèles compatibles"},{"key":"specification","header":"Spécification"},{"key":"unit","header":"Unité"},{"key":"salePriceCny","header":"Prix de vente (CNY)"},{"key":"description","header":"Description"}]',
    columns_zh_json = '[{"key":"reference","header":"产品编码"},{"key":"designation","header":"产品名称"},{"key":"compatibleModels","header":"适用车型"},{"key":"specification","header":"规格型号"},{"key":"unit","header":"单位"},{"key":"salePriceCny","header":"销售价（人民币）"},{"key":"description","header":"备注"}]'
WHERE id = 'devis-sur-demande';

-- This transient table contains customer-facing data and final literal prices only.
CREATE TABLE migration_0007_bicycle_catalog (
  record_id TEXT PRIMARY KEY,
  product_code TEXT NOT NULL,
  price_basis TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  designation_fr TEXT NOT NULL,
  designation_zh TEXT NOT NULL,
  specification_fr TEXT NOT NULL,
  specification_zh TEXT NOT NULL,
  final_price_cny REAL NOT NULL
);

INSERT INTO migration_0007_bicycle_catalog VALUES
  ('bicycle-outer-42710-26-1-75-djj', '42710-26-1.75-DJJ', 'tire', 0, 'Pneu vélo noir 26×1,75', '26×1.75 黑色自行车外胎', '26×1,75 · pneu noir · minimum 500 pièces', '26×1.75 · 黑胎 · 起订量500条', 11.2),
  ('bicycle-outer-42710-24-1-75-djj', '42710-24-1.75-DJJ', 'tire', 1, 'Pneu vélo noir 24×1,75', '24×1.75 黑色自行车外胎', '24×1,75 · pneu noir · minimum 500 pièces', '24×1.75 · 黑胎 · 起订量500条', 10.7),
  ('bicycle-outer-42710-20-1-75-djj', '42710-20-1.75-DJJ', 'tire', 2, 'Pneu vélo noir 20×1,75', '20×1.75 黑色自行车外胎', '20×1,75 · pneu noir · minimum 500 pièces', '20×1.75 · 黑胎 · 起订量500条', 9.4),
  ('bicycle-outer-42170-16-1-75-fc', '42170-16-1.75-FC', 'tire', 3, 'Pneu vélo noir 16×1,75', '16×1.75 黑色自行车外胎', '16×1,75 · pneu noir · minimum 500 pièces', '16×1.75 · 黑胎 · 起订量500条', 8.3),
  ('bicycle-outer-42170-20-1-75-fc', '42170-20-1.75-FC', 'tire', 4, 'Pneu vélo noir 20×1,75', '20×1.75 黑色自行车外胎', '20×1,75 · pneu noir · minimum 500 pièces', '20×1.75 · 黑胎 · 起订量500条', 9.4),
  ('bicycle-outer-42170-24-1-75-fc', '42170-24-1.75-FC', 'tire', 5, 'Pneu vélo noir 24×1,75', '24×1.75 黑色自行车外胎', '24×1,75 · pneu noir · minimum 500 pièces', '24×1.75 · 黑胎 · 起订量500条', 10.7),
  ('bicycle-outer-42170-26-1-75-fc', '42170-26-1.75-FC', 'tire', 6, 'Pneu vélo noir 26×1,75', '26×1.75 黑色自行车外胎', '26×1,75 · pneu noir · minimum 500 pièces', '26×1.75 · 黑胎 · 起订量500条', 11.2),
  ('bicycle-outer-42170-27-5-2-125-fc', '42170-27.5-2.125-FC', 'tire', 7, 'Pneu vélo noir 27,5×2,125', '27.5×2.125 黑色自行车外胎', '27,5×2,125 · pneu noir · minimum 500 pièces', '27.5×2.125 · 黑胎 · 起订量500条', 14.3),
  ('bicycle-outer-42170-700x42-fc', '42170-700*42-FC', 'tire', 8, 'Pneu vélo noir 700×42', '700×42 黑色自行车外胎', '700×42 · pneu noir · minimum 500 pièces', '700×42 · 黑胎 · 起订量500条', 13.7),
  ('bicycle-inner-a-42710-26-1-75-djj', '42710-26-1.75-DJJ', 'unit', 9, 'Chambre à air vélo en butyle 26×1,75 — qualité A', '26×1.75 自行车丁基胶内胎（A质量）', '26×1,75 · valve Presta FV33 · butyle · minimum 3 000 pièces', '26×1.75 · 法嘴 FV33 · 丁基胶 · 起订量3000条', 6.7),
  ('bicycle-inner-a-42710-24-1-75-djj', '42710-24-1.75-DJJ', 'unit', 10, 'Chambre à air vélo en butyle 24×1,75 — qualité A', '24×1.75 自行车丁基胶内胎（A质量）', '24×1,75 · valve Presta FV33 · butyle · minimum 3 000 pièces', '24×1.75 · 法嘴 FV33 · 丁基胶 · 起订量3000条', 6.5),
  ('bicycle-inner-a-42710-20-1-75-djj', '42710-20-1.75-DJJ', 'unit', 11, 'Chambre à air vélo en butyle 20×1,75 — qualité A', '20×1.75 自行车丁基胶内胎（A质量）', '20×1,75 · valve Presta FV33 · butyle · minimum 3 000 pièces', '20×1.75 · 法嘴 FV33 · 丁基胶 · 起订量3000条', 6.2),
  ('bicycle-inner-a-42170-16-1-75-fc', '42170-16-1.75-FC', 'unit', 12, 'Chambre à air vélo 16×1,75 — qualité A', '16×1.75 自行车内胎（A质量）', '16×1,75 · valve Schrader · minimum 3 000 pièces', '16×1.75 · 美嘴 · 起订量3000条', 5.5),
  ('bicycle-inner-a-42170-20-1-75-fc', '42170-20-1.75-FC', 'unit', 13, 'Chambre à air vélo 20×1,75 — qualité A', '20×1.75 自行车内胎（A质量）', '20×1,75 · valve Schrader · minimum 3 000 pièces', '20×1.75 · 美嘴 · 起订量3000条', 6.0),
  ('bicycle-inner-a-42170-24-1-75-fc', '42170-24-1.75-FC', 'unit', 14, 'Chambre à air vélo 24×1,75 — qualité A', '24×1.75 自行车内胎（A质量）', '24×1,75 · valve Schrader · minimum 3 000 pièces', '24×1.75 · 美嘴 · 起订量3000条', 6.3),
  ('bicycle-inner-a-42170-26-1-75-fc', '42170-26-1.75-FC', 'unit', 15, 'Chambre à air vélo 26×1,75 — qualité A', '26×1.75 自行车内胎（A质量）', '26×1,75 · valve Schrader · minimum 3 000 pièces', '26×1.75 · 美嘴 · 起订量3000条', 6.5),
  ('bicycle-inner-a-42170-27-5-2-125-fc', '42170-27.5-2.125-FC', 'unit', 16, 'Chambre à air vélo 27,5×2,125 — qualité A', '27.5×2.125 自行车内胎（A质量）', '27,5×2,125 · valve Schrader · minimum 3 000 pièces', '27.5×2.125 · 美嘴 · 起订量3000条', 7.0),
  ('bicycle-inner-a-42170-700x42-fc', '42170-700*42-FC', 'unit', 17, 'Chambre à air vélo 700×42 — qualité A', '700×42 自行车内胎（A质量）', '700×42 · valve Schrader · minimum 3 000 pièces', '700×42 · 美嘴 · 起订量3000条', 7.1),
  ('bicycle-inner-b-42710-26-1-75-djj', '42710-26-1.75-DJJ', 'unit', 18, 'Chambre à air vélo 26×1,75 — qualité B', '26×1.75 自行车内胎（B质量）', '26×1,75 · valve Presta FV33 · section 45 mm · minimum 1 000 pièces', '26×1.75 · 法嘴 FV33 · 断面宽度45 mm · 起订量1000条', 7.1),
  ('bicycle-inner-b-42710-24-1-75-djj', '42710-24-1.75-DJJ', 'unit', 19, 'Chambre à air vélo 24×1,75 — qualité B', '24×1.75 自行车内胎（B质量）', '24×1,75 · valve Presta FV33 · section 45 mm · minimum 1 000 pièces', '24×1.75 · 法嘴 FV33 · 断面宽度45 mm · 起订量1000条', 7.0),
  ('bicycle-inner-b-42710-20-1-75-djj', '42710-20-1.75-DJJ', 'unit', 20, 'Chambre à air vélo 20×1,75 — qualité B', '20×1.75 自行车内胎（B质量）', '20×1,75 · valve Presta FV33 · section 45 mm · minimum 1 000 pièces', '20×1.75 · 法嘴 FV33 · 断面宽度45 mm · 起订量1000条', 6.3),
  ('bicycle-inner-b-42170-16-1-75-fc', '42170-16-1.75-FC', 'unit', 21, 'Chambre à air vélo 16×1,75 — qualité B', '16×1.75 自行车内胎（B质量）', '16×1,75 · valve Schrader AV35 · section 45 mm · minimum 1 000 pièces', '16×1.75 · 美嘴 AV35 · 断面宽度45 mm · 起订量1000条', 5.2),
  ('bicycle-inner-b-42170-20-1-75-fc', '42170-20-1.75-FC', 'unit', 22, 'Chambre à air vélo 20×1,75 — qualité B', '20×1.75 自行车内胎（B质量）', '20×1,75 · valve Schrader AV35 · section 45 mm · minimum 1 000 pièces', '20×1.75 · 美嘴 AV35 · 断面宽度45 mm · 起订量1000条', 5.8),
  ('bicycle-inner-b-42170-24-1-75-fc', '42170-24-1.75-FC', 'unit', 23, 'Chambre à air vélo 24×1,75 — qualité B', '24×1.75 自行车内胎（B质量）', '24×1,75 · valve Schrader AV35 · section 45 mm · minimum 1 000 pièces', '24×1.75 · 美嘴 AV35 · 断面宽度45 mm · 起订量1000条', 6.5),
  ('bicycle-inner-b-42170-26-1-75-fc', '42170-26-1.75-FC', 'unit', 24, 'Chambre à air vélo 26×1,75 — qualité B', '26×1.75 自行车内胎（B质量）', '26×1,75 · valve Schrader AV35 · section 45 mm · minimum 1 000 pièces', '26×1.75 · 美嘴 AV35 · 断面宽度45 mm · 起订量1000条', 6.6),
  ('bicycle-inner-b-42170-27-5-2-125-fc', '42170-27.5-2.125-FC', 'unit', 25, 'Chambre à air vélo 27,5×2,125 — qualité B', '27.5×2.125 自行车内胎（B质量）', '27,5×2,125 · valve Schrader AV35 · section 45 mm · minimum 1 000 pièces', '27.5×2.125 · 美嘴 AV35 · 断面宽度45 mm · 起订量1000条', 6.9),
  ('bicycle-inner-b-42170-700x42-fc', '42170-700*42-FC', 'unit', 26, 'Chambre à air vélo 700×42 — qualité B', '700×42 自行车内胎（B质量）', '700×42 · valve Schrader AV35 · section 34 mm · minimum 1 000 pièces', '700×42 · 美嘴 AV35 · 断面宽度34 mm · 起订量1000条', 7.2);

INSERT INTO products(
  record_id, product_code, product_code_normalized, unit_price_cny, price_basis,
  sales_unit_code, sales_unit_fr, sales_unit_zh, unit_weight_kg,
  unit_weight_source, source_kind
)
SELECT
  record_id, product_code, upper(product_code), final_price_cny, price_basis,
  'unit', 'pièce', '条', NULL, 'unknown', 'excel'
FROM migration_0007_bicycle_catalog;

INSERT INTO category_products(
  category_id, record_id, sort_order, source_row,
  fields_fr_json, fields_zh_json, search_fr, search_zh
)
SELECT
  'devis-sur-demande',
  record_id,
  sort_order,
  NULL,
  json_object(
    'reference', product_code,
    'designation', designation_fr,
    'compatibleModels', 'Bicyclettes',
    'specification', specification_fr,
    'unit', 'pièce',
    'salePriceCny', final_price_cny,
    'description', 'Prix hors taxes'
  ),
  json_object(
    'reference', product_code,
    'designation', designation_zh,
    'compatibleModels', '自行车',
    'specification', specification_zh,
    'unit', '条',
    'salePriceCny', final_price_cny,
    'description', '不含税报价'
  ),
  product_code || ' ' || designation_fr || ' ' || specification_fr,
  product_code || ' ' || designation_zh || ' ' || specification_zh
FROM migration_0007_bicycle_catalog
ORDER BY sort_order;

DROP TABLE migration_0007_bicycle_catalog;
