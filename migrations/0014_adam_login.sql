PRAGMA foreign_keys = ON;

CREATE TABLE admin_users (
  username TEXT PRIMARY KEY,
  password_salt TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  password_iterations INTEGER NOT NULL CHECK (password_iterations >= 100000),
  active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

INSERT INTO admin_users(
  username,
  password_salt,
  password_hash,
  password_iterations,
  active
) VALUES (
  'Adam',
  'LjsXDwLsnKxmSN8MDYr3cg==',
  't+sBeCcpaoqqqGOjSBkBb0zrx8WPzct/56c6tW4YGds=',
  210000,
  1
);
