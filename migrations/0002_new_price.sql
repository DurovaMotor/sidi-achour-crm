ALTER TABLE product_order_state ADD COLUMN new_price_cny REAL;

DROP VIEW v_category_stats;

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
    SUM(COALESCE(os.ordered_quantity, 0) * COALESCE(os.new_price_cny, p.unit_price_cny, 0)) AS ordered_amount_cny,
    SUM(
      CASE WHEN COALESCE(os.ordered_quantity, 0) > 0
                  AND p.unit_weight_kg IS NULL THEN 1 ELSE 0 END
    ) AS ordered_lines_missing_weight,
    SUM(
      CASE WHEN COALESCE(os.ordered_quantity, 0) > 0
                  AND COALESCE(os.new_price_cny, p.unit_price_cny) IS NULL THEN 1 ELSE 0 END
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
