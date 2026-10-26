"""Build an idempotent, non-destructive catalog name correction plan.
Only reviewed gear IDs and their original names are matched. No entries, votes,
track links, or broadcasts are removed. The audit table retains before/after data.
Usage: python scripts/review_catalog_names.py OUTPUT.json
"""
import json,sys
from pathlib import Path

def quote(value):
 return 'NULL' if value is None else "'"+str(value).replace("'","''")+"'"
SCHEMA='''CREATE TABLE IF NOT EXISTS catalog_name_reviews (
 review_id TEXT NOT NULL, gear_id TEXT NOT NULL, before_json TEXT NOT NULL,
 after_json TEXT NOT NULL, reviewed_at TEXT NOT NULL DEFAULT (datetime('now')),
 PRIMARY KEY(review_id,gear_id));'''
def prepare(rows,review_id='2026-10-26-names'):
 batches=[]
 for row in rows:
  gid=quote(row['id']);old=row['before'];new=row['after']
  if old==new:continue
  predicate=f"gear_id={gid} AND gear_name={quote(old['name'])}"
  guard=f"EXISTS(SELECT 1 FROM entries WHERE {predicate})"
  before=quote(json.dumps(old,ensure_ascii=False));after=quote(json.dumps(new,ensure_ascii=False))
  sql=f"INSERT OR IGNORE INTO catalog_name_reviews(review_id,gear_id,before_json,after_json) SELECT {quote(review_id)},{gid},{before},{after} WHERE {guard};\n"
  sql+=f"INSERT INTO gear_metadata(gear_id,brand) SELECT {gid},{quote(new['brand'])} WHERE {guard} ON CONFLICT(gear_id) DO UPDATE SET brand=excluded.brand;\n"
  sql+=f"UPDATE entries SET gear_name={quote(new['name'])} WHERE {predicate};"
  batches.append(sql)
 return {'schema':SCHEMA,'batches':batches}
if __name__=='__main__':
 rows=json.load(open(Path(__file__).resolve().parents[1]/'data/catalog-name-review.json'))
 json.dump(prepare(rows),open(sys.argv[1],'w'),ensure_ascii=False)
