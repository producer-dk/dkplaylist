-- Register SoundCloud track on both products; repeatable inserts preserve votes.
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-9a2022853ed44bae-https://soundcloud.com/4delight/no-one-else','ref-9a2022853ed44bae','AudioQuest DragonFly','DAC / 앰프','https://soundcloud.com/4delight/no-one-else','No One Else','카바티나 스토리','kzRjn1SGq1o','2018-05-03');
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('9102a5b84f7996054b5f940d','ref-9a2022853ed44bae');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-9a2022853ed44bae','AudioQuest');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-9a2022853ed44bae' WHERE id='9102a5b84f7996054b5f940d' AND status='needs_product_review';
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-c6a928bb9d499f9f-https://soundcloud.com/4delight/no-one-else','ref-c6a928bb9d499f9f','FiiO Q1 Mark II','DAC / 앰프','https://soundcloud.com/4delight/no-one-else','No One Else','카바티나 스토리','kzRjn1SGq1o','2018-05-03');
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('9102a5b84f7996054b5f940d','ref-c6a928bb9d499f9f');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-c6a928bb9d499f9f','FiiO');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-c6a928bb9d499f9f' WHERE id='9102a5b84f7996054b5f940d' AND status='needs_product_review';
