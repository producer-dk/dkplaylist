const fs=require('fs'),vm=require('vm'),assert=require('node:assert/strict'),{DatabaseSync}=require('node:sqlite');
const source=fs.readFileSync('worker.js','utf8'),html=JSON.parse(source.split('\n')[0].slice(13,-1));
let now=Date.now(),reads=0,failRead=false,failWrite=false,failDelete=false,dbDown=false;
class Clock extends Date {static now(){return now}}
const db=new DatabaseSync(':memory:');db.exec(fs.readFileSync('schema.sql','utf8'));
db.exec("INSERT INTO users(id,google_sub,nickname) VALUES ('owner','owner-sub','Owner'),('member','member-sub','Member'); INSERT INTO user_permissions VALUES ('owner','owner'); INSERT INTO votes(user_id,entry_id,direction,target_id) VALUES ('owner','g0-qR2pggPX_Sc','gear','g0');");
const env={DB:{prepare(sql){if(dbDown)throw Error('DB unavailable');const stmt=db.prepare(sql);let args=[];return {bind(...a){args=a;return this},async all(){reads++;return {results:stmt.all(...args)}},async first(){reads++;return stmt.get(...args)},async run(){return stmt.run(...args)}}},async batch(statements){db.exec('BEGIN');try{const result=[];for(const s of statements)result.push(await s.run());db.exec('COMMIT');return result}catch(e){db.exec('ROLLBACK');throw e}}}};
const entries=new Map(),pending=[];
const cache={async match(k){if(failRead)throw Error();return entries.get(k.url)?.clone()},async put(k,r){if(failWrite)throw Error();assert(!r.headers.has('set-cookie'));entries.set(k.url,r.clone())},async delete(k){if(failDelete)throw Error();return entries.delete(k.url)}};
const ctx={HTML:html,URL,Request,Response,Headers,TextEncoder,TextDecoder,Uint8Array,Date:Clock,crypto:require('crypto').webcrypto,atob,console,caches:{default:cache}};
vm.createContext(ctx);vm.runInContext(source.slice(source.indexOf('\n')+1).replace('export default','globalThis.worker='),ctx);
async function call(path='/api/catalog',options={},beta=false){return ctx.worker.fetch(new Request('https://'+(beta?'beta.':'')+'dkplaylist.com'+path,options),{...env,...beta&&{APP_ENV:'beta'}},{waitUntil(p){pending.push(p)}})}
async function flush(){await Promise.all(pending.splice(0))}
(async()=>{
 const owner=await ctx.newSession(env,'owner'),member=await ctx.newSession(env,'member');
 let r=await call();assert.equal(r.headers.get('x-dk-cache'),'MISS');const tag=r.headers.get('etag'),data=await r.json();assert(data.gears.length);await flush();assert.equal(entries.size,1);const initialReads=reads;
 r=await call('/api/catalog?ignored=1',{headers:{cookie:'__Host-dk_session='+owner}});assert.equal(r.headers.get('x-dk-cache'),'HIT');assert.deepEqual(await r.json(),data);assert.equal(reads,initialReads);assert.match(r.headers.get('cache-control'),/^private/);
 r=await call('/api/catalog',{headers:{'if-none-match':'"other", '+tag}});assert.equal(r.status,304);assert.equal(await r.text(),'');assert.equal(reads,initialReads);
 // Unknown hosts never reach cache or DB.
 r=await ctx.worker.fetch(new Request('https://evil.test/api/catalog'),env);assert.equal(r.status,403);assert.equal(reads,initialReads);
 r=await call('/api/catalog',{},true);assert.equal(r.headers.get('x-dk-cache'),'MISS');await flush();assert.equal(entries.size,2);assert.equal(r.headers.get('x-dk-environment'),'beta');
 now+=61000;r=await call();assert.equal(r.headers.get('x-dk-cache'),'MISS');await flush();assert(reads>initialReads);
 // A real authorized edit clears both local-origin caches, preserves votes and reads fresh.
 r=await call('/api/admin',{method:'POST',headers:{origin:'https://dkplaylist.com','content-type':'application/json',cookie:'__Host-dk_session='+owner},body:JSON.stringify({kind:'song',id:'qR2pggPX_Sc',title:'Cache test title',artist:'Artist'})});assert.equal(r.status,200);assert.equal(entries.size,0);
 r=await call();assert((await r.json()).gears.flatMap(g=>g.songs).some(s=>s.title==='Cache test title'));await flush();
 // Failed writes must not purge a good cached response.
 r=await call('/api/admin',{method:'POST',headers:{origin:'https://evil.test','content-type':'application/json',cookie:'__Host-dk_session='+owner},body:'{}'});assert.equal(r.status,403);assert.equal(entries.size,1);
 // Chart stays personalized even if cookies change on the same URL.
 for(const [token,mine]of [[owner,1],[member,0],['',0]]){r=await call('/api/chart?mode=gear&target=g0',{headers:{cookie:'__Host-dk_session='+token}});assert.equal(r.headers.get('cache-control'),'no-store');assert.equal((await r.json()).rows.find(x=>x.id==='g0-qR2pggPX_Sc').mine,mine)}
 for(const path of ['/api/my-recommendations','/api/admin','/auth/me']){r=await call(path);assert.equal(r.headers.get('cache-control'),'no-store');assert.equal(r.headers.get('x-dk-cache'),null)}
 // Bypass ignores an old edge value; subsequent ordinary reads see the refreshed copy.
 db.exec("UPDATE entries SET title='Fresh bypass' WHERE video='qR2pggPX_Sc'");r=await call('/api/catalog',{headers:{'cache-control':'no-cache','if-none-match':tag}});assert.equal(r.status,200);assert.equal(r.headers.get('x-dk-cache'),'BYPASS');assert((await r.json()).gears.flatMap(g=>g.songs).some(s=>s.title==='Fresh bypass'));await flush();
 failRead=failWrite=true;r=await call();assert.equal(r.status,200);await flush();failRead=failWrite=false;
 // Cache/storage failures do not turn a successful edit into a failed mutation.
 failDelete=true;r=await call('/api/admin',{method:'POST',headers:{origin:'https://dkplaylist.com','content-type':'application/json',cookie:'__Host-dk_session='+owner},body:JSON.stringify({kind:'song',id:'qR2pggPX_Sc',title:'Still saved',artist:'Artist'})});assert.equal(r.status,200);failDelete=false;
 entries.clear();dbDown=true;r=await call();assert.equal(r.status,503);await flush();assert.equal(entries.size,0);dbDown=false;
 // Shell validators follow the actual generated body, including beta banner.
 r=await call('/');const pageTag=r.headers.get('etag');assert(pageTag);r=await call('/',{headers:{'if-none-match':pageTag}});assert.equal(r.status,304);assert.equal(await r.text(),'');
 r=await call('/',{},true);assert.notEqual(r.headers.get('etag'),pageTag);assert((await r.text()).includes('베타 테스트'));
 r=await call('/',{method:'HEAD'});assert.equal(await r.text(),'');assert.equal(r.headers.get('etag'),pageTag);
 console.log('PASS edge hits with zero D1 reads, TTL expiry, ETags, host/beta isolation, real mutation invalidation, personalized APIs, cache/DB failure handling and HTML validators');
 // Browser: coalesce duplicate startup calls, avoid reads within TTL, and discard pre-edit results.
 let calls=0,fetches=[],uiNow=0;class UIDate extends Date{static now(){return uiNow}}
 const ui={Date:UIDate,fetch:(path,options)=>{calls++;return new Promise(resolve=>fetches.push({path,options,resolve}))}};vm.createContext(ui);vm.runInContext(html.slice(html.indexOf('let catalogMemo='),html.indexOf('const RECENT_GEAR_KEY')),ui);
 const response=(data)=>new Response(JSON.stringify(data),{headers:{'X-DK-Catalog-TTL':'30'}});
 let a=ui.request('/api/catalog'),b=ui.request('/api/catalog');assert.equal(calls,1);fetches.shift().resolve(response({gears:['old']}));await Promise.all([a,b]);await ui.request('/api/catalog');assert.equal(calls,1);
 uiNow=31000;a=ui.request('/api/catalog');let old=fetches.shift();const edit=ui.request('/api/admin',{});fetches.shift().resolve(response({ok:true}));await edit;
 b=ui.request('/api/catalog');const fresh=fetches.shift();assert.equal(fresh.options.cache,'reload');assert.equal(fresh.options.headers['Cache-Control'],'no-cache');old.resolve(response({gears:['stale']}));fresh.resolve(response({gears:['new']}));assert.deepEqual(await a,{gears:['new']});assert.deepEqual(await b,{gears:['new']});
 console.log('PASS browser request coalescing, TTL reuse, forced post-edit refresh and stale in-flight read protection');
})().catch(e=>{console.error(e);process.exitCode=1});
