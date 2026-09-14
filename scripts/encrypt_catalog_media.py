import base64
import io
import json
import os
import shutil
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from PIL import Image, ImageDraw, ImageFont, ImageOps


MAGIC = b"SIDIIMG1"
PREVIEW_LONG_EDGE = 640
FRENCH_PREVIEW_LONG_EDGE = 96
SUPPORTED_EXTENSIONS = {".webp", ".png", ".jpg", ".jpeg"}
WATERMARK_TEXT = "SIDI ACHOUR  HIGHTAC"

PROJECT_ROOT = Path(__file__).resolve().parents[1]
PUBLIC_MEDIA_ROOT = PROJECT_ROOT / "public" / "media"
PUBLIC_CATALOG = PUBLIC_MEDIA_ROOT / "catalog"
STAGING_CATALOG = PUBLIC_MEDIA_ROOT / "catalog-encrypted-staging"
PRIVATE_ROOT = PROJECT_ROOT / "private"
PRIVATE_CATALOG = PRIVATE_ROOT / "catalog-originals"
PRIVATE_DEPLOYMENT_BACKUP = PRIVATE_ROOT / "catalog-public-before-encryption"


def require_scoped_path(path: Path, parent: Path) -> None:
    resolved_path = path.resolve()
    resolved_parent = parent.resolve()
    if not resolved_path.is_relative_to(resolved_parent):
        raise RuntimeError(f"Path is outside the intended project scope: {resolved_path}")


def load_key() -> bytes:
    encoded = os.environ.get("CATALOG_MEDIA_AES_KEY", "")
    try:
        key = base64.b64decode(encoded, validate=True)
    except Exception as error:
        raise RuntimeError("CATALOG_MEDIA_AES_KEY must be valid base64") from error
    if len(key) != 32:
        raise RuntimeError("CATALOG_MEDIA_AES_KEY must decode to exactly 32 bytes")
    return key


def find_font(size: int):
    for candidate in (
        Path("C:/Windows/Fonts/msyhbd.ttc"),
        Path("C:/Windows/Fonts/arialbd.ttf"),
        Path("C:/Windows/Fonts/arial.ttf"),
    ):
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default(size=size)


def create_watermark_tile(font, long_edge: int) -> Image.Image:
    probe = Image.new("RGBA", (1, 1), (0, 0, 0, 0))
    draw = ImageDraw.Draw(probe)
    stroke_width = 2 if long_edge >= 320 else 1
    left, top, right, bottom = draw.textbbox((0, 0), WATERMARK_TEXT, font=font, stroke_width=stroke_width)
    padding_x = max(24, round(long_edge * 0.1375))
    padding_y = max(18, round(long_edge * 0.1))
    tile = Image.new("RGBA", (right - left + padding_x, bottom - top + padding_y), (0, 0, 0, 0))
    tile_draw = ImageDraw.Draw(tile)
    tile_draw.text(
        (tile.width // 2, tile.height // 2),
        WATERMARK_TEXT,
        font=font,
        anchor="mm",
        fill=(255, 255, 255, 92),
        stroke_width=stroke_width,
        stroke_fill=(0, 0, 0, 72),
    )
    return tile.rotate(28, expand=True, resample=Image.Resampling.BICUBIC)


def watermark_preview(source_path: Path, long_edge: int, quality: int, allow_upscale: bool) -> bytes:
    with Image.open(source_path) as opened:
        image = ImageOps.exif_transpose(opened).convert("RGBA")
        scale = long_edge / max(image.width, image.height)
        if not allow_upscale:
            scale = min(1, scale)
        target_size = (max(1, round(image.width * scale)), max(1, round(image.height * scale)))
        image = image.resize(target_size, Image.Resampling.LANCZOS)

    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    minimum_font = 18 if long_edge >= 320 else 7
    tile = create_watermark_tile(find_font(max(minimum_font, round(long_edge * 0.035))), long_edge)
    step_x = max(round(long_edge * 0.28), tile.width - max(8, round(long_edge * 0.044)))
    step_y = max(round(long_edge * 0.15), tile.height - max(6, round(long_edge * 0.019)))
    for row, y in enumerate(range(-tile.height, image.height + tile.height, step_y)):
        offset = -step_x // 2 if row % 2 else 0
        for x in range(-tile.width + offset, image.width + tile.width, step_x):
            overlay.alpha_composite(tile, (x, y))

    preview = Image.alpha_composite(image, overlay)
    output = io.BytesIO()
    extension = source_path.suffix.lower()
    if extension == ".webp":
        preview.save(output, format="WEBP", quality=quality, method=6)
    elif extension == ".png":
        preview.save(output, format="PNG", optimize=True)
    else:
        background = Image.new("RGB", preview.size, "white")
        background.paste(preview, mask=preview.getchannel("A"))
        background.save(output, format="JPEG", quality=quality, optimize=True, progressive=True)
    return output.getvalue()


def encrypt_bytes(plaintext: bytes, key: bytes, media_key: str, kind: str) -> bytes:
    nonce = os.urandom(12)
    aad = f"sidi-catalog:v1:{kind}:{media_key}".encode("utf-8")
    aes = AESGCM(key)
    encrypted = aes.encrypt(nonce, plaintext, aad)
    if aes.decrypt(nonce, encrypted, aad) != plaintext:
        raise RuntimeError(f"AES-GCM round-trip failed for {media_key} ({kind})")
    return MAGIC + nonce + encrypted


def prepare_private_sources() -> list[Path]:
    require_scoped_path(PUBLIC_CATALOG, PUBLIC_MEDIA_ROOT)
    require_scoped_path(PRIVATE_CATALOG, PRIVATE_ROOT)
    plaintext_public = sorted(
        path for path in PUBLIC_CATALOG.rglob("*")
        if path.is_file() and path.suffix.lower() in SUPPORTED_EXTENSIONS
    ) if PUBLIC_CATALOG.exists() else []

    PRIVATE_CATALOG.mkdir(parents=True, exist_ok=True)
    for source in plaintext_public:
        relative = source.relative_to(PUBLIC_CATALOG)
        destination = PRIVATE_CATALOG / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        if destination.exists() and destination.read_bytes() != source.read_bytes():
            raise RuntimeError(f"Private source differs from public source: {relative.as_posix()}")
        if not destination.exists():
            shutil.copy2(source, destination)

    sources = sorted(
        path for path in PRIVATE_CATALOG.rglob("*")
        if path.is_file() and path.suffix.lower() in SUPPORTED_EXTENSIONS
    )
    if not sources:
        raise RuntimeError("No private catalog source images were found")
    return sources


def process_source(source: Path, key: bytes) -> dict:
    relative = source.relative_to(PRIVATE_CATALOG)
    media_key = (Path("catalog") / relative).as_posix()
    original = source.read_bytes()
    preview = watermark_preview(source, PREVIEW_LONG_EDGE, 82, True)
    french_preview = watermark_preview(source, FRENCH_PREVIEW_LONG_EDGE, 68, False)

    original_target = STAGING_CATALOG / Path(f"{relative.as_posix()}.original.bin")
    preview_target = STAGING_CATALOG / Path(f"{relative.as_posix()}.preview.bin")
    french_target = STAGING_CATALOG / Path(f"{relative.as_posix()}.french.bin")
    original_target.parent.mkdir(parents=True, exist_ok=True)
    original_target.write_bytes(encrypt_bytes(original, key, media_key, "original"))
    preview_target.write_bytes(encrypt_bytes(preview, key, media_key, "preview"))
    french_target.write_bytes(encrypt_bytes(french_preview, key, media_key, "french"))

    with Image.open(io.BytesIO(preview)) as image:
        preview_size = image.size
    with Image.open(io.BytesIO(french_preview)) as image:
        french_size = image.size
    return {
        "originalBytes": len(original),
        "previewBytes": len(preview),
        "previewWidth": preview_size[0],
        "previewHeight": preview_size[1],
        "frenchBytes": len(french_preview),
        "frenchWidth": french_size[0],
        "frenchHeight": french_size[1],
    }


def replace_public_catalog(expected_files: int) -> None:
    staged_files = [path for path in STAGING_CATALOG.rglob("*") if path.is_file()]
    if len(staged_files) != expected_files * 3:
        raise RuntimeError(f"Expected {expected_files * 3} encrypted files, found {len(staged_files)}")
    if any(path.suffix.lower() != ".bin" for path in staged_files):
        raise RuntimeError("Encrypted catalog staging contains a non-.bin file")

    require_scoped_path(STAGING_CATALOG, PUBLIC_MEDIA_ROOT)
    require_scoped_path(PRIVATE_DEPLOYMENT_BACKUP, PRIVATE_ROOT)
    if PRIVATE_DEPLOYMENT_BACKUP.exists():
        shutil.rmtree(PRIVATE_DEPLOYMENT_BACKUP)
    if PUBLIC_CATALOG.exists():
        PUBLIC_CATALOG.rename(PRIVATE_DEPLOYMENT_BACKUP)
    try:
        STAGING_CATALOG.rename(PUBLIC_CATALOG)
    except Exception:
        if not PUBLIC_CATALOG.exists() and PRIVATE_DEPLOYMENT_BACKUP.exists():
            PRIVATE_DEPLOYMENT_BACKUP.rename(PUBLIC_CATALOG)
        raise
    if PRIVATE_DEPLOYMENT_BACKUP.exists():
        shutil.rmtree(PRIVATE_DEPLOYMENT_BACKUP)


def main() -> None:
    key = load_key()
    sources = prepare_private_sources()
    require_scoped_path(STAGING_CATALOG, PUBLIC_MEDIA_ROOT)
    if STAGING_CATALOG.exists():
        shutil.rmtree(STAGING_CATALOG)
    STAGING_CATALOG.mkdir(parents=True)

    results = []
    workers = min(6, max(2, os.cpu_count() or 2))
    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = [executor.submit(process_source, source, key) for source in sources]
        for index, future in enumerate(as_completed(futures), start=1):
            results.append(future.result())
            if index % 50 == 0 or index == len(futures):
                print(f"Processed {index}/{len(futures)} catalog images", flush=True)

    replace_public_catalog(len(sources))
    print(json.dumps({
        "sourceImages": len(sources),
        "encryptedOriginals": len(sources),
        "encryptedPreviews": len(sources),
        "encryptedFrenchPreviews": len(sources),
        "plaintextCatalogFiles": 0,
        "previewLongEdge": PREVIEW_LONG_EDGE,
        "frenchPreviewLongEdge": FRENCH_PREVIEW_LONG_EDGE,
        "originalBytes": sum(item["originalBytes"] for item in results),
        "previewBytes": sum(item["previewBytes"] for item in results),
        "frenchPreviewBytes": sum(item["frenchBytes"] for item in results),
        "previewDimensionsValid": all(
            max(item["previewWidth"], item["previewHeight"]) == PREVIEW_LONG_EDGE
            for item in results
        ),
        "frenchPreviewDimensionsValid": all(
            max(item["frenchWidth"], item["frenchHeight"]) <= FRENCH_PREVIEW_LONG_EDGE
            for item in results
        ),
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()
