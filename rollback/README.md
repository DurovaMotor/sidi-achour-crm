# D1 rollback

Before the weight migration, the complete production database was exported to the locally ignored `backups/` directory. Migration `0003_weight_basis.sql` also snapshots the 384 affected product weights and 21 category modes inside D1.

To revert only the derived weight feature while preserving all order quantities, remarks and new prices:

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --remote --file rollback/0003_weight_basis.rollback.sql
```

The rollback restores the previous `products.unit_weight_kg`, `unit_weight_source`, product timestamps and category quantity modes. It does not write to `product_order_state`.

## Production backup used for this migration

- Full D1 export: `backups/sidi-achour-orders-pre-weight-20260909T022734Z.sql`
- Full export SHA-256: `ad291959b15ab8e56e58f01451866ba2f91351b178bab285fcf2d3458e04175b`
- Immediate pre-migration order state: `backups/product_order_state-immediate-pre-20260909-105100.sql`
- Immediate post-migration order state: `backups/product_order_state-immediate-post-20260909-105657.sql`
- Both order-state SHA-256 values: `94fbf9b9312ea78a46124746936959da9a79bf441e86b9f3bf99f7724baddbc2`

The full export was restored into an isolated local D1. Migration and rollback were both executed there; all 343 order-state rows matched the backup exactly before migration, after migration and after rollback.

## Tire Remarks rollback

Migration `0004_tire_remarks.sql` snapshots both localized JSON fields for all 71 tire rows. To restore those fields without changing order state:

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --remote --file rollback/0004_tire_remarks.rollback.sql
```

Production backup: `backups/sidi-achour-orders-pre-tire-remarks-20260909-120637.sql`, SHA-256 `e34e18d42c9bd8e4776f9d09d6b6b0af63717b7516a75ee2c992ff2ac4ffa04c`.

The immediate pre/post order-state exports both have SHA-256 `6e45e4e6ccc9b5b0f732fdb483bdf3407ed7126c40748fb9caa853d1e414cd56`.

## Sidi priority workspace and catalog additions

Migration `0006_sidi_priority_and_inner_tubes.sql` creates a separate customer-priority state table, adds two inner-tube products and updates the `TL-16-C` catalog Remarks value. It does not write `product_order_state`.

To restore only the previous `TL-16-C` catalog fields while preserving all original and customer-priority user data:

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --remote --file rollback/0006_catalog_changes.rollback.sql
```

Production backup: `backups/pre-sidi-priority-20260909-151042.sql`, SHA-256 `bbbcaf20540084ed37d05a38ec5eb4d18cba456c24dafebf45a478f0001857d3`.

The additive product rows and `sidi_priority_order_state` intentionally remain during the targeted rollback so data entered after release is never deleted. The full pre-migration export supports complete disaster recovery when explicitly required.

## Bicycle tyre catalog rollback

Migration `0007_bicycle_tire_catalog.sql` replaces the two bicycle-tyre quote placeholders with 27 priced product rows. The migration snapshots the replaced product rows, both order-state tables and the category metadata.

Production backup: `backups/sidi-achour-orders-pre-bicycle-catalog-20260910T042207Z.sql`, SHA-256 `5e542595e0fbff874c60a2e0f75b5b9c31727f0f8945e8ff67f6ae7d609f964e`.

To restore the placeholders and their saved state:

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --remote --file rollback/0007_bicycle_tire_catalog.rollback.sql
```

This targeted rollback deletes the 27 replacement rows. Use it only after confirming that no new order or priority quantities need to be retained.

## Bicycle tyre row-order rollback

Migration `0009_group_bicycle_tires_by_size.sql` snapshots the previous row order before grouping bicycle products by size and code. To restore the previous order without changing product data or order state:

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --remote --file rollback/0009_group_bicycle_tires_by_size.rollback.sql
```

## Bicycle product-code suffix rollback

Migration `0010_bicycle_product_code_suffixes.sql` snapshots all 27 previous bicycle product codes, localized fields and search text before adding the customer-facing suffixes. To restore the previous codes without changing row order, prices or order state:

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --remote --file rollback/0010_bicycle_product_code_suffixes.rollback.sql
```

## Bicycle historical-sales order rollback

Migration `0011_bicycle_historical_sales_sort.sql` snapshots the previous row order before applying the matching order from the historical-sales workbook. To restore the previous order without changing product codes, prices or order state:

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --remote --file rollback/0011_bicycle_historical_sales_sort.rollback.sql
```

## Bicycle supplier-code rollback

Migration `0012_bicycle_supplier_codes.sql` snapshots both localized product-field JSON values and search text before adding supplier codes to the combined specification/model column. To restore the previous fields without changing product codes, prices, row order or order state:

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --remote --file rollback/0012_bicycle_supplier_codes.rollback.sql
```

## DJJ bicycle outer-tyre rollback

Migration `0013_remove_djj_bicycle_outer_tires.sql` snapshots the three removed `DJJ-WT` product rows, category fields, image relationships and both order-state tables. To restore them:

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --remote --file rollback/0013_remove_djj_bicycle_outer_tires.rollback.sql
```

## Category title rollback

Migration `0005_category_titles.sql` snapshots all 35 previous French and Chinese category titles. To restore them without changing products or order state:

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --remote --file rollback/0005_category_titles.rollback.sql
```

Production backup: `backups/sidi-achour-orders-pre-category-titles-20260909-123538.sql`, SHA-256 `74000f5a58f40734c05d42feaa51827eedd9ce1394e492d9489a611f01a143e9`.

The immediate pre/post order-state exports both have SHA-256 `6e45e4e6ccc9b5b0f732fdb483bdf3407ed7126c40748fb9caa853d1e414cd56`.
