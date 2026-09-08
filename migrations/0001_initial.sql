PRAGMA foreign_keys = ON;

-- Global values are stored as text so configuration can be updated without a
-- schema migration. Numeric readers must CAST(value AS REAL).
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL,
  display_template TEXT,
  currency TEXT,
  title_fr TEXT NOT NULL,
  title_zh TEXT NOT NULL,
  intro_fr TEXT,
  intro_zh TEXT,
  columns_fr_json TEXT NOT NULL,
  columns_zh_json TEXT NOT NULL,
  -- raw: sum the editable quantity values exactly as entered.
  -- weight_kg: sum ordered_quantity * products.unit_weight_kg.
  quantity_mode TEXT NOT NULL DEFAULT 'raw'
    CHECK (quantity_mode IN ('raw', 'weight_kg')),
  quantity_display_unit_fr TEXT,
  quantity_display_unit_zh TEXT,
  active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1))
);

-- Every Excel display row is a separate product record. Product codes are not
-- unique: they are used for image matching only and never key editable state.
CREATE TABLE products (
  record_id TEXT PRIMARY KEY,
  product_code TEXT,
  product_code_normalized TEXT,
  unit_price_cny REAL,
  price_basis TEXT CHECK (price_basis IN ('unit', 'pair', 'set', 'bag', 'tire', 'unknown')),
  sales_unit_code TEXT,
  sales_unit_fr TEXT,
  sales_unit_zh TEXT,
  -- Weight for one editable quantity unit. Do not put carton weight here.
  unit_weight_kg REAL,
  unit_weight_source TEXT CHECK (
    unit_weight_source IN ('per_item', 'per_tire', 'carton_derived', 'unknown')
  ),
  source_kind TEXT NOT NULL DEFAULT 'excel',
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE INDEX idx_products_product_code
  ON products(product_code_normalized)
  WHERE product_code_normalized IS NOT NULL;

-- Locale-specific row JSON preserves each worksheet's differing column shape.
CREATE TABLE category_products (
  category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  record_id TEXT NOT NULL REFERENCES products(record_id) ON DELETE CASCADE,
  sort_order INTEGER NOT NULL,
  source_row INTEGER,
  fields_fr_json TEXT NOT NULL,
  fields_zh_json TEXT NOT NULL,
  search_fr TEXT NOT NULL DEFAULT '',
  search_zh TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (category_id, record_id)
);

CREATE INDEX idx_category_products_page
  ON category_products(category_id, sort_order, record_id);
CREATE INDEX idx_category_products_record
  ON category_products(record_id);

CREATE TABLE product_images (
  id TEXT PRIMARY KEY,
  record_id TEXT NOT NULL REFERENCES products(record_id) ON DELETE CASCADE,
  r2_key TEXT NOT NULL,
  source TEXT NOT NULL CHECK (source IN ('jiandaoyun', 'excel')),
  is_primary INTEGER NOT NULL DEFAULT 0 CHECK (is_primary IN (0, 1)),
  width INTEGER,
  height INTEGER,
  bytes INTEGER,
  sha256 TEXT,
  alt_fr TEXT,
  alt_zh TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  UNIQUE(record_id, r2_key)
);

CREATE INDEX idx_product_images_primary
  ON product_images(record_id, is_primary DESC, sort_order, id);

CREATE TABLE product_order_state (
  record_id TEXT PRIMARY KEY REFERENCES products(record_id) ON DELETE CASCADE,
  ordered_quantity REAL NOT NULL DEFAULT 0 CHECK (ordered_quantity >= 0),
  remark TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

-- Keep every licence row instead of prematurely collapsing it by category.
-- This preserves the audit trail when a category maps to multiple HS rows.
CREATE TABLE category_quotas (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  hs_code_10 TEXT,
  designation_fr TEXT NOT NULL,
  designation_zh TEXT NOT NULL,
  requested_quantity REAL NOT NULL,
  quota_unit_code TEXT NOT NULL CHECK (quota_unit_code IN ('kg', 'unit')),
  quota_unit_fr TEXT NOT NULL,
  quota_unit_zh TEXT NOT NULL,
  declared_unit_price_usd REAL,
  quota_value_usd REAL NOT NULL,
  -- Snapshot is retained for audit; the current UI requirement uses the global
  -- fixed rate from app_settings (6.67).
  fx_rate_usd_cny_snapshot REAL NOT NULL DEFAULT 6.67,
  sort_order INTEGER NOT NULL
);

CREATE INDEX idx_category_quotas_category
  ON category_quotas(category_id, sort_order, id);

INSERT INTO app_settings(key, value) VALUES
  ('usd_cny_rate', '6.67'),
  ('fx_notice_zh', '金额按固定汇率 1 USD = 6.67 CNY 换算'),
  ('fx_notice_fr', 'Conversion au taux fixe : 1 USD = 6,67 CNY'),
  ('catalog_page_size', '50');

-- Read model for the colored category fractions. It exposes both raw count and
-- known-weight totals. The UI currently uses quantity_mode='raw' and always
-- uses CNY for the amount fraction.
CREATE VIEW v_category_stats AS
WITH
order_totals AS (
  SELECT
    cp.category_id,
    SUM(COALESCE(os.ordered_quantity, 0)) AS ordered_quantity_raw,
    SUM(
      CASE WHEN p.unit_weight_kg IS NOT NULL
        THEN COALESCE(os.ordered_quantity, 0) * p.unit_weight_kg
        ELSE 0
      END
    ) AS ordered_weight_kg_known,
    SUM(
      CASE WHEN p.unit_price_cny IS NOT NULL
        THEN COALESCE(os.ordered_quantity, 0) * p.unit_price_cny
        ELSE 0
      END
    ) AS ordered_amount_cny,
    SUM(
      CASE WHEN COALESCE(os.ordered_quantity, 0) > 0
                  AND p.unit_weight_kg IS NULL THEN 1 ELSE 0 END
    ) AS ordered_lines_missing_weight,
    SUM(
      CASE WHEN COALESCE(os.ordered_quantity, 0) > 0
                  AND p.unit_price_cny IS NULL THEN 1 ELSE 0 END
    ) AS ordered_lines_missing_price
  FROM category_products cp
  JOIN products p ON p.record_id = cp.record_id
  LEFT JOIN product_order_state os ON os.record_id = p.record_id
  GROUP BY cp.category_id
),
quota_totals AS (
  SELECT
    category_id,
    SUM(requested_quantity) AS quota_quantity,
    MIN(quota_unit_code) AS quota_unit_code,
    COUNT(DISTINCT quota_unit_code) AS quota_unit_count,
    SUM(quota_value_usd) AS quota_value_usd,
    SUM(quota_value_usd * fx_rate_usd_cny_snapshot) AS quota_value_cny_snapshot
  FROM category_quotas
  GROUP BY category_id
),
rate AS (
  SELECT CAST(value AS REAL) AS usd_cny_rate
  FROM app_settings
  WHERE key = 'usd_cny_rate'
)
SELECT
  c.id AS category_id,
  c.quantity_mode,
  CASE c.quantity_mode
    WHEN 'weight_kg' THEN COALESCE(o.ordered_weight_kg_known, 0)
    ELSE COALESCE(o.ordered_quantity_raw, 0)
  END AS ordered_quantity,
  COALESCE(o.ordered_quantity_raw, 0) AS ordered_quantity_raw,
  COALESCE(o.ordered_weight_kg_known, 0) AS ordered_weight_kg_known,
  COALESCE(q.quota_quantity, 0) AS quota_quantity,
  q.quota_unit_code,
  COALESCE(o.ordered_amount_cny, 0) AS ordered_amount_cny,
  COALESCE(q.quota_value_usd, 0) AS quota_value_usd,
  COALESCE(q.quota_value_usd, 0) * rate.usd_cny_rate AS quota_value_cny,
  q.quota_value_cny_snapshot,
  rate.usd_cny_rate,
  COALESCE(o.ordered_lines_missing_weight, 0) AS ordered_lines_missing_weight,
  COALESCE(o.ordered_lines_missing_price, 0) AS ordered_lines_missing_price,
  COALESCE(q.quota_unit_count, 0) AS quota_unit_count
FROM categories c
LEFT JOIN order_totals o ON o.category_id = c.id
LEFT JOIN quota_totals q ON q.category_id = c.id
CROSS JOIN rate;
