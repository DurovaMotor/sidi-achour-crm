PRAGMA foreign_keys = ON;

UPDATE admin_users
SET
  password_hash = 'p8Hv6akKau8jZkfjNmqBu1izM3r9sv5QdZBgU4H6Ixo=',
  password_iterations = 100000,
  updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE username = 'Adam';
