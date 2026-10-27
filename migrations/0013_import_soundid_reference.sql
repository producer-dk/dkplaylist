-- User identified software used in target tuning broadcast.
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-dd3145b4a23a2ac7-WKn5s5sc0C0','ref-dd3145b4a23a2ac7','Sonarworks SoundID Reference','소프트웨어','WKn5s5sc0C0','제2막','분리수거','Ddms66Djemg','2024-04-21');
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('3fc18d2af9d0ca27f822fb03','ref-dd3145b4a23a2ac7');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-dd3145b4a23a2ac7','Sonarworks');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-dd3145b4a23a2ac7' WHERE id='3fc18d2af9d0ca27f822fb03' AND status='needs_product_review';
