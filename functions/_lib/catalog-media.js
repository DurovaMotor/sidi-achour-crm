const MAGIC = new TextEncoder().encode("SIDIIMG1");
const IV_BYTES = 12;
const TAG_BYTES = 16;

function decodeBase64Key(encoded) {
  if (typeof encoded !== "string" || !encoded) throw new Error("Catalog media key is unavailable");
  let binary;
  try {
    binary = atob(encoded);
  } catch {
    throw new Error("Catalog media key is invalid");
  }
  const key = Uint8Array.from(binary, (character) => character.charCodeAt(0));
  if (key.byteLength !== 32) throw new Error("Catalog media key has an invalid length");
  return key;
}

function validateEnvelope(bytes) {
  if (bytes.byteLength < MAGIC.byteLength + IV_BYTES + TAG_BYTES) {
    throw new Error("Encrypted catalog media is truncated");
  }
  for (let index = 0; index < MAGIC.byteLength; index += 1) {
    if (bytes[index] !== MAGIC[index]) throw new Error("Encrypted catalog media has an invalid header");
  }
}

export function contentTypeForMediaKey(mediaKey) {
  const extension = mediaKey.split(".").pop().toLowerCase();
  if (extension === "webp") return "image/webp";
  if (extension === "png") return "image/png";
  if (extension === "jpg" || extension === "jpeg") return "image/jpeg";
  throw new Error("Unsupported catalog media type");
}

export async function decryptCatalogMedia(envelope, encodedKey, mediaKey, kind = "preview") {
  const bytes = new Uint8Array(envelope);
  validateEnvelope(bytes);
  const ivStart = MAGIC.byteLength;
  const ciphertextStart = ivStart + IV_BYTES;
  const iv = bytes.slice(ivStart, ciphertextStart);
  const ciphertext = bytes.slice(ciphertextStart);
  const key = await crypto.subtle.importKey(
    "raw",
    decodeBase64Key(encodedKey),
    { name: "AES-GCM" },
    false,
    ["decrypt"],
  );
  const additionalData = new TextEncoder().encode(`sidi-catalog:v1:${kind}:${mediaKey}`);
  return crypto.subtle.decrypt({ name: "AES-GCM", iv, additionalData }, key, ciphertext);
}
