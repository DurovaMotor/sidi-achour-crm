import { readAdamSession, unauthorizedResponse } from "../_lib/adam-auth.js";

export async function onRequestGet(context) {
  const url = new URL(context.request.url);
  const locale = url.searchParams.get("locale") === "fr" ? "fr" : "zh";
  if (locale === "zh" && !await readAdamSession(context.request, context.env.ADAM_SESSION_SECRET)) {
    return unauthorizedResponse();
  }
  const statsView = url.searchParams.get("workspace") === "sidi" ? "v_sidi_priority_category_stats" : "v_category_stats";
  const titleColumn = locale === "fr" ? "c.title_fr" : "c.title_zh";
  const unitColumn = locale === "fr" ? "c.quantity_display_unit_fr" : "c.quantity_display_unit_zh";

  const [categoriesResult, settingsResult] = await context.env.DB.batch([
    context.env.DB.prepare(`
      SELECT
        c.id,
        c.sort_order,
        ${titleColumn} AS title,
        COUNT(cp.record_id) AS product_count,
        s.quantity_mode,
        s.ordered_quantity,
        s.quota_quantity,
        ${unitColumn} AS quota_unit,
        s.quota_unit_code,
        s.ordered_amount_cny,
        s.quota_value_cny,
        s.quota_value_usd,
        s.usd_cny_rate
      FROM categories c
      LEFT JOIN category_products cp ON cp.category_id = c.id
      LEFT JOIN ${statsView} s ON s.category_id = c.id
      WHERE c.active = 1
      GROUP BY c.id
      ORDER BY c.sort_order, c.id
    `),
    context.env.DB.prepare(`
      SELECT key, value
      FROM app_settings
      WHERE key IN ('fx_notice_zh', 'fx_notice_fr', 'catalog_page_size')
    `),
  ]);

  const settings = Object.fromEntries(settingsResult.results.map((row) => [row.key, row.value]));
  const data = categoriesResult.results.map((row) => ({
    id: row.id,
    title: row.title,
    productCount: Number(row.product_count),
    quantity: {
      ordered: Number(row.ordered_quantity ?? 0),
      quota: Number(row.quota_quantity ?? 0),
      unit: row.quota_unit ?? "",
      mode: row.quantity_mode,
    },
    amount: {
      orderedCny: Number(row.ordered_amount_cny ?? 0),
      quotaCny: Number(row.quota_value_cny ?? 0),
      quotaUsd: Number(row.quota_value_usd ?? 0),
      usdCnyRate: Number(row.usd_cny_rate),
    },
  }));

  return Response.json({
    data,
    pageSize: Number(settings.catalog_page_size),
    fxNotice: settings[locale === "fr" ? "fx_notice_fr" : "fx_notice_zh"],
  }, { headers: { "Cache-Control": "no-store" } });
}
