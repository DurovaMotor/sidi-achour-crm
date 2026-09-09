export async function onRequestGet(context) {
  const locale = new URL(context.request.url).searchParams.get("locale") === "fr" ? "fr" : "zh";
  const fieldsColumn = locale === "fr" ? "cp.fields_fr_json" : "cp.fields_zh_json";
  const categoryTitleColumn = locale === "fr" ? "c.title_fr" : "c.title_zh";
  const salesUnitColumn = locale === "fr" ? "p.sales_unit_fr" : "p.sales_unit_zh";
  const result = await context.env.DB.prepare(`
    SELECT
      os.record_id,
      p.product_code,
      p.unit_price_cny,
      ${salesUnitColumn} AS sales_unit,
      p.unit_weight_kg,
      os.new_price_cny,
      os.ordered_quantity,
      os.remark AS order_remark,
      os.updated_at,
      c.id AS category_id,
      ${categoryTitleColumn} AS category_title,
      ${fieldsColumn} AS fields_json,
      pi.r2_key AS image_key
    FROM product_order_state os
    JOIN products p ON p.record_id = os.record_id
    JOIN category_products cp ON cp.record_id = os.record_id
    JOIN categories c ON c.id = cp.category_id
    LEFT JOIN product_images pi ON pi.id = (
      SELECT image.id
      FROM product_images image
      WHERE image.record_id = os.record_id
      ORDER BY image.is_primary DESC, image.sort_order, image.id
      LIMIT 1
    )
    WHERE os.ordered_quantity > 0
    ORDER BY c.sort_order, cp.sort_order, os.record_id
  `).all();

  const clean = (value) => value == null ? "" : String(value).trim();
  const data = result.results.map((row) => {
    const fields = JSON.parse(row.fields_json);
    const productName = clean(fields.designation || fields.suppliedModel || fields.customerSpecification || (locale === "fr" ? row.category_title : fields.reference || row.product_code));
    const specification = row.category_id === "pneumatiques"
      ? clean(fields.remarks)
      : [...new Set([
          fields.compatibleModels,
          fields.specification,
          fields.customerSpecification,
          fields.requestedPattern,
          fields.description,
          fields.remarks,
        ].map(clean).filter(Boolean))].join("\n");
    const originalPriceCny = row.unit_price_cny === null ? null : Number(row.unit_price_cny);
    const newPriceCny = row.new_price_cny === null ? null : Number(row.new_price_cny);
    const effectivePriceCny = newPriceCny ?? originalPriceCny;
    const orderedQuantity = Number(row.ordered_quantity);
    const unitWeightKg = row.unit_weight_kg === null ? null : Number(row.unit_weight_kg);

    return {
      recordId: row.record_id,
      imageUrl: row.image_key ? `/media/${row.image_key.split("/").map(encodeURIComponent).join("/")}` : null,
      productCode: row.product_code ?? "",
      productName,
      categoryId: row.category_id,
      category: row.category_title,
      specification,
      salesUnit: clean(row.sales_unit || fields.unit) || (locale === "fr" ? "pièce" : "个"),
      originalPriceCny,
      newPriceCny,
      effectivePriceCny,
      orderedQuantity,
      unitWeightKg,
      orderedWeightKg: unitWeightKg === null ? null : orderedQuantity * unitWeightKg,
      orderedAmountCny: effectivePriceCny === null ? null : orderedQuantity * effectivePriceCny,
      orderRemark: row.order_remark,
      updatedAt: row.updated_at,
    };
  });

  return Response.json({ generatedAt: new Date().toISOString(), data }, {
    headers: { "Cache-Control": "no-store" },
  });
}
