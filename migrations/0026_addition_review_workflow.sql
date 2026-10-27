-- Append-only revisions: confirmation archives a revision, never deletes a song.
CREATE TABLE IF NOT EXISTS addition_events (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 entry_id TEXT NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
 title TEXT NOT NULL, artist TEXT NOT NULL, video TEXT NOT NULL,
 previous_title TEXT, previous_artist TEXT, previous_video TEXT,
 reason TEXT NOT NULL CHECK(reason IN ('added','edited')),
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS addition_events_entry ON addition_events(entry_id,id DESC);
CREATE TABLE IF NOT EXISTS addition_ai_reviews (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 event_id INTEGER NOT NULL REFERENCES addition_events(id) ON DELETE CASCADE,
 verdict TEXT NOT NULL CHECK(verdict IN ('verified','needs_attention')),
 note TEXT NOT NULL,
 sources_json TEXT NOT NULL CHECK(json_valid(sources_json)),
 reviewed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS addition_ai_reviews_event ON addition_ai_reviews(event_id,id DESC);
CREATE TABLE IF NOT EXISTS addition_confirmations (
 event_id INTEGER PRIMARY KEY REFERENCES addition_events(id) ON DELETE CASCADE,
 review_id INTEGER NOT NULL REFERENCES addition_ai_reviews(id),
 confirmed_by TEXT NOT NULL REFERENCES users(id),
 confirmed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TRIGGER IF NOT EXISTS addition_track_insert AFTER INSERT ON entries
WHEN NEW.created_by IS NOT NULL
BEGIN
 INSERT INTO addition_events(entry_id,title,artist,video,reason,created_at)
 VALUES(NEW.id,NEW.title,NEW.artist,NEW.video,'added',NEW.created_at);
END;
CREATE TRIGGER IF NOT EXISTS addition_track_update AFTER UPDATE OF title,artist,video ON entries
WHEN (OLD.title IS NOT NEW.title OR OLD.artist IS NOT NEW.artist OR OLD.video IS NOT NEW.video)
 AND (NEW.created_by IS NOT NULL OR EXISTS(SELECT 1 FROM addition_events WHERE entry_id=NEW.id))
BEGIN
 INSERT INTO addition_events(entry_id,title,artist,video,previous_title,previous_artist,previous_video,reason)
 VALUES(NEW.id,NEW.title,NEW.artist,NEW.video,OLD.title,OLD.artist,OLD.video,'edited');
END;
-- Idempotent backfill for existing user additions.
INSERT INTO addition_events(entry_id,title,artist,video,reason,created_at)
SELECT e.id,e.title,e.artist,e.video,'added',e.created_at FROM entries e
WHERE e.created_by IS NOT NULL AND NOT EXISTS(SELECT 1 FROM addition_events v WHERE v.entry_id=e.id) ORDER BY e.created_at,e.id;
