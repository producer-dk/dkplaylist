CREATE TABLE IF NOT EXISTS catalog_name_reviews (
 review_id TEXT NOT NULL, gear_id TEXT NOT NULL, before_json TEXT NOT NULL,
 after_json TEXT NOT NULL, reviewed_at TEXT NOT NULL DEFAULT (datetime('now')),
 PRIMARY KEY(review_id,gear_id));
