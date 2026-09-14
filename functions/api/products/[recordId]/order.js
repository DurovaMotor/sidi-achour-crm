import { readAdamSession, unauthorizedResponse } from "../../../_lib/adam-auth.js";

export async function onRequestPatch(context) {
  const url = new URL(context.request.url);
  const requestedWorkspace = url.searchParams.get("workspace");
  const workspace = requestedWorkspace === "sidi" ? "sidi" : requestedWorkspace === "adam" ? "adam" : "default";
  if (workspace === "adam" && !await readAdamSession(context.request, context.env.ADAM_SESSION_SECRET)) {
    return unauthorizedResponse();
  }
  const recordId = context.params.recordId;
  const body = await context.request.json();
  const newPriceCny = body.newPriceCny == null ? null : Number(body.newPriceCny);
  const orderedQuantity = Number(body.orderedQuantity);
  const remark = String(body.remark ?? "");

  if (workspace === "sidi") {
    await context.env.DB.prepare(`
      INSERT INTO sidi_priority_order_state(record_id, ordered_quantity, remark, updated_at)
      VALUES (?, ?, ?, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
      ON CONFLICT(record_id) DO UPDATE SET
        ordered_quantity = excluded.ordered_quantity,
        remark = excluded.remark,
        updated_at = excluded.updated_at
    `).bind(recordId, orderedQuantity, remark).run();
  } else {
    const updateNewPrice = workspace === "adam" && Object.hasOwn(body, "newPriceCny");
    await context.env.DB.prepare(`
      INSERT INTO product_order_state(record_id, new_price_cny, ordered_quantity, remark, updated_at)
      VALUES (?, ?, ?, ?, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
      ON CONFLICT(record_id) DO UPDATE SET
        new_price_cny = CASE WHEN ? THEN excluded.new_price_cny ELSE product_order_state.new_price_cny END,
        ordered_quantity = excluded.ordered_quantity,
        remark = excluded.remark,
        updated_at = excluded.updated_at
    `).bind(recordId, newPriceCny, orderedQuantity, remark, Number(updateNewPrice)).run();
  }

  const stateTable = workspace === "sidi" ? "sidi_priority_order_state" : "product_order_state";
  const statsView = workspace === "sidi" ? "v_sidi_priority_category_stats" : "v_category_stats";
  const newPriceExpression = workspace === "sidi" ? "price_state.new_price_cny" : "os.new_price_cny";

  const product = await context.env.DB.prepare(`
    SELECT
      os.record_id,
      ${newPriceExpression} AS new_price_cny,
      os.ordered_quantity,
      os.remark,
      os.updated_at,
      COALESCE(os.ordered_quantity, 0) * COALESCE(${newPriceExpression}, p.unit_price_cny, 0) AS ordered_amount_cny
    FROM ${stateTable} os
    JOIN products p ON p.record_id = os.record_id
    LEFT JOIN product_order_state price_state ON price_state.record_id = os.record_id
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
    FROM ${statsView} s
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
