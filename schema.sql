-- Apply once to the D1 database. Existing users and votes are preserved.
CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY, google_sub TEXT NOT NULL UNIQUE, nickname TEXT, nickname_key TEXT UNIQUE, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS entries (id TEXT PRIMARY KEY,gear_id TEXT NOT NULL,gear_name TEXT NOT NULL,category TEXT NOT NULL,video TEXT NOT NULL,title TEXT NOT NULL,artist TEXT NOT NULL,broadcast TEXT,source_date TEXT NOT NULL,created_by TEXT REFERENCES users(id),created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,UNIQUE(gear_id,video));
CREATE TABLE IF NOT EXISTS votes (user_id TEXT NOT NULL REFERENCES users(id),entry_id TEXT NOT NULL REFERENCES entries(id),direction TEXT NOT NULL CHECK(direction IN ('gear','song')),target_id TEXT NOT NULL,created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY(user_id,entry_id,direction));
CREATE INDEX IF NOT EXISTS votes_target ON votes(user_id,direction,target_id);
CREATE INDEX IF NOT EXISTS votes_entry ON votes(entry_id,direction);
CREATE TRIGGER IF NOT EXISTS votes_validate BEFORE INSERT ON votes BEGIN SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM entries WHERE id=NEW.entry_id AND CASE WHEN NEW.direction='gear' THEN gear_id ELSE video END=NEW.target_id) THEN RAISE(ABORT,'invalid_target') END; SELECT CASE WHEN (SELECT count(*) FROM votes WHERE user_id=NEW.user_id AND direction=NEW.direction AND target_id=NEW.target_id)>=3 THEN RAISE(ABORT,'limit3') END; END;
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g0-qR2pggPX_Sc','g0','SeeAudio Bravo','이어폰','qR2pggPX_Sc','Wishing Umbrella','UI Shigure','XaiQTmkl7qY','2026-10-15');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g0-59FJdI4DGi0','g0','SeeAudio Bravo','이어폰','59FJdI4DGi0','DJ Mocha','Feel','XaiQTmkl7qY','2026-10-15');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g0-7mZlRSAUSsU','g0','SeeAudio Bravo','이어폰','7mZlRSAUSsU','Tori No Uta','VISUAL ARTS, Key','XaiQTmkl7qY','2026-10-15');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g0-TZBmS7zvCNc','g0','SeeAudio Bravo','이어폰','TZBmS7zvCNc','Love Charity','딜라이트(Delight)','XaiQTmkl7qY','2026-10-15');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g0-t9eAg7Nhq-o','g0','SeeAudio Bravo','이어폰','t9eAg7Nhq-o','Let Mom Sleep','Hideki Naganuma','XaiQTmkl7qY','2026-10-15');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g1-JkB41jZtyrQ','g1','Juzear Nimbus','이어폰','JkB41jZtyrQ','Memories','beabadoobee','wdo4zFL91Vs','2026-10-08');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g1-R9miRFaYbWo','g1','Juzear Nimbus','이어폰','R9miRFaYbWo','Candy Pink Magic Hole Flip Phone','KiiiKiii','wdo4zFL91Vs','2026-10-08');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g1-j5MKeHn_0v0','g1','Juzear Nimbus','이어폰','j5MKeHn_0v0','Tastes Like Summer','James Blunt','wdo4zFL91Vs','2026-10-08');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g1-nP1xjFX86Po','g1','Juzear Nimbus','이어폰','nP1xjFX86Po','이 별로부터','IU','wdo4zFL91Vs','2026-10-08');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g2-7lnZ30QvvqQ','g2','Kennerton Vinneta','헤드폰','7lnZ30QvvqQ','Home','Fickle Friends','hxJuaIKpyD8','2026-09-29');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g2-92oT9rvnr_E','g2','Kennerton Vinneta','헤드폰','92oT9rvnr_E','It don''t Matter to Me','Bread','hxJuaIKpyD8','2026-09-29');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g2-ZU5MAitxtfY','g2','Kennerton Vinneta','헤드폰','ZU5MAitxtfY','Jenina','Kanako Wada','hxJuaIKpyD8','2026-09-29');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g2-ZdbGDLC4qhI','g2','Kennerton Vinneta','헤드폰','ZdbGDLC4qhI','We''re All Alone','Rita Coolidge','hxJuaIKpyD8','2026-09-29');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g2-BVqHA9Bb8jo','g2','Kennerton Vinneta','헤드폰','BVqHA9Bb8jo','One Hundred Ways','Quincy Jones, James Ingram','hxJuaIKpyD8','2026-09-29');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g3-oZrZNbReL8k','g3','Cayin HA-300 MK3','앰프','oZrZNbReL8k','To Ease You','Men I Trust','br3LXTCCPOo','2026-09-17');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g3-aTKEhjImAbk','g3','Cayin HA-300 MK3','앰프','aTKEhjImAbk','Soften','Laura Misch','br3LXTCCPOo','2026-09-17');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g3-swMIr3U_Ktg','g3','Cayin HA-300 MK3','앰프','swMIr3U_Ktg','Hey Hi','KiiiKiii','br3LXTCCPOo','2026-09-17');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g3-N2GecyozKEo','g3','Cayin HA-300 MK3','앰프','N2GecyozKEo','Lonely Girl','Yui','br3LXTCCPOo','2026-09-17');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g4-sD1iBAKplqQ','g4','Audeze Maxwell 2 ANC','헤드폰','sD1iBAKplqQ','Bish Bash Bosh','MIMI','jr98zX4Zcvw','2026-09-10');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g4-Ob_EDY9Eiis','g4','Audeze Maxwell 2 ANC','헤드폰','Ob_EDY9Eiis','WannaCry','Ninajirachi & Porter Robinson','jr98zX4Zcvw','2026-09-10');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g4-_tN91WXp5Rw','g4','Audeze Maxwell 2 ANC','헤드폰','_tN91WXp5Rw','얼마나 좋을까','이수영','jr98zX4Zcvw','2026-09-10');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g5-sLk8zWUuYTA','g5','Aune AR9000','헤드폰','sLk8zWUuYTA','Vitamin ME','fromis_9','et7ibeUo2i8','2026-09-03');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g5-i5CVOiDyXu8','g5','Aune AR9000','헤드폰','i5CVOiDyXu8','Amber','Maddie Ashman','et7ibeUo2i8','2026-09-03');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g5-sMO87qJnpzg','g5','Aune AR9000','헤드폰','sMO87qJnpzg','Sky Restaurant','Hi-Fi Set','et7ibeUo2i8','2026-09-03');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g5-jol-ff1EcZw','g5','Aune AR9000','헤드폰','jol-ff1EcZw','Momoiro Kataomoi(Cover)','Momone Chinoi','et7ibeUo2i8','2026-09-03');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g5-8pTejvbf5PM','g5','Aune AR9000','헤드폰','8pTejvbf5PM','Spin The Marvin','Uwanosora','et7ibeUo2i8','2026-09-03');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g6-lBOQpZ56-gY','g6','LAiV Crescendo VERSE','DAC / 앰프','lBOQpZ56-gY','I''m gonna make it shine','더베인(THE VANE)','rw4GJDo8zJk','2026-08-25');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g6-EN1lQPxjRv4','g6','LAiV Crescendo VERSE','DAC / 앰프','EN1lQPxjRv4','Rescue','더베인(THE VANE)','rw4GJDo8zJk','2026-08-25');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g6-1Sdt8-BZJOE','g6','LAiV Crescendo VERSE','DAC / 앰프','1Sdt8-BZJOE','HOURS','SHINee','rw4GJDo8zJk','2026-08-25');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g6-eO3zsYsDnbI','g6','LAiV Crescendo VERSE','DAC / 앰프','eO3zsYsDnbI','Camera','Charli xcx','rw4GJDo8zJk','2026-08-25');
INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('g6-YkG62bOqCwg','g6','LAiV Crescendo VERSE','DAC / 앰프','YkG62bOqCwg','NENDO','Caffeine Junkie','rw4GJDo8zJk','2026-08-25');
CREATE TABLE IF NOT EXISTS lookup_cache (key TEXT PRIMARY KEY,payload TEXT NOT NULL,expires_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS lookup_limits (key TEXT PRIMARY KEY,used INTEGER NOT NULL DEFAULT 0);

-- Full Reference Player archive; ambiguous product mappings stay out of entries.
CREATE TABLE IF NOT EXISTS reference_sources (id TEXT PRIMARY KEY,source_url TEXT NOT NULL,broadcast TEXT,source_date TEXT NOT NULL,subject TEXT NOT NULL,payload TEXT NOT NULL,gear_id TEXT NOT NULL DEFAULT '',status TEXT NOT NULL);
CREATE INDEX IF NOT EXISTS reference_sources_status ON reference_sources(status);
CREATE TABLE IF NOT EXISTS reference_products(source_id TEXT NOT NULL REFERENCES reference_sources(id),gear_id TEXT NOT NULL,PRIMARY KEY(source_id,gear_id));
CREATE INDEX IF NOT EXISTS reference_products_gear ON reference_products(gear_id);
INSERT OR IGNORE INTO reference_products(source_id,gear_id) SELECT id,gear_id FROM reference_sources WHERE gear_id<>'';
CREATE TABLE IF NOT EXISTS sessions(token_hash TEXT PRIMARY KEY,user_id TEXT NOT NULL REFERENCES users(id),expires_at INTEGER NOT NULL);
CREATE INDEX IF NOT EXISTS sessions_expiry ON sessions(expires_at);
CREATE TABLE IF NOT EXISTS user_permissions(user_id TEXT PRIMARY KEY REFERENCES users(id),role TEXT NOT NULL CHECK(role IN ('member','admin','owner')));
CREATE TABLE IF NOT EXISTS gear_metadata(gear_id TEXT PRIMARY KEY,brand TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS edit_history(id INTEGER PRIMARY KEY AUTOINCREMENT,actor_id TEXT NOT NULL REFERENCES users(id),kind TEXT NOT NULL,target_id TEXT NOT NULL,before_json TEXT NOT NULL,after_json TEXT NOT NULL,created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE IF NOT EXISTS catalog_name_reviews (
 review_id TEXT NOT NULL, gear_id TEXT NOT NULL, before_json TEXT NOT NULL,
 after_json TEXT NOT NULL, reviewed_at TEXT NOT NULL DEFAULT (datetime('now')),
 PRIMARY KEY(review_id,gear_id));

CREATE TABLE IF NOT EXISTS catalog_category_reviews (
 review_id TEXT NOT NULL, gear_id TEXT NOT NULL, before_category TEXT NOT NULL,
 after_category TEXT NOT NULL, reviewed_at TEXT NOT NULL DEFAULT (datetime('now')),
 PRIMARY KEY(review_id,gear_id));
