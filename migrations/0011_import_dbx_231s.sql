-- User identified EQ quiz device as dbx 231s.
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-3eebda4471d5ae15-BHjmwp_Gx7Y','ref-3eebda4471d5ae15','dbx 231s','음향 프로세서','BHjmwp_Gx7Y','blah blah blah','Camille de la Cruz, WEARETHEGOOD','kXO3clxHU44','2025-04-06');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-3eebda4471d5ae15-EqF5kIu3giw','ref-3eebda4471d5ae15','dbx 231s','음향 프로세서','EqF5kIu3giw','Spinnin'' Me Around','Shaked Miller, Danny Shields','kXO3clxHU44','2025-04-06');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-3eebda4471d5ae15-P29qO1OR2jY','ref-3eebda4471d5ae15','dbx 231s','음향 프로세서','P29qO1OR2jY','Games','NM','kXO3clxHU44','2025-04-06');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-3eebda4471d5ae15-4quSQgJtwt0','ref-3eebda4471d5ae15','dbx 231s','음향 프로세서','4quSQgJtwt0','お星様に願いを(한본어)','fleurbis','kXO3clxHU44','2025-04-06');
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('edf447aa26d7a08a2b8f4571','ref-3eebda4471d5ae15');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-3eebda4471d5ae15','dbx');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-3eebda4471d5ae15' WHERE id='edf447aa26d7a08a2b8f4571' AND status='needs_product_review';
