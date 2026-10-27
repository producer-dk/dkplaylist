"""Prepare reviewed multi-product broadcasts as independent product/song entries.
python scripts/import_multi.py SOURCE_JSON EXISTING_GEARS_JSON OUTPUT_JSON
Use after the base import. Never alters votes, users, or existing entries.
"""
import json,sys,hashlib,re
from pathlib import Path
from import_reference import normalize_date,is_ignored_source,clean_song_text,key,video

def canonical(name):
 name=re.sub(r'^Bowers & Wilkins\b','B&W',name,flags=re.I)
 name=re.sub(r'^Meze Audio\b','Meze',name,flags=re.I)
 name=re.sub(r'^64Audio\b','64 Audio',name,flags=re.I)
 return key(name)

def prepare(source,existing,mapping):
 byname={canonical(g['gear_name']):g for g in existing};batch=[];new=set();pairs=set()
 for d in source:
  if is_ignored_source(d):continue
  spec=mapping.get(d.get('url'))
  if not spec:continue
  assert d['subject']==spec['subject'],'Source title changed; review mapping'
  sid=hashlib.sha256((str(d.get('url'))+'|'+d['date']+'|'+d['subject']).encode()).hexdigest()[:24]
  ids=[]
  for name in spec['products']:
   k=canonical(name);g=byname.get(k)
   if not g:
    candidates=[v for n,v in byname.items() if n.startswith(k) and re.match(r'^[가-힣(]',v['gear_name'][len(name):].strip())]
    if len(candidates)==1:g=candidates[0]
   if not g:
    g={'gear_id':'ref-'+hashlib.sha256(key(name).encode()).hexdigest()[:16],'gear_name':name,'category':'미분류'};new.add(g['gear_id'])
   byname[k]=g;ids.append(g['gear_id'])
   batch.append({'sql':'INSERT OR IGNORE INTO reference_products(source_id,gear_id) VALUES (?,?)','params':[sid,g['gear_id']]})
   for t in d.get('song',[]):
    v=video(t.get('url'));title=clean_song_text(t.get('title'));artist=clean_song_text(t.get('artist'))
    if not v or not title or not artist:continue
    pair=(g['gear_id'],v)
    if pair in pairs:continue
    pairs.add(pair)
    batch.append({'sql':'INSERT OR IGNORE INTO entries(id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES (?,?,?,?,?,?,?,?,?)','params':[g['gear_id']+'-'+v,g['gear_id'],g['gear_name'],g['category'],v,title,artist,video(d.get('url')),normalize_date(d['date'])]})
  batch.append({'sql':"UPDATE reference_sources SET status='matched_multi',gear_id=? WHERE id=?",'params':[ids[0],sid]})
 return {'batch':batch,'broadcasts':len(mapping),'new_products':len(new),'proposed_pairs':len(pairs)}

if __name__=='__main__':
 m=json.load(open(Path(__file__).resolve().parents[1]/'data/multi-products.json'))
 p=prepare(json.load(open(sys.argv[1]))['data'],json.load(open(sys.argv[2])),m)
 json.dump(p,open(sys.argv[3],'w'),ensure_ascii=False)
 print({k:v for k,v in p.items() if k!='batch'})
