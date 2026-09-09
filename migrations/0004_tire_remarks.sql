CREATE TABLE tire_remarks_provenance (
  record_id TEXT PRIMARY KEY REFERENCES products(record_id) ON DELETE CASCADE,
  product_code TEXT NOT NULL,
  source_workbook TEXT NOT NULL,
  source_sheet TEXT NOT NULL,
  source_row INTEGER NOT NULL,
  remarks TEXT,
  matched_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE rollback_0004_tire_fields (
  record_id TEXT PRIMARY KEY,
  fields_fr_json TEXT NOT NULL,
  fields_zh_json TEXT NOT NULL
);

INSERT INTO rollback_0004_tire_fields(record_id, fields_fr_json, fields_zh_json)
SELECT record_id, fields_fr_json, fields_zh_json
FROM category_products
WHERE category_id = 'pneumatiques';

INSERT INTO tire_remarks_provenance(record_id, product_code, source_workbook, source_sheet, source_row, remarks) VALUES
  ('pneumatiques-6', 'TL-01-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 5, 'Dayan'),
  ('pneumatiques-7', 'TL-01-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 6, 'A1155'),
  ('pneumatiques-8', 'TL-01-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 7, 'B0553'),
  ('pneumatiques-9', 'TL-02-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 8, 'Brand: DURO; Product code: 42710-90-90-10-DURO'),
  ('pneumatiques-10', 'TL-02-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 9, 'A1138 Minlong'),
  ('pneumatiques-11', 'TL-02-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 10, 'B0553'),
  ('pneumatiques-12', 'TL-03-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 12, NULL),
  ('pneumatiques-13', 'TL-03-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 13, 'B0553'),
  ('pneumatiques-14', 'TL-04-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 14, 'Brand: DURO; Product code: 42710-100-90-10-DURO'),
  ('pneumatiques-15', 'TL-04-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 15, 'A1138 Minlong'),
  ('pneumatiques-16', 'TL-04-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 16, 'B0553'),
  ('pneumatiques-17', 'TL-05-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 17, 'Brand: DURO; Product code: 42710-100-90-10-DURO'),
  ('pneumatiques-18', 'TL-05-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 18, 'Dayan'),
  ('pneumatiques-19', 'TL-05-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 19, 'B0553'),
  ('pneumatiques-20', 'TL-06-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 20, 'Brand: DURO'),
  ('pneumatiques-21', 'TL-06-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 21, 'A1138 Minlong'),
  ('pneumatiques-22', 'TL-06-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 22, 'B0553'),
  ('pneumatiques-23', 'TL-07-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 23, 'Brand: DURO'),
  ('pneumatiques-24', 'TL-07-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 24, 'A1138 Minlong'),
  ('pneumatiques-25', 'TL-07-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 25, 'B0553'),
  ('pneumatiques-26', 'TL-08-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 26, 'A1138 Minlong'),
  ('pneumatiques-27', 'TL-08-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 27, 'B0553'),
  ('pneumatiques-28', 'TL-08-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 28, NULL),
  ('pneumatiques-29', 'TL-09-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 30, 'A1138 Minlong Tire'),
  ('pneumatiques-30', 'TL-09-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 31, 'A1155'),
  ('pneumatiques-31', 'TL-10-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 33, 'A1155'),
  ('pneumatiques-32', 'TL-10-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 34, 'B0553'),
  ('pneumatiques-33', 'TL-11-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 36, 'A1138 Minlong Tire'),
  ('pneumatiques-34', 'TL-11-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 37, 'A1155'),
  ('pneumatiques-35', 'TL-12-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 38, 'Brand: DURO; Product code: 42710-130-70-13-DURO'),
  ('pneumatiques-36', 'TL-12-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 39, 'A1138 Minlong Tire'),
  ('pneumatiques-37', 'TL-12-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 40, 'B0553'),
  ('pneumatiques-38', 'TL-13-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 41, 'A1138 Minlong Tire'),
  ('pneumatiques-39', 'TL-13-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 42, 'B0553'),
  ('pneumatiques-40', 'TL-13-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 43, NULL),
  ('pneumatiques-41', 'TL-14-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 45, NULL),
  ('pneumatiques-42', 'TL-15-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 47, 'A1138 Minlong Tire'),
  ('pneumatiques-43', 'TL-15-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 48, 'A1155'),
  ('pneumatiques-44', 'TL-15-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 49, 'B0553'),
  ('pneumatiques-45', 'TL-16-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 50, 'A0088'),
  ('pneumatiques-46', 'TL-16-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 51, 'A1138 Minlong Tire'),
  ('pneumatiques-47', 'TL-16-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 52, 'B0553: tubeless tire 44; standard tire 37.'),
  ('pneumatiques-48', 'TL-18-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 57, 'A1155'),
  ('pneumatiques-49', 'TL-18-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 58, 'B0553'),
  ('pneumatiques-50', 'TL-19-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 59, 'Brand: DURO; Product code: 42710-120-70-12-DURO'),
  ('pneumatiques-51', 'TL-19-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 60, 'Dayan'),
  ('pneumatiques-52', 'TL-19-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 61, 'B0553'),
  ('pneumatiques-53', 'TL-20-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 62, 'Brand: DURO; Product code: 42710-130-70-12-DURO');

INSERT INTO tire_remarks_provenance(record_id, product_code, source_workbook, source_sheet, source_row, remarks) VALUES
  ('pneumatiques-54', 'TL-20-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 63, 'B0553'),
  ('pneumatiques-55', 'TL-20-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 64, 'A1155'),
  ('pneumatiques-56', 'TL-21-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 65, 'A0088'),
  ('pneumatiques-57', 'TL-21-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 66, 'A1138 Minlong Tire'),
  ('pneumatiques-58', 'TL-21-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 67, 'B0553'),
  ('pneumatiques-59', 'TL-22-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 68, NULL),
  ('pneumatiques-60', 'TL-22-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 69, 'B0553'),
  ('pneumatiques-61', 'TL-22-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 70, 'A1155'),
  ('pneumatiques-62', 'TL-23-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 72, NULL),
  ('pneumatiques-63', 'TL-23-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 73, 'B0553'),
  ('pneumatiques-64', 'TL-24-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 75, 'B0553'),
  ('pneumatiques-65', 'TL-24-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 76, 'A1155'),
  ('pneumatiques-66', 'TL-25-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 77, 'A0088'),
  ('pneumatiques-67', 'TL-25-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 78, 'A1155'),
  ('pneumatiques-68', 'TL-25-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 79, 'B0553'),
  ('pneumatiques-69', 'TL-26-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 81, 'A1154'),
  ('pneumatiques-70', 'TL-26-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 82, 'A1155'),
  ('pneumatiques-71', 'TL-27-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 83, 'A1138 Minlong Tire'),
  ('pneumatiques-72', 'TL-27-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 84, 'A1155'),
  ('pneumatiques-73', 'TL-27-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 85, 'B0553'),
  ('pneumatiques-74', 'TT-17-A', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 53, 'A0088'),
  ('pneumatiques-75', 'TT-17-B', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 54, 'A1138 Minlong Tire'),
  ('pneumatiques-76', 'TT-17-C', 'Tire_Quotation_Customer_EN_Color_Coded.xlsx', 'Quotation', 55, NULL);

UPDATE category_products
SET fields_fr_json = json_set(fields_fr_json, '$.remarks', (
      SELECT p.remarks FROM tire_remarks_provenance p
      WHERE p.record_id = category_products.record_id
    )),
    fields_zh_json = json_set(fields_zh_json, '$.remarks', (
      SELECT p.remarks FROM tire_remarks_provenance p
      WHERE p.record_id = category_products.record_id
    ))
WHERE category_id = 'pneumatiques'
  AND record_id IN (SELECT record_id FROM tire_remarks_provenance);
