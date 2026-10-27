-- User identified the 2021-05-23 broadcast as EarSonics CORSA.
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-6d281eeee7ef4511-BMzqMgOLbSs','ref-6d281eeee7ef4511','EarSonics CORSA','이어폰','BMzqMgOLbSs','Home With You','Madison Beer','-4iP2mwuHEk','2021-05-23');
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-6d281eeee7ef4511-EpPpbZKjAYc','ref-6d281eeee7ef4511','EarSonics CORSA','이어폰','EpPpbZKjAYc','Deepest Lonely','Birdy','-4iP2mwuHEk','2021-05-23');
INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('302d9b6388309c3878ecec0d','ref-6d281eeee7ef4511');
INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('ref-6d281eeee7ef4511','EarSonics');
UPDATE reference_sources SET status='matched_reviewed',gear_id='ref-6d281eeee7ef4511' WHERE id='302d9b6388309c3878ecec0d' AND status='needs_product_review';
