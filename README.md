# Release environments

- Beta: https://beta.dkplaylist.com — Worker `dkplaylist-beta`, branch `beta`.
- Live: https://dkplaylist.com — Worker `dkplaylist`, branch `main`.
- Both share `dkplaylist-db`; changes to catalog data and votes are real on both sites.
- Code changes go to beta first, then to live only after the user explicitly approves that release. See AGENTS.md.
- `wrangler.jsonc` defaults to beta, using the shared DB. Never overwrite production with a beta snapshot.
- Beta is marked noindex and has a visible shared-data banner. Cookies remain host-only, so sign-in is separate per hostname.
- Google OAuth must allow `https://beta.dkplaylist.com` as an authorized JavaScript origin. Beta needs its own `YOUTUBE_API_KEY` Worker secret for external video candidate searches. These settings are not assumed to copy between Workers.

Catalog import (2026-10-27): 905 archived broadcasts, 847 linked, 58 deliberately excluded; 1,026 gear records and 3,524 gear/song pairs. Migrations 0026 and 0027 add 448 broadcasts (551 gear links), preserving existing users and votes.

The remaining text below describes earlier import milestones, not current counts.

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

## v0.8.0

Reviewed multi-product broadcasts are listed in data/multi-products.json.
Run scripts/import_multi.py after the base importer to link each listed product
to the same broadcast tracks. reference_products preserves all source links
without duplicating existing product/video combinations or votes.
The 2026-10-26 multi-product pass covered 124 broadcasts, bringing the live
catalog to 513 products, 1,279 video IDs and 1,775 product/song pairs; 538
broadcasts still require product-name review.

The picker groups canonical brand aliases and sorts models naturally within
brands. Brand chips filter directly; IntersectionObserver loads the next batch
of products, chart tracks and personal recommendations near the list end.
Buttons remain available as a fallback.

Google ID tokens are verified only at sign-in. The site issues a random 256-bit
session token valid for 30 days, stored in a Secure/HttpOnly/SameSite=Lax cookie.
D1 stores only its SHA-256 hash, account ID and expiration. Logout revokes the
server record. Existing valid short-lived cookies migrate on /auth/me.

Checks: node tests/sessions.cjs; node tests/personal-list.cjs;
node tests/browsing.cjs.
