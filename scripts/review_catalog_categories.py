"""Generate reviewed category updates guarded by the prior value.
No entry IDs, recommendations, votes or source links are modified.
"""
import json,sys
from pathlib import Path
from review_catalog_names import quote
SCHEMA='''CREATE TABLE IF NOT EXISTS catalog_category_reviews (
 review_id TEXT NOT NULL, gear_id TEXT NOT NULL, before_category TEXT NOT NULL,
 after_category TEXT NOT NULL, reviewed_at TEXT NOT NULL DEFAULT (datetime('now')),
 PRIMARY KEY(review_id,gear_id));'''
def prepare(rows):
 batches=[]
 for row in rows:
  if row['before']==row['after']:continue
  gid=quote(row['id']);old=quote(row['before']);new=quote(row['after'])
  pred=f'gear_id={gid} AND category={old}'
  batches.append(f"INSERT OR IGNORE INTO catalog_category_reviews(review_id,gear_id,before_category,after_category) SELECT '2026-10-26-categories',{gid},{old},{new} WHERE EXISTS(SELECT 1 FROM entries WHERE {pred});\nUPDATE entries SET category={new} WHERE {pred};")
 return {'schema':SCHEMA,'batches':batches}
if __name__=='__main__':
 rows=json.load(open(Path(__file__).resolve().parents[1]/'data/catalog-category-review.json'))
 json.dump(prepare(rows),open(sys.argv[1],'w'),ensure_ascii=False)
