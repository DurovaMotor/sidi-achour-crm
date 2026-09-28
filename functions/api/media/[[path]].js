import { contentTypeForMediaKey, decryptCatalogMedia } from "../../_lib/catalog-media.js";
import { readAdamSession, unauthorizedResponse } from "../../_lib/adam-auth.js";

const MAX_ENCRYPTED_PREVIEW_BYTES = 3 * 1024 * 1024;
const SAFE_SEGMENT = /^[A-Za-z0-9._*-]+$/;

function mediaKeyFromParams(value) {
  const segments = Array.isArray(value) ? value : [value];
  if (!segments.length || segments.some((segment) => !segment || segment === "." || segment === ".." || !SAFE_SEGMENT.test(segment))) {
    throw new Error("Invalid catalog media path");
  }
  const mediaKey = segments.join("/");
  if (!mediaKey.startsWith("catalog/")) throw new Error("Invalid catalog media scope");
  return mediaKey;
}

export async function onRequestGet(context) {
  let mediaKey;
  try {
    mediaKey = mediaKeyFromParams(context.params.path);
    const isFrench = new URL(context.request.url).searchParams.get("variant") === "fr";
    if (!isFrench && !await readAdamSession(context.request, context.env.ADAM_SESSION_SECRET)) {
      return unauthorizedResponse();
    }
    const kind = isFrench ? "french" : "original";
    let encrypted;
    let contentType;
    if (mediaKey.startsWith("catalog/v1/uploads/")) {
      const uploaded = await context.env.DB.prepare(`
        SELECT chunk_index, content_type, encrypted_bytes
        FROM uploaded_catalog_media_chunks
        WHERE media_key = ? AND kind = ?
        ORDER BY chunk_index
      `).bind(mediaKey, kind).all();
      if (!uploaded.results.length) return new Response("Not found", { status: 404 });
      const chunks = uploaded.results.map((row) => new Uint8Array(row.encrypted_bytes));
      const totalBytes = chunks.reduce((sum, chunk) => sum + chunk.byteLength, 0);
      const joined = new Uint8Array(totalBytes);
      let offset = 0;
      for (const chunk of chunks) {
        joined.set(chunk, offset);
        offset += chunk.byteLength;
      }
      encrypted = joined.buffer;
      contentType = uploaded.results[0].content_type;
    } else {
      const staticPath = `/media/${mediaKey.split("/").map(encodeURIComponent).join("/")}.${kind}.bin`;
      const encryptedResponse = await fetch(new URL(staticPath, context.request.url), {
        headers: { Accept: "application/octet-stream" },
      });
      if (!encryptedResponse.ok) return new Response("Not found", { status: 404 });
      const declaredLength = Number(encryptedResponse.headers.get("Content-Length") ?? 0);
      if (declaredLength > MAX_ENCRYPTED_PREVIEW_BYTES) throw new Error("Encrypted preview exceeds the size limit");
      encrypted = await encryptedResponse.arrayBuffer();
      if (encrypted.byteLength > MAX_ENCRYPTED_PREVIEW_BYTES) throw new Error("Encrypted preview exceeds the size limit");
      contentType = contentTypeForMediaKey(mediaKey);
    }

    const decrypted = await decryptCatalogMedia(encrypted, context.env.CATALOG_MEDIA_AES_KEY, mediaKey, kind);
    return new Response(decrypted, {
      headers: {
        "Cache-Control": "public, max-age=3600",
        "Content-Type": contentType,
        "Cross-Origin-Resource-Policy": "same-origin",
        "X-Content-Type-Options": "nosniff",
        "X-Robots-Tag": "noindex, noarchive",
      },
    });
  } catch (error) {
    console.error(JSON.stringify({
      message: "catalog media decryption failed",
      mediaKey: mediaKey ?? null,
      error: error instanceof Error ? error.message : String(error),
    }));
    return new Response("Media unavailable", { status: 503 });
  }
}

export function onRequestHead() {
  return new Response(null, { status: 405, headers: { Allow: "GET" } });
}
