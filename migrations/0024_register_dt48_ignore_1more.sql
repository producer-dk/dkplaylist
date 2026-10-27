-- User mapped DT 48 and excluded the 1MORE/Shanling broadcast.
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-0485655a1bdded34-yI2oS2hoL0k','ref-0485655a1bdded34','beyerdynamic DT 48','헤드폰','yI2oS2hoL0k','Burn The Witch','Radiohead','3sQp0pZIVIo','2019-08-28');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-0485655a1bdded34-o-0ygW-B_gI','ref-0485655a1bdded34','beyerdynamic DT 48','헤드폰','o-0ygW-B_gI','Radio Gaga','Queen','3sQp0pZIVIo','2019-08-28');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-0485655a1bdded34-fcHR7vGqw9k','ref-0485655a1bdded34','beyerdynamic DT 48','헤드폰','fcHR7vGqw9k','Waiting For You','핑클','3sQp0pZIVIo','2019-08-28');
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('2258b35f01b4df4ee4791ebb','ref-0485655a1bdded34');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-0485655a1bdded34','beyerdynamic');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-0485655a1bdded34' WHERE id='2258b35f01b4df4ee4791ebb' AND status='needs_product_review';
UPDATE reference_sources SET status='ignored' WHERE id='bcb4be485c1908d8f9fcf355' AND status='needs_product_review';
