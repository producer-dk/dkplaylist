-- User requested exclusion of six broadcasts without source track metadata.
UPDATE reference_sources SET status='ignored' WHERE id IN ('a516027065191a7b6c76723b','bd19029caaf3c1016b853a56','17394c0a822bb08100f9a918','4fff582006aca0546fde666b','73919a43b22cde89adfd85cf','a6250d9c6d03dd7e33b80a0b') AND status='needs_product_review';
