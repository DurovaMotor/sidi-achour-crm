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
