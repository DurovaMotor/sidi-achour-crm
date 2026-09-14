# Production D1 snapshot

`sidi-achour-orders-production.sql` is a complete SQL export of the production Cloudflare D1 database bound as `DB` in `wrangler.jsonc`.

The snapshot contains operational order state and must remain in the private `DurovaMotor/sidi-achour-crm` repository. It contains no environment files, OAuth credentials, API tokens or private keys.

## Verify locally

Restore the snapshot into a disposable local D1 database or an empty SQLite database before using it for recovery work. Do not apply it to production unless a complete restore is explicitly intended.

```powershell
npx --yes wrangler@4.129.1 d1 execute sidi-achour-orders --local --file database/sidi-achour-orders-production.sql
```

The matching export time and row counts are recorded in `snapshot.json`. Future snapshot updates use Git diffs and row counts rather than local file hash checks.
