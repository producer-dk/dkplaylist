"""Prepare explicitly reviewed product mappings; preserve existing entries/votes.
Usage: python scripts/import_reviewed.py /tmp/reviewed-sources.json OUTPUT_JSON
Sources contain id, subject, date, url, song from the archived reference payload.
Apply each output SQL batch transactionally through D1 query. Reruns are idempotent.
"""
import json,sys,hashlib
from pathlib import Path
from import_reference import IGNORED_BROADCASTS,clean_song_text,video,key

def quote(v):
 return 'NULL' if v is None else "'"+str(v).replace("'","''")+"'"
def prepare(rows,specs):
 batches=[];count=0
 for spec in specs:
  source=next(r for r in rows if r['id']==spec['id']);assert source['subject']==spec['subject']
  if source.get('url') in IGNORED_BROADCASTS:continue
  gid=spec.get('existingId') or 'ref-'+hashlib.sha256(key(spec['name']).encode()).hexdigest()[:16]
  valid=[(t,video(t.get('url'))) for t in source.get('song',[]) if video(t.get('url')) and clean_song_text(t.get('title')) and clean_song_text(t.get('artist'))]
  assert valid,'No playable tracks; leave source pending'
  sql=[]
  for t,v in valid:
   values=[gid+'-'+v,gid,spec['name'],spec['category'],v,clean_song_text(t['title']),clean_song_text(t['artist']),video(source['url']),source['date']]
   if spec.get('existingId'):
    sql.append('INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) SELECT '+','.join(map(quote,values[:2]))+',gear_name,category,'+','.join(map(quote,values[4:]))+' FROM entries WHERE gear_id='+quote(gid)+' LIMIT 1;')
   else:sql.append('INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES ('+','.join(map(quote,values))+');')
  sql.append('INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES ('+quote(spec['id'])+','+quote(gid)+');')
  sql.append('INSERT OR IGNORE INTO gear_metadata(gear_id,brand) VALUES ('+quote(gid)+','+quote(spec['brand'])+');')
  sql.append("UPDATE reference_sources SET status='matched_reviewed',gear_id="+quote(gid)+' WHERE id='+quote(spec['id'])+" AND status='needs_product_review';")
  batches.append({'id':spec['id'],'name':spec['name'],'tracks':len(valid),'sql':'\n'.join(sql)});count+=len(valid)
 return {'batches':batches,'proposed_tracks':count}
if __name__=='__main__':
 result=prepare(json.load(open(sys.argv[1])),json.load(open(Path(__file__).resolve().parents[1]/'data/reviewed-products.json')))
 json.dump(result,open(sys.argv[2],'w'),ensure_ascii=False);print({'broadcasts':len(result['batches']),'proposed_tracks':result['proposed_tracks']})
