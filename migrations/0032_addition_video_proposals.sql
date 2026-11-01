CREATE TABLE IF NOT EXISTS addition_video_proposals (
 event_id INTEGER NOT NULL REFERENCES addition_events(id) ON DELETE CASCADE,
 review_id INTEGER NOT NULL REFERENCES addition_ai_reviews(id) ON DELETE CASCADE,
 video TEXT NOT NULL CHECK(length(video)=11),
 url TEXT NOT NULL,
 label TEXT NOT NULL,
 note TEXT NOT NULL DEFAULT '',
 sources_json TEXT NOT NULL DEFAULT '[]' CHECK(json_valid(sources_json)),
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(event_id,review_id,video)
);