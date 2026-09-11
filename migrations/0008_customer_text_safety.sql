PRAGMA foreign_keys = ON;

-- Remove the one legacy internal note found in customer-facing catalog data.
UPDATE category_products
SET fields_zh_json = json_remove(fields_zh_json, '$.description'),
    search_zh = trim(
      COALESCE(json_extract(fields_zh_json, '$.reference'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.designation'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.compatibleModels'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.specification'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.unit'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.salePriceCny'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.unitsPerCarton'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.weightKg'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.cartonDimensionsCm'), '') || ' ' ||
      COALESCE(json_extract(fields_zh_json, '$.volumeM3'), '')
    )
WHERE record_id = 'eclairage-31';
