const fs=require('fs'),vm=require('vm'),assert=require('node:assert/strict'),{DatabaseSync}=require('node:sqlite');
const db=new DatabaseSync(':memory:');db.exec(fs.readFileSync('schema.sql','utf8'));db.exec("INSERT INTO users(id,google_sub,nickname) VALUES('owner','o','Owner'),('member','m','Member'),('admin','a','Admin');");
let role='owner';const source=fs.readFileSync('worker.js','utf8');
const env={DB:{prepare(sql){const st=db.prepare(sql);let args=[];return{bind(...a){args=a;return this},async first(){return st.get(...args)},async all(){return {results:st.all(...args)}},async run(){return {meta:{changes:st.run(...args).changes}}}}},async batch(statements){db.exec('BEGIN');try{const out=[];for(const s of statements)out.push(await s.run());db.exec('COMMIT');return out}catch(e){db.exec('ROLLBACK');throw e}}}};
const ctx={URL,Request,Response,Date,JSON,cookie:()=>'',verifySession:async()=>({sub:role}),account:async()=>({id:role,role}),correctedSong:x=>x,json:(data,status=200)=>({data,status})};vm.createContext(ctx);vm.runInContext(source.slice(source.indexOf('async function adminApi'),source.indexOf('async function api(')),ctx);
async function call(body=null,origin='https://dkplaylist.com',kind='additions'){const url=new URL('https://dkplaylist.com/api/admin?kind='+kind);return ctx.adminApi(new Request(url,body?{method:'POST',headers:{origin,'content-type':'application/json'},body:JSON.stringify(body)}:{}),env,url)}
function add(id){db.prepare("INSERT INTO entries(id,gear_id,gear_name,category,video,title,artist,source_date,created_by) VALUES (?,'gear','Gear','이어폰',?,'Song','Artist','2026-10-28','member')").run(id,'video-'+id)}
function review(id,verdict='verified'){const event=db.prepare('SELECT MAX(id) id FROM addition_events WHERE entry_id=?').get(id).id;const r=db.prepare("INSERT INTO addition_ai_reviews(event_id,verdict,note,sources_json) VALUES (?,?,'Checked','[{\"url\":\"https://music.apple.com/example\",\"label\":\"Apple Music\"}]')").run(event,verdict);return {eventId:event,reviewId:Number(r.lastInsertRowid)}}
(async()=>{
 add('one');let r=await call();assert.equal(r.data.total,1);assert.equal(r.data.rows[0].review_status,'pending');assert.equal(r.data.ready,0);
 assert.equal((await call({kind:'confirm-addition',eventId:r.data.rows[0].event_id,reviewId:1})).status,409);
 let proof=review('one');r=await call();assert.equal(r.data.rows[0].review_status,'ai_reviewed');assert.equal(r.data.ready,1);
 for(role of ['member','admin'])assert.equal((await call({kind:'confirm-additions',maxReviewId:proof.reviewId})).status,403);role='owner';
 assert.equal((await call({kind:'confirm-addition',...proof},'https://evil.test')).status,403);
 assert.equal((await call({kind:'confirm-addition',...proof})).data.confirmed,1);assert.equal((await call()).data.total,0);assert(db.prepare("SELECT 1 FROM entries WHERE id='one'").get());
 assert.equal((await call({kind:'confirm-addition',...proof})).status,409);
 // No-op edits do not reopen. A real edit creates a fresh revision and invalidates approval.
 db.exec("UPDATE entries SET title=title WHERE id='one'");assert.equal((await call()).data.total,0);
 db.exec("UPDATE entries SET title='Changed' WHERE id='one'");r=await call();assert.equal(r.data.total,1);assert.equal(r.data.rows[0].review_status,'pending');assert.equal(r.data.rows[0].previous_title,'Song');assert.equal((await call({kind:'confirm-addition',...proof})).status,409);
 // A→B→A must not recover an old AI review or confirmation.
 db.exec("UPDATE entries SET title='Song' WHERE id='one'");assert.equal((await call()).data.rows[0].review_status,'pending');
 // Bulk covers more than one page but excludes pending, uncertain, revised and newly reviewed rows.
 for(let i=0;i<55;i++){add('bulk-'+i);review('bulk-'+i)}add('uncertain');review('uncertain','needs_attention');add('pending');
 const snapshot=(await call()).data;assert.equal(snapshot.rows.length,50);assert.equal(snapshot.ready,55);assert(snapshot.nextCursor);
 db.exec("UPDATE entries SET artist='Changed' WHERE id='bulk-0'");add('late');review('late');
 // An updated AI decision after the snapshot is excluded even when the song is unchanged.
 review('bulk-1');
 r=await call({kind:'confirm-additions',maxReviewId:snapshot.maxReviewId});assert.equal(r.data.confirmed,53);
 r=await call();assert.equal(r.data.ready,2);assert.equal(r.data.total,6);
 assert.equal((await call({kind:'confirm-additions',maxReviewId:snapshot.maxReviewId})).data.confirmed,0);
 for(const invalid of [0,-1,'1',1.5,Number.MAX_SAFE_INTEGER+1])assert.equal((await call({kind:'confirm-additions',maxReviewId:invalid})).status,400);
 assert.equal(db.prepare('SELECT count(*) n FROM addition_confirmations').get().n,54);
 // Migration re-application never duplicates or reopens confirmed revisions.
 const count=db.prepare('SELECT count(*) n FROM addition_events').get().n;db.exec(fs.readFileSync('migrations/0026_addition_review_workflow.sql','utf8'));assert.equal(db.prepare('SELECT count(*) n FROM addition_events').get().n,count);
 const history=await call(null,undefined,'addition-history&entry=one');assert.equal(history.data.rows.length,3);assert(history.data.rows.some(x=>x.confirmed_at));
 // Shared song edit through the real admin endpoint reopens every affected tracked entry.
 db.exec("UPDATE entries SET gear_id=id,video='abcdefghijk' WHERE id IN ('bulk-2','bulk-3')");review('bulk-2');review('bulk-3');await call({kind:'confirm-additions',maxReviewId:(await call()).data.maxReviewId});
 assert.equal((await call({kind:'song',id:'abcdefghijk',title:'Admin edit',artist:'Artist'})).status,200);
 r=await call();assert.equal(r.data.rows.filter(x=>['bulk-2','bulk-3'].includes(x.id)&&x.review_status==='pending').length,2);
 console.log('PASS individual/bulk owner confirmation, >50-row batch, snapshot race protection, re-edit/ABA reopening, immutable history, no-op edits, idempotent migration and shared metadata edits');
})().catch(e=>{console.error(e);process.exitCode=1});
// Review recorder: evidence is bound to a version, and cannot certify a later edit.
{
 const {statements}=require('../scripts/record_addition_review.cjs');const check=new DatabaseSync(':memory:');check.exec(fs.readFileSync('schema.sql','utf8'));check.exec("INSERT INTO users(id,google_sub) VALUES ('u','u'); INSERT INTO entries(id,gear_id,gear_name,category,video,title,artist,source_date,created_by) VALUES ('r','r','Gear','이어폰','abcdefghijk','old','artist','2026-10-28','u');");
 const eventId=check.prepare("SELECT MAX(id) id FROM addition_events WHERE entry_id='r'").get().id;
 const item={entryId:'r',eventId,before:{title:'old',artist:'artist',video:'abcdefghijk'},after:{title:'New',artist:'artist',video:'abcdefghijk'},verdict:'verified',note:'Verified official title',sources:[{url:'https://music.apple.com/example',label:'Apple Music'}]};
 const queries=statements(item);check.prepare(queries[0].sql).run(...queries[0].params);
 check.exec("UPDATE entries SET title='User edit' WHERE id='r'");check.prepare(queries[1].sql).run(...queries[1].params);assert.equal(check.prepare('SELECT count(*) n FROM addition_ai_reviews').get().n,0);
 // Fresh snapshot succeeds; a repeat invocation must not append another review.
 item.eventId=check.prepare("SELECT MAX(id) id FROM addition_events WHERE entry_id='r'").get().id;item.before.title='User edit';for(const q of statements(item))check.prepare(q.sql).run(...q.params);assert.equal(check.prepare('SELECT count(*) n FROM addition_ai_reviews').get().n,1);for(const q of statements(item))check.prepare(q.sql).run(...q.params);assert.equal(check.prepare('SELECT count(*) n FROM addition_ai_reviews').get().n,1);
 assert.throws(()=>statements({...item,sources:[]}));assert.throws(()=>statements({...item,verdict:'needs_attention'}));
 console.log('PASS evidence recorder rejects stale versions, intervening edits, duplicate reviews and missing sources');
}
