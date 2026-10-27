-- User follow-ups: SACD 30n and MDR-MV1 links; exclude theMIX event.
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) SELECT 'ref-f8e7d43263faea85-atcVf8NAIUs','ref-f8e7d43263faea85',gear_name,category,'atcVf8NAIUs','Broken','Seori','os85KoJerSM','2024-05-28' FROM entries WHERE gear_id='ref-f8e7d43263faea85' LIMIT 1;
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) SELECT 'ref-f8e7d43263faea85-4QIZE708gJ4','ref-f8e7d43263faea85',gear_name,category,'4QIZE708gJ4','I Had Some Help','Post Malone','os85KoJerSM','2024-05-28' FROM entries WHERE gear_id='ref-f8e7d43263faea85' LIMIT 1;
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) SELECT 'ref-f8e7d43263faea85-Vk5-c_v4gMU','ref-f8e7d43263faea85',gear_name,category,'Vk5-c_v4gMU','Magnetic','ILLIT','os85KoJerSM','2024-05-28' FROM entries WHERE gear_id='ref-f8e7d43263faea85' LIMIT 1;
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) SELECT 'ref-f8e7d43263faea85-S3Oik7w5t1M','ref-f8e7d43263faea85',gear_name,category,'S3Oik7w5t1M','Daikokai','Ai Higuchi','os85KoJerSM','2024-05-28' FROM entries WHERE gear_id='ref-f8e7d43263faea85' LIMIT 1;
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('cf641b1d9d5b0fec43e07e56','ref-f8e7d43263faea85');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-f8e7d43263faea85','Marantz');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-f8e7d43263faea85' WHERE id='cf641b1d9d5b0fec43e07e56' AND status='needs_product_review';
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-59267e3d679b3050-prt92KnnlIo','ref-59267e3d679b3050','Sony MDR-MV1','헤드폰','prt92KnnlIo','Chuou Freeway','Miki Imai','YXBeroMgDVI','2023-05-14');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-59267e3d679b3050-Xm_9NQX7uKc','ref-59267e3d679b3050','Sony MDR-MV1','헤드폰','Xm_9NQX7uKc','Allo Allo','Martin Solveig','YXBeroMgDVI','2023-05-14');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-59267e3d679b3050-2y9XiiOimHI','ref-59267e3d679b3050','Sony MDR-MV1','헤드폰','2y9XiiOimHI','最強☆ソング','Poppin''Party×HoneyWorks','YXBeroMgDVI','2023-05-14');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-59267e3d679b3050-YMYa9DyNRbI','ref-59267e3d679b3050','Sony MDR-MV1','헤드폰','YMYa9DyNRbI','野百合也有春天','孟庭葦','YXBeroMgDVI','2023-05-14');
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('32145bd8ead85152679ca2d4','ref-59267e3d679b3050');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-59267e3d679b3050','Sony');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-59267e3d679b3050' WHERE id='32145bd8ead85152679ca2d4' AND status='needs_product_review';
UPDATE reference_sources SET status='ignored' WHERE id='8177714112b710fa8ccda65e' AND status='needs_product_review';
