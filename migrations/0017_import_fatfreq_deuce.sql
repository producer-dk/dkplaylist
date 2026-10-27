-- User identified FATfreq x HBB broadcast as Deuce.
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-0cfbf2bd145081a8-VhZk2yUO3AY','ref-0cfbf2bd145081a8','FATfreq Deuce','이어폰','VhZk2yUO3AY','R.E.M','KISS OF LIFE','74ELsTW-eew','2024-11-12');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-0cfbf2bd145081a8-97TN2ciZQZI','ref-0cfbf2bd145081a8','FATfreq Deuce','이어폰','97TN2ciZQZI','Dream Brother','Zedd, Jeff Buckley','74ELsTW-eew','2024-11-12');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-0cfbf2bd145081a8-VDClMJbdIKE','ref-0cfbf2bd145081a8','FATfreq Deuce','이어폰','VDClMJbdIKE','그때의 우리를 기억하나요','김수영','74ELsTW-eew','2024-11-12');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-0cfbf2bd145081a8-g4xXhY8F2wg','ref-0cfbf2bd145081a8','FATfreq Deuce','이어폰','g4xXhY8F2wg','Hidamari','Ms.OOJA','74ELsTW-eew','2024-11-12');
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('626a3ff5f72cc5a8a5ddc1e9','ref-0cfbf2bd145081a8');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-0cfbf2bd145081a8','FATfreq');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-0cfbf2bd145081a8' WHERE id='626a3ff5f72cc5a8a5ddc1e9' AND status='needs_product_review';
