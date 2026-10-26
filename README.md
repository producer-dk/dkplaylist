# dkplaylist
DK Playlist - Music and audio gear matching platform

## Reference data

The public source is `http://refplay.iptime.org:9000/song` (POST, the same
read endpoint used by the Reference Player). `reference_sources` preserves
all original broadcast records, including source titles and raw song links.
The 2026-10-26 import archived 905 broadcasts / 3,012 track occurrences.
245 broadcasts were mapped to explicit product names; 660 remain marked
`needs_product_review`. Invalid or non-YouTube links stay in the archive.
Existing entry IDs and user votes were preserved. The live catalog after
import contains 245 products, 952 distinct video IDs and 985 combinations.

`scripts/import_reference.py` prepares a parameterized D1 batch plan from a
source JSON response and an export of existing entries. It reuses existing
product IDs, skips duplicate product/video pairs and never overwrites votes.
Review proposed names before executing a plan. Apply schema.sql before
installing the worker on a new database. Review ambiguous records in
reference_sources before promoting them to entries; do not infer per-product
recommendations from a multi-product broadcast without checking the source.

The signed-in personal list is `/#my-recommendations`; its API reads only
current gear votes for the authenticated account, 100 rows per page.
