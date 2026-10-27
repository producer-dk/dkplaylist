-- User linked LDAC broadcast to existing Sony MDR-1ABT.
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) SELECT 'ref-60be1f24aa8d759c-itsDVntfFl0','ref-60be1f24aa8d759c',gear_name,category,'itsDVntfFl0','궤도','가리나 프로젝트','31O0aRNx4OA','2018-05-17' FROM entries WHERE gear_id='ref-60be1f24aa8d759c' LIMIT 1;
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('1e2d234d8e917536f469e354','ref-60be1f24aa8d759c');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-60be1f24aa8d759c','Sony');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-60be1f24aa8d759c' WHERE id='1e2d234d8e917536f469e354' AND status='needs_product_review';
