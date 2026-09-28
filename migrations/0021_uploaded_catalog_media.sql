CREATE TABLE uploaded_catalog_media_chunks (
  media_key TEXT NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('original', 'preview', 'french')),
  chunk_index INTEGER NOT NULL,
  content_type TEXT NOT NULL,
  encrypted_bytes BLOB NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  PRIMARY KEY (media_key, kind, chunk_index)
);

CREATE INDEX idx_uploaded_catalog_media_lookup
  ON uploaded_catalog_media_chunks(media_key, kind, chunk_index);
