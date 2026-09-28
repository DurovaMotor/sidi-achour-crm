import { encryptCatalogMedia } from "../../_lib/catalog-media.js";
import { readAdamSession, unauthorizedResponse } from "../../_lib/adam-auth.js";

const MEDIA_CHUNK_BYTES = 512 * 1024;

function text(value, key) {
  return String(value[key] ?? "").trim();
}

function numeric(value, key) {
  const number = text(value, key);
  return number === "" ? null : Number(number);
}

function mediaStatements(database, mediaKey, kind, contentType, encrypted) {
  const statements = [];
  for (let offset = 0, chunkIndex = 0; offset < encrypted.byteLength; offset += MEDIA_CHUNK_BYTES, chunkIndex += 1) {
    statements.push(database.prepare(`
      INSERT INTO uploaded_catalog_media_chunks(media_key, kind, chunk_index, content_type, encrypted_bytes)
      VALUES (?, ?, ?, ?, ?)
    `).bind(
      mediaKey,
      kind,
      chunkIndex,
      contentType,
      encrypted.slice(offset, offset + MEDIA_CHUNK_BYTES).buffer,
    ));
  }
  return statements;
}

export async function onRequestPost(context) {
  if (!await readAdamSession(context.request, context.env.ADAM_SESSION_SECRET)) return unauthorizedResponse();

  const form = await context.request.formData();
  const categoryId = String(form.get("categoryId") ?? "").trim();
  const rows = JSON.parse(String(form.get("rows") ?? "[]"));
  const statements = [];
  const ids = [];

  for (const row of rows) {
    const productCode = text(row, "productCode");
    const nameZh = text(row, "nameZh");
    const nameFr = text(row, "nameFr") || nameZh;
    const compatibleModels = text(row, "compatibleModels");
    const specification = text(row, "specification");
    const unitZh = text(row, "unitZh") || "个";
    const unitFr = text(row, "unitFr") || "pièce";
    const unitPriceCny = numeric(row, "unitPriceCny");
    const newPriceCny = numeric(row, "newPriceCny");
    const unitWeightKg = numeric(row, "unitWeightKg");
    const description = text(row, "description");
    const recordId = `${categoryId}-adam-${crypto.randomUUID()}`;
    const normalizedCode = productCode.toUpperCase();
    const fieldsZh = { reference: productCode, designation: nameZh, compatibleModels, specification, remarks: specification, unit: unitZh, salePriceCny: unitPriceCny, weightKg: unitWeightKg, description };
    const fieldsFr = { reference: productCode, designation: nameFr, compatibleModels, specification, remarks: specification, unit: unitFr, salePriceCny: unitPriceCny, weightKg: unitWeightKg, description };
    const searchZh = Object.values(fieldsZh).filter((value) => value !== null).join(" ");
    const searchFr = Object.values(fieldsFr).filter((value) => value !== null).join(" ");

    statements.push(
      context.env.DB.prepare(`
        INSERT INTO products(
          record_id, product_code, product_code_normalized, unit_price_cny,
          price_basis, sales_unit_code, sales_unit_fr, sales_unit_zh,
          unit_weight_kg, unit_weight_source, source_kind
        ) VALUES (?, ?, ?, ?, 'unit', 'unit', ?, ?, ?, ?, 'adam')
      `).bind(recordId, productCode, normalizedCode, unitPriceCny, unitFr, unitZh, unitWeightKg, unitWeightKg === null ? "unknown" : "per_item"),
      context.env.DB.prepare(`
        INSERT INTO category_products(
          category_id, record_id, sort_order, source_row,
          fields_fr_json, fields_zh_json, search_fr, search_zh
        )
        SELECT ?, ?, COALESCE(MAX(sort_order), -1) + 1, NULL, ?, ?, ?, ?
        FROM category_products
        WHERE category_id = ?
      `).bind(categoryId, recordId, JSON.stringify(fieldsFr), JSON.stringify(fieldsZh), searchFr, searchZh, categoryId),
      context.env.DB.prepare(`
        INSERT INTO product_order_state(record_id, new_price_cny, ordered_quantity, remark)
        VALUES (?, ?, 0, '')
      `).bind(recordId, newPriceCny),
    );

    const original = form.get(`image.${row.key}`);
    const frenchPreview = form.get(`frenchPreview.${row.key}`);
    if (original instanceof File && original.size && frenchPreview instanceof File && frenchPreview.size) {
      const imageId = `img_${crypto.randomUUID()}`;
      const extension = original.type === "image/png" ? "png" : original.type === "image/webp" ? "webp" : "jpg";
      const mediaKey = `catalog/v1/uploads/${crypto.randomUUID()}.${extension}`;
      const [originalEncrypted, frenchEncrypted] = await Promise.all([
        encryptCatalogMedia(await original.arrayBuffer(), context.env.CATALOG_MEDIA_AES_KEY, mediaKey, "original"),
        encryptCatalogMedia(await frenchPreview.arrayBuffer(), context.env.CATALOG_MEDIA_AES_KEY, mediaKey, "french"),
      ]);
      statements.push(...mediaStatements(context.env.DB, mediaKey, "original", original.type, originalEncrypted));
      statements.push(...mediaStatements(context.env.DB, mediaKey, "french", frenchPreview.type, frenchEncrypted));
      statements.push(context.env.DB.prepare(`
        INSERT INTO product_images(
          id, record_id, r2_key, source, is_primary, width, height, bytes,
          sha256, alt_fr, alt_zh, sort_order
        ) VALUES (?, ?, ?, 'excel', 1, ?, ?, ?, NULL, ?, ?, 0)
      `).bind(imageId, recordId, mediaKey, Number(row.imageWidth), Number(row.imageHeight), original.size, nameFr, nameZh));
    }
    ids.push({ key: row.key, id: recordId });
  }

  await context.env.DB.batch(statements);
  return Response.json({ ids, categoryId }, {
    status: 201,
    headers: { "Cache-Control": "no-store" },
  });
}
