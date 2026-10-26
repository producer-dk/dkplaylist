CREATE TABLE IF NOT EXISTS catalog_category_reviews (
 review_id TEXT NOT NULL, gear_id TEXT NOT NULL, before_category TEXT NOT NULL,
 after_category TEXT NOT NULL, reviewed_at TEXT NOT NULL DEFAULT (datetime('now')),
 PRIMARY KEY(review_id,gear_id));
