"""Prepare a repeatable, non-destructive import from the public Reference Player.
Usage: python scripts/import_reference.py SOURCE_JSON EXISTING_ENTRIES_JSON OUTPUT_JSON
Output is a D1 batch plan. Existing IDs, user entries and votes are never modified.
Only explicit single-product suffixes are promoted; all broadcasts stay in the archive.
"""
import sys,json,re,hashlib,unicodedata
from urllib.parse import urlparse,parse_qs

def key(s):return re.sub(r'[^\w]','',unicodedata.normalize('NFKC',s).casefold())
def video(s):
 s=str(s or '').strip()
 if s.startswith(('http://','https://')):
  u=urlparse(s);host=u.hostname or ''
  if host in ('youtube.com','www.youtube.com','m.youtube.com'):s=parse_qs(u.query).get('v',[''])[0]
  elif host=='youtu.be':s=u.path.strip('/')
  else:return None
 m=re.fullmatch(r'/?([A-Za-z0-9_-]{11})(?:\?|\s+\([^)]*\))?',s)
 return m[1] if m else None

def prepare(source,existing):
 bybroadcast={e['broadcast']:e for e in existing if e.get('broadcast')}
 byname={key(e['gear_name']):e for e in existing}
 known={(e['gear_id'],e['video']) for e in existing}
 statements=[];counts={'broadcasts':len(source),'source_tracks':sum(len(d.get('song',[])) for d in source),'new_entries':0,'matched_broadcasts':0,'pending_broadcasts':0,'unplayable_tracks':0}
 for d in source:
  raw=json.dumps(d,ensure_ascii=False,separators=(',',':'));sid=hashlib.sha256((str(d.get('url'))+'|'+d['date']+'|'+d['subject']).encode()).hexdigest()[:24]
  gear=bybroadcast.get(d.get('url'));name=d['subject'].rsplit('|',1)[-1].strip()
  # A delimiter alone does not establish a product: reject prose and multi-product headings.
  if not gear and '|' in d['subject']:
   name=re.split(r'\s*\((?:feat\.|비교)',name,flags=re.I)[0].strip()
   if re.match(r'^(?:[A-Za-z]|[0-9]+[A-Za-z]|64 Audio)',name) and not name.startswith('EP.') and len(name)<=70 and not re.search(r'[,/+]|\bvs\b|비교|시리즈|행사|코드|리뷰|업그레이드|테스트|방문|추천|신작|한정판',name,re.I):
    gear=byname.get(key(name))
    if not gear:
     gid='ref-'+hashlib.sha256(key(name).encode()).hexdigest()[:16]
     # Categories only when explicitly stated; otherwise preserve as unclassified.
     subject=d['subject'];category='미분류'
     if '이어폰' in subject:category='이어폰'
     elif '헤드폰' in subject or '헤드셋' in subject:category='헤드폰'
     elif '스피커' in subject:category='스피커'
     elif re.search(r'\bDAC\b',subject,re.I):category='DAC / 앰프'
     elif '앰프' in subject:category='앰프'
     gear={'gear_id':gid,'gear_name':name,'category':category};byname[key(name)]=gear
  status='matched' if gear else 'needs_product_review';counts['matched_broadcasts' if gear else 'pending_broadcasts']+=1
  statements.append({'sql':'INSERT INTO reference_sources (id,source_url,broadcast,source_date,subject,payload,gear_id,status) VALUES (?,?,?,?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET payload=excluded.payload,gear_id=CASE WHEN reference_sources.status IN (\'matched_multi\',\'matched_reviewed\') THEN reference_sources.gear_id ELSE excluded.gear_id END,status=CASE WHEN reference_sources.status IN (\'matched_multi\',\'matched_reviewed\') THEN reference_sources.status ELSE excluded.status END','params':[sid,'http://refplay.iptime.org:9000/song',d.get('url',''),d['date'],d['subject'],raw,gear['gear_id'] if gear else '',status]})
  for t in d.get('song',[]):
   v=video(t.get('url'));title=t.get('title','').strip();artist=t.get('artist','').strip()
   if not v or not title or not artist:counts['unplayable_tracks']+=1;continue
   if not gear:continue
   pair=(gear['gear_id'],v)
   if pair in known:continue
   known.add(pair);counts['new_entries']+=1
   statements.append({'sql':'INSERT OR IGNORE INTO entries (id,gear_id,gear_name,category,video,title,artist,broadcast,source_date) VALUES (?,?,?,?,?,?,?,?,?)','params':[gear['gear_id']+'-'+v,gear['gear_id'],gear['gear_name'],gear['category'],v,title,artist,video(d.get('url')),d['date']]})
 return {'counts':counts,'batch':statements}

if __name__=='__main__':
 source=json.load(open(sys.argv[1]))['data'];existing=json.load(open(sys.argv[2]));plan=prepare(source,existing);json.dump(plan,open(sys.argv[3],'w'),ensure_ascii=False);print(json.dumps(plan['counts'],ensure_ascii=False))
