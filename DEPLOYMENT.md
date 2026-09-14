# HighTac → Sidi Achour

Production: https://sidi-achour-crm.pages.dev/

## Hosting

- Cloudflare Pages serves `public/`. Product media under `public/media/catalog/` consists of 1,052 encrypted `.bin` files: 526 originals and 526 watermarked previews.
- Pages Functions handles `/api/*`, including authenticated AES-GCM decryption of watermarked product previews at `/api/media/*`.
- D1 binding `DB` uses `sidi-achour-orders` (`36a123f5-7509-41d8-a690-13be0ec02524`).
- No R2 bucket, binding, subscription, or runtime request is required.

The local `r2-assets/` staging directory remains ignored by Git. `seed/r2-manifest.json` and D1 column `product_images.r2_key` retain their original logical names. Product APIs map those keys to `/api/media/`; the Function fetches the corresponding `.preview.bin`, decrypts it with Pages Secret `CATALOG_MEDIA_AES_KEY`, and returns only the watermarked preview. Encrypted originals are deployed as `.original.bin` without a plaintext endpoint.

## Deploy

Run the release entry point from this directory:

```powershell
.\deploy.ps1
```

The script generates a unique version and random release-ID JS/CSS files under `public/build/`, writes them to the page and `public/version.json`, and attaches the same release reference/message to the Cloudflare deployment record. Release-ID assets are immutable; the current and immediately previous asset pair are retained during each publication. The script does not hash local source, resource, or build files. It also records the returned Cloudflare deployment ID under `deployment-history/`.

Deploy only `public/`, with the sibling `functions/` directory. The older root-level HTML, JavaScript, CSS, `assets/`, and `data/` are not the current deployment.

Product image updates belong in the Git-ignored `private/catalog-originals/` directory. Run the in-memory key rotation and encryption workflow, then deploy:

```powershell
.\scripts\rotate_catalog_media_key.ps1 -PythonExecutable python
.\deploy.ps1
```

`rotate_catalog_media_key.ps1` generates a fresh 32-byte key in memory, runs `scripts/encrypt_catalog_media.py`, writes the same value to the production Pages Secret, clears the process environment variable and never creates a key file. The encryption script creates a 640px-long-edge repeated-watermark preview, encrypts both original and preview with AES-256-GCM using unique IVs and path-bound additional authenticated data, verifies decryption before replacing `public/media/catalog/`, and leaves no plaintext catalog file in `public/`.

New price, quantity and remark edits save directly to D1 through the API and need no deployment.

## Data

The initial schema and data are already present in D1 and migration `0001_initial.sql` is recorded. Do not re-import the initial seed into the live database. Future schema changes belong in new migrations.

- 35 categories, 637 independently editable product rows, 543 image relationships, 42 import quota rows.
- Order state is keyed by `record_id`; duplicate product codes remain independent rows.
- Rightmost frozen columns: new price, quantity, remark.
- Amount numerator: ordered quantity × new CNY price when filled; otherwise the original CNY unit price. A new price of zero is valid; an empty value is stored as NULL.
- Chinese shows the original price and an editable new price. French exposes no new-price editor; its single `Prix` column shows the new price when present and otherwise the original price.
- Migration `0002_new_price.sql` adds the nullable new price and updates category totals. Apply it before deploying the corresponding Functions.
- Amount denominator: import quota USD × 6.67.
- Fixed exchange-rate notice appears in both Chinese and French.
- For the 21 kg-quota categories, the numerator is `ordered quantity × unit weight (kg)`. Unit weight is derived from `产品数据库.xlsx` as `毛重(KG) ÷ 每箱数量(CTN)` and stored with row-level provenance.
- Migration `0003_weight_basis.sql` snapshots the previous 384 product weights and 21 category modes before switching kg categories to weight calculations. It never writes `product_order_state`.
- Migration `0004_tire_remarks.sql` maps 71 tire records to the `Quotation` sheet's `Remarks` cells using TL/TT, original number and A/B/C tier. It snapshots both localized row JSON values before updating them and never writes `product_order_state`.
- Migration `0005_category_titles.sql` maps all 35 categories to every distinct value in `Sidi.xlsx` `Licence!D5:D46`; French uses the source text verbatim and Chinese stores a segment-by-segment translation. Previous titles are retained in a rollback table.
- Migration `0006_sidi_priority_and_inner_tubes.sql` adds two exact-code inner-tube products from `产品编码转录.xlsx` and `产品数据库.xlsx`, updates the `TL-16-C` catalog Remarks value, and creates `sidi_priority_order_state` plus its independent category-stat view. It never writes `product_order_state`.
- Migration `0007_bicycle_tire_catalog.sql` replaces the two bicycle-tyre quote placeholders with 27 customer-facing rows: 9 black outer tyres, 9 grade-A inner tubes and 9 grade-B inner tubes. It stores only final literal prices and no pricing formulas.
- Migration `0008_customer_text_safety.sql` removes a legacy internal note from customer-facing catalog data. Product and export APIs also suppress any future line explicitly labeled as a purchase or cost price.
- Migration `0009_group_bicycle_tires_by_size.sql` orders the 27 bicycle tyre rows by size, then keeps identical product codes together in outer-tyre, grade-A inner-tube and grade-B inner-tube order.
- Migration `0010_bicycle_product_code_suffixes.sql` adds the customer-facing code suffixes `-WT`, `-A` and `-B` to bicycle outer tyres, grade-A inner tubes and grade-B inner tubes while preserving record IDs and order state.
- Migration `0011_bicycle_historical_sales_sort.sql` follows the matching row order in `自行车轮胎历史销量_合并去售价.xlsx`; same-size codes remain adjacent and each base-code group stays in `-WT`, `-A`, `-B` order.
- Migration `0012_bicycle_supplier_codes.sql` puts supplier code `A1154` on grade-A bicycle inner tubes and `A1155` on bicycle outer tyres and grade-B inner tubes in the combined specification/model column.
- Migration `0013_remove_djj_bicycle_outer_tires.sql` removes the three `DJJ-WT` bicycle outer-tyre rows while retaining all `DJJ-A` and `DJJ-B` inner-tube rows. It snapshots the deleted products and dependent state for rollback.
- The production backup and exact order-state snapshot are kept in the locally ignored `backups/` directory. Targeted rollback is documented in `rollback/README.md`.

## Verified online

- 50 rows on pages 1 and 2; 13 rows on page 13.
- Entering 120 at CNY 2.50 updates the category amount to CNY 300 immediately.
- Quantity and bilingual remarks survive a page reload; verification values were restored to zero/empty.
- Both logo responses exactly match the original files.
- Desktop widths from 981px show every language-appropriate column without horizontal table scrolling.
- At mobile widths, no document overflow or clipped fraction text; the rightmost editable columns remain fixed during table scrolling.
- Desktop and mobile support Chinese/French switching.
- Selecting the tire category changes the specification header to `Remarks`; all 71 tire rows display the same source-cell value in Chinese and French.
- The header and splash use only the Sidi Achour Logo. The splash is centered at every viewport and uses the NVIDIA-derived 2px geometry, 1px gray rule, deep-red/black surface and Microsoft YaHei font stack.
- The Sidi Achour Logo uses the transparent RGBA source and a SHA-256 fingerprinted filename; the splash renders it directly over a white-to-red-and-black gradient without a separate carrier surface.
- French hides the product-code column at every breakpoint; Chinese retains it.
- `/` is the French entry point. `/Adam` is served by the generated `public/Adam.html` clean URL and selects Chinese from the path. The language-switch buttons have been removed.
- `/Sidi` is a French clean URL backed by `public/Sidi.html`; it reads and writes the separate customer priority quantity/remark table while continuing to display prices from the primary price state.
- Chinese-only header actions open a Chinese/French export choice and export all positive-quantity orders through the read-only `/api/export/orders` endpoint. The standard workbook embeds product images and codes; the redacted workbook omits both.
- Excel exports contain one localized `订单` or `Commande` sheet with Microsoft YaHei, black headers, a red total rule, frozen headings, CNY number formats and readable column widths. The vendored ExcelJS browser bundle uses a content-fingerprinted filename.
- Export requests execute SELECT statements only and never write D1.
- Product image URLs use `/api/media/*`; plaintext `/media/catalog/*.webp` paths return 404, and direct static catalog traversal exposes only `.bin` ciphertext.
- Ctrl+S/Cmd+S, Ctrl+P/Cmd+P, all page context menus and image drag starts are prevented by the client interface.
- Earlier Pages deployments that contained plaintext catalog images were deleted after the encrypted deployment passed production checks.
