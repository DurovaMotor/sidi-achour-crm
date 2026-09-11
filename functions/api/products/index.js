const SORTS = {
  source: "c.sort_order, cp.sort_order, p.record_id",
  "price-asc": "p.unit_price_cny IS NULL, p.unit_price_cny ASC, c.sort_order, cp.sort_order",
  "price-desc": "p.unit_price_cny IS NULL, p.unit_price_cny DESC, c.sort_order, cp.sort_order",
  code: "p.product_code_normalized IS NULL, p.product_code_normalized, c.sort_order, cp.sort_order",
};

const CUSTOMER_SENSITIVE_LINE = /(?:进价|進價|采购价|採購價|采购成本|採購成本|成本价|成本價|purchase\s+(?:price|cost)|cost\s+price|unit\s+cost|prix\s+d[’']achat|co[uû]t\s+d[’']achat|prix\s+de\s+revient)/iu;

function sanitizeCustomerText(value) {
  if (value === null || value === undefined) return value;
  return String(value)
    .split(/\r?\n/)
    .filter((line) => !CUSTOMER_SENSITIVE_LINE.test(line))
    .join("\n")
    .trim();
}

function sanitizeCustomerFields(value) {
  if (Array.isArray(value)) return value.map(sanitizeCustomerFields);
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).map(([key, entry]) => [key, sanitizeCustomerFields(entry)]));
  }
  return typeof value === "string" ? sanitizeCustomerText(value) : value;
}

export async function onRequestGet(context) {
  const url = new URL(context.request.url);
  const locale = url.searchParams.get("locale") === "fr" ? "fr" : "zh";
  const workspace = url.searchParams.get("workspace") === "sidi" ? "sidi" : "default";
  const stateAlias = workspace === "sidi" ? "priority_state" : "primary_state";
  const category = url.searchParams.get("category") ?? "all";
  const query = (url.searchParams.get("q") ?? "").trim();
  const page = Math.max(1, Number(url.searchParams.get("page") ?? 1));
  const requestedSort = url.searchParams.get("sort");
  const sort = locale === "fr" && requestedSort === "price-asc"
    ? "COALESCE(primary_state.new_price_cny, p.unit_price_cny) IS NULL, COALESCE(primary_state.new_price_cny, p.unit_price_cny) ASC, c.sort_order, cp.sort_order"
    : locale === "fr" && requestedSort === "price-desc"
      ? "COALESCE(primary_state.new_price_cny, p.unit_price_cny) IS NULL, COALESCE(primary_state.new_price_cny, p.unit_price_cny) DESC, c.sort_order, cp.sort_order"
      : SORTS[requestedSort] ?? SORTS.source;
  const pageSize = 50;
  const offset = (page - 1) * pageSize;
  const fieldsColumn = locale === "fr" ? "cp.fields_fr_json" : "cp.fields_zh_json";
  const searchColumn = locale === "fr" ? "cp.search_fr" : "cp.search_zh";
  const titleColumn = locale === "fr" ? "c.title_fr" : "c.title_zh";
  const conditions = [];
  const params = [];

  if (category !== "all") {
    conditions.push("cp.category_id = ?");
    params.push(category);
  }
  if (query) {
    conditions.push(`(${searchColumn} LIKE '%' || ? || '%' OR p.product_code_normalized LIKE '%' || upper(?) || '%')`);
    params.push(query, query);
  }

  const where = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const base = `
    FROM category_products cp
    JOIN categories c ON c.id = cp.category_id
    JOIN products p ON p.record_id = cp.record_id
    LEFT JOIN product_order_state primary_state ON primary_state.record_id = p.record_id
    LEFT JOIN sidi_priority_order_state priority_state ON priority_state.record_id = p.record_id
    LEFT JOIN product_images pi ON pi.id = (
      SELECT x.id
      FROM product_images x
      WHERE x.record_id = p.record_id
      ORDER BY x.is_primary DESC, x.sort_order, x.id
      LIMIT 1
    )
    ${where}
  `;

  const [countResult, dataResult] = await context.env.DB.batch([
    context.env.DB.prepare(`SELECT COUNT(*) AS total ${base}`).bind(...params),
    context.env.DB.prepare(`
      SELECT
        p.record_id,
        cp.category_id,
        p.product_code,
        p.unit_price_cny,
        p.unit_weight_kg,
        primary_state.new_price_cny,
        ${titleColumn} AS category_title,
        ${fieldsColumn} AS fields_json,
        COALESCE(${stateAlias}.ordered_quantity, 0) AS ordered_quantity,
        COALESCE(${stateAlias}.remark, '') AS remark,
        pi.r2_key,
        pi.width AS image_width,
        pi.height AS image_height
      ${base}
      ORDER BY ${sort}
      LIMIT ? OFFSET ?
    `).bind(...params, pageSize, offset),
  ]);

  const total = Number(countResult.results[0].total);
  const data = dataResult.results.map((row) => ({
    id: row.record_id,
    categoryId: row.category_id,
    categoryTitle: row.category_title,
    productCode: row.product_code,
    fields: sanitizeCustomerFields(JSON.parse(row.fields_json)),
    unitPriceCny: row.unit_price_cny === null ? null : Number(row.unit_price_cny),
    unitWeightKg: row.unit_weight_kg === null ? null : Number(row.unit_weight_kg),
    newPriceCny: row.new_price_cny === null ? null : Number(row.new_price_cny),
    orderedQuantity: Number(row.ordered_quantity),
    orderedAmountCny: Number(row.ordered_quantity) * Number(row.new_price_cny ?? row.unit_price_cny ?? 0),
    remark: sanitizeCustomerText(row.remark),
    image: row.r2_key ? {
      key: row.r2_key,
      url: `/media/${row.r2_key.split("/").map(encodeURIComponent).join("/")}`,
      width: Number(row.image_width),
      height: Number(row.image_height),
    } : null,
  }));

  return Response.json({
    data,
    page,
    pageSize,
    total,
    totalPages: Math.max(1, Math.ceil(total / pageSize)),
  }, { headers: { "Cache-Control": "no-store" } });
}
