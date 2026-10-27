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


## Public catalog caching

`GET /api/catalog` uses Cloudflare Cache API for 60 seconds per location.
Only the public catalog is cached: charts (including `mine`), participants,
account/session APIs, admin APIs and personal recommendations remain `no-store`.
Cache keys exclude cookies and unused query parameters and include the origin
and `CATALOG_CACHE_VERSION`; bump that version when changing catalog projection
or `SONG_CORRECTIONS`. No new KV/D1 table or paid resource is required.

Catalog responses carry ETags and use private browser revalidation. An edge hit
requires no D1 queries; matching `If-None-Match` returns an empty 304 response.
The browser coalesces concurrent catalog loads and reuses data for up to 30s,
bounded by the remaining edge lifetime. Successful recommendations/admin edits
clear the editing browser's memo and the local caches for production/beta host
aliases. Its next read explicitly bypasses the edge cache. Other locations and
already open tabs can remain stale until their TTL expires; Cache API deletion
is not global. Direct SQL imports also rely on the TTL (or an explicit purge).
Concurrent pre-edit fills may remain until TTL expiry; bypass ensures the editor
reads its write. Cache failures fall back to D1, and errors are never stored.

HTML is reusable in the browser for 60s and also emits a body-derived ETag
(distinct for beta). Cloudflare HTML transformations may strip that ETag;
the 60s browser freshness still avoids repeated page downloads. Compression
remains enabled. A newly deployed page may take up to 60s to reach a browser. Inspect
`X-DK-Cache: MISS/HIT/BYPASS` and `X-DK-Catalog-TTL` on catalog responses.
This reduces DB reads and response bytes; edge Cache API hits still invoke a
Worker. Check with `node tests/cache.cjs` and the existing `tests/*.cjs` suite.

## User addition review queue

Apply `migrations/0026_addition_review_workflow.sql` before deploying the review UI.
The migration adds tables/triggers only and backfills existing user additions.
Every real title, artist or recording change to a tracked entry appends a new
revision, including changes made through the old Worker or direct SQL. No-op
edits do not reopen a review. Historical revisions, AI evidence and owner
confirmations are retained. Songs and votes are never deleted by confirmation.

Only the owner can view the queue/history or confirm revisions. Individual
confirmation requires the exact event/review IDs. Bulk confirmation includes
all pages, but only the latest unchanged verified revisions whose AI review ID
is no newer than the list snapshot. A concurrent edit, re-review or prior
confirmation is skipped. An A→B→A edit still needs a fresh review.

AI status is not exposed as a user-writable endpoint. After actually verifying
against official artist/label/streaming sources and checking the linked recording,
prepare an evidence manifest with before/after snapshots, exact current event ID,
verdict, note and source URLs. `node scripts/record_addition_review.cjs manifest.json`
produces guarded D1 batch statements. Execute them through an authorized D1
connection, then verify the inserted review and current snapshot. Never label
unverified/ambiguous results complete; use `needs_attention` with the reason.
There is no unattended model or scheduled review job in this change. New or
edited entries remain pending until an actual review is recorded.

Checks: `node tests/addition-review.cjs` plus the existing Node test suite.
