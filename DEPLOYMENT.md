# HighTac → Sidi Achour

Production: https://sidi-achour-crm.pages.dev/

## Hosting

- Cloudflare Pages serves `public/`, including the 527 original media files in `public/media/`.
- Pages Functions handles `/api/*` only.
- D1 binding `DB` uses `sidi-achour-orders` (`36a123f5-7509-41d8-a690-13be0ec02524`).
- No R2 bucket, binding, subscription, or runtime request is required.

The local `r2-assets/` staging directory is ignored by Git. `seed/r2-manifest.json` and D1 column `product_images.r2_key` retain their original names as source metadata. Their keys map directly to `/media/` static paths; they do not depend on R2. The committed `public/media/` files and the original staging files have identical SHA-256 hashes.

## Deploy

Run the release entry point from this directory:

```powershell
.\deploy.ps1
```

The script generates a unique version, writes it to the page and `public/version.json`, and attaches the same release hash/message to the Cloudflare deployment record. It also records the returned Cloudflare deployment ID under `deployment-history/`.

Deploy only `public/`, with the sibling `functions/` directory. The older root-level HTML, JavaScript, CSS, `assets/`, and `data/` are not the current deployment.

Image updates belong in `public/media/` and require a Pages deployment. New price, quantity and remark edits save directly to D1 through the API and need no deployment.

## Data

The initial schema and data are already present in D1 and migration `0001_initial.sql` is recorded. Do not re-import the initial seed into the live database. Future schema changes belong in new migrations.

- 35 categories, 613 independently editable product rows, 541 image relationships, 42 import quota rows.
- Order state is keyed by `record_id`; duplicate product codes remain independent rows.
- Rightmost frozen columns: new price, quantity, remark.
- Amount numerator: ordered quantity × new CNY price when filled; otherwise the original CNY unit price. A new price of zero is valid; an empty value is stored as NULL.
- Chinese shows the original price and an editable new price. French exposes no new-price editor; its single `Prix` column shows the new price when present and otherwise the original price.
- Migration `0002_new_price.sql` adds the nullable new price and updates category totals. Apply it before deploying the corresponding Functions.
- Amount denominator: import quota USD × 6.67.
- Fixed exchange-rate notice appears in both Chinese and French.
- Quantity fractions retain the source quota unit, including kg; no unit-weight conversion is inferred.

## Verified online

- 50 rows on pages 1 and 2; 13 rows on page 13.
- Entering 120 at CNY 2.50 updates the category amount to CNY 300 immediately.
- Quantity and bilingual remarks survive a page reload; verification values were restored to zero/empty.
- Both logo responses exactly match the original files.
- Desktop widths from 981px show every language-appropriate column without horizontal table scrolling.
- At mobile widths, no document overflow or clipped fraction text; the rightmost editable columns remain fixed during table scrolling.
- Desktop and mobile support Chinese/French switching.
