-- User identified training broadcast device as TK Audio TKlizer.
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-f4fff5a16175c831-P29qO1OR2jY','ref-f4fff5a16175c831','TK Audio TKlizer','음향 프로세서','P29qO1OR2jY','Games','N M','mouoO8W6QLA','2024-05-26');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-f4fff5a16175c831-aTj3RIQlj78','ref-f4fff5a16175c831','TK Audio TKlizer','음향 프로세서','aTj3RIQlj78','Play No Games','Henry Young','mouoO8W6QLA','2024-05-26');
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('87c4edd033d6af1b431f375b','ref-f4fff5a16175c831');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-f4fff5a16175c831','TK Audio');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-f4fff5a16175c831' WHERE id='87c4edd033d6af1b431f375b' AND status='needs_product_review';
