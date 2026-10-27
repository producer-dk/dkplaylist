-- User excluded Diablo/Pikachu, DMSD and Nintendo Walkman broadcasts.
UPDATE reference_sources SET status='ignored' WHERE id IN ('16530f8fb47c87e8a22b7d99','50930133b07dcbc7aae05236','58854cb2792af066bc171978') AND status='needs_product_review';
