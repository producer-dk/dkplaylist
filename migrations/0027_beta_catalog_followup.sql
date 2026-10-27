-- User approved shared-DB catalog import on 2026-10-27. Idempotent; preserve votes and existing IDs.
UPDATE entries SET gear_name='ANOMOIBUDS IP010-Plus' WHERE gear_id='ref-ee875e2a7fdacbdc' AND gear_name='IP010-Plus';
UPDATE gear_metadata SET brand='ANOMOIBUDS' WHERE gear_id='ref-ee875e2a7fdacbdc' AND brand='브랜드 미확인';
UPDATE entries SET gear_name='Whizzer TP1' WHERE gear_id='ref-eab731a94ceb9138' AND gear_name='TP1';
UPDATE gear_metadata SET brand='Whizzer' WHERE gear_id='ref-eab731a94ceb9138' AND brand='브랜드 미확인';
INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('ref-5229571922b5b6da-r3mIpbGD-xw','ref-5229571922b5b6da','Moondrop Blessing 3','이어폰','r3mIpbGD-xw','Sunshine Girl','moumoon','_3aFlsnXBFs','2023-05-04');
