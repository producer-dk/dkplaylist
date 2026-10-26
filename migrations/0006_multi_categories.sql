INSERT OR IGNORE INTO catalog_category_reviews(review_id,gear_id,before_category,after_category) SELECT '2026-10-27-multi-category','ref-4d0f6dd811159508','오디오 세트','DAC · 앰프 · DDC / 클럭' WHERE EXISTS(SELECT 1 FROM entries WHERE gear_id='ref-4d0f6dd811159508' AND category='오디오 세트');
UPDATE entries SET category='DAC · 앰프 · DDC / 클럭' WHERE gear_id='ref-4d0f6dd811159508' AND category='오디오 세트';
INSERT OR IGNORE INTO catalog_category_reviews(review_id,gear_id,before_category,after_category) SELECT '2026-10-27-multi-category','ref-4fa8ac9fe42a150b','오디오 세트','DAP · 이어폰' WHERE EXISTS(SELECT 1 FROM entries WHERE gear_id='ref-4fa8ac9fe42a150b' AND category='오디오 세트');
UPDATE entries SET category='DAP · 이어폰' WHERE gear_id='ref-4fa8ac9fe42a150b' AND category='오디오 세트';
INSERT OR IGNORE INTO catalog_category_reviews(review_id,gear_id,before_category,after_category) SELECT '2026-10-27-multi-category','ref-3ed93e93bc7fd9af','액세서리','DAC' WHERE EXISTS(SELECT 1 FROM entries WHERE gear_id='ref-3ed93e93bc7fd9af' AND category='액세서리');
UPDATE entries SET category='DAC' WHERE gear_id='ref-3ed93e93bc7fd9af' AND category='액세서리';
INSERT OR IGNORE INTO catalog_category_reviews(review_id,gear_id,before_category,after_category) SELECT '2026-10-27-multi-category','ref-fc704bd6e73afa2d','액세서리','DAC' WHERE EXISTS(SELECT 1 FROM entries WHERE gear_id='ref-fc704bd6e73afa2d' AND category='액세서리');
UPDATE entries SET category='DAC' WHERE gear_id='ref-fc704bd6e73afa2d' AND category='액세서리';
