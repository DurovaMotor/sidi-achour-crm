export async function onRequestPatch(context) {
  const recordId = context.params.recordId;
  const body = await context.request.json();
  const newPriceCny = body.newPriceCny == null ? null : Number(body.newPriceCny);
  const orderedQuantity = Number(body.orderedQuantity);
  const remark = String(body.remark ?? "");

  await context.env.DB.prepare(`
    INSERT INTO product_order_state(record_id, new_price_cny, ordered_quantity, remark, updated_at)
    VALUES (?, ?, ?, ?, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
    ON CONFLICT(record_id) DO UPDATE SET
      new_price_cny = CASE WHEN ? THEN excluded.new_price_cny ELSE product_order_state.new_price_cny END,
      ordered_quantity = excluded.ordered_quantity,
      remark = excluded.remark,
      updated_at = excluded.updated_at
  `).bind(recordId, newPriceCny, orderedQuantity, remark, Number(Object.hasOwn(body, "newPriceCny"))).run();

  const product = await context.env.DB.prepare(`
    SELECT
      os.record_id,
      os.new_price_cny,
      os.ordered_quantity,
      os.remark,
      os.updated_at,
      COALESCE(os.ordered_quantity, 0) * COALESCE(os.new_price_cny, p.unit_price_cny, 0) AS ordered_amount_cny
    FROM product_order_state os
    JOIN products p ON p.record_id = os.record_id
    WHERE os.record_id = ?
  `).bind(recordId).first();

  const stats = await context.env.DB.prepare(`
    SELECT
      s.category_id,
      s.ordered_quantity,
      s.quota_quantity,
      s.quota_unit_code,
      s.ordered_amount_cny,
      s.quota_value_cny,
      s.quota_value_usd,
      s.usd_cny_rate
    FROM v_category_stats s
    JOIN category_products cp ON cp.category_id = s.category_id
    WHERE cp.record_id = ?
  `).bind(recordId).all();

  return Response.json({
    product: {
      id: product.record_id,
      newPriceCny: product.new_price_cny === null ? null : Number(product.new_price_cny),
      orderedQuantity: Number(product.ordered_quantity),
      orderedAmountCny: Number(product.ordered_amount_cny),
      remark: product.remark,
      updatedAt: product.updated_at,
    },
    categoryStats: stats.results.map((row) => ({
      categoryId: row.category_id,
      orderedQuantity: Number(row.ordered_quantity),
      quotaQuantity: Number(row.quota_quantity),
      quotaUnit: row.quota_unit_code,
      orderedAmountCny: Number(row.ordered_amount_cny),
      quotaAmountCny: Number(row.quota_value_cny),
      quotaAmountUsd: Number(row.quota_value_usd),
      usdCnyRate: Number(row.usd_cny_rate),
    })),
  }, { headers: { "Cache-Control": "no-store" } });
}
