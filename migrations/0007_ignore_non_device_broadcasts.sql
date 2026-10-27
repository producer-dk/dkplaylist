-- Explicit user exclusions; archive retained, no entries or votes deleted.
UPDATE reference_sources SET status='ignored' WHERE id IN ('d2a824148dc255fe5bae8674','ffdb5a6e4ed5ce6a8886d55a','42caa7641dc04192d5bcc961') AND status='needs_product_review';
