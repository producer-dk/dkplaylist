const fs=require('fs'),vm=require('vm'),assert=require('node:assert/strict');
const {DatabaseSync}=require('node:sqlite');
const source=fs.readFileSync('worker.js','utf8');
const db=new DatabaseSync(':memory:');db.exec(fs.readFileSync('schema.sql','utf8'));
db.exec("INSERT INTO users(id,google_sub,nickname) VALUES ('owner','owner','원장'),('member','member','사용자');");
const insert=db.prepare('INSERT INTO entries(id,gear_id,gear_name,category,video,title,artist,source_date,created_by,created_at) VALUES (?,?,?,?,?,?,?,?,?,?)');
for(let i=0;i<53;i++)insert.run('new-'+String(i).padStart(3,'0'),'g-new-'+i,'Test gear','이어폰','qR2pggPX_Sc','Song '+i,'Artist','2026-10-27','member','2026-10-27 12:00:00');
// Votes alone must not appear; cancellation does not erase an actual addition.
db.exec("INSERT INTO votes(user_id,entry_id,direction,target_id) VALUES ('member','g0-qR2pggPX_Sc','gear','g0');");
let valid=true,role='owner';
const env={DB:{prepare(sql){const stmt=db.prepare(sql);let args=[];return {bind(...v){args=v;return this},async first(){return stmt.get(...args)},async all(){return {results:stmt.all(...args)}}}}}};
const ctx={URL,Request,Response,cookie:()=>'',verifySession:async()=>{if(!valid)throw Error();return {sub:role}},account:async()=>({id:role,role}),correctedSong:r=>r,json:(data,status=200)=>({data,status})};
vm.createContext(ctx);vm.runInContext(source.slice(source.indexOf('async function adminApi'),source.indexOf('async function api(')),ctx);
async function call(extra=''){const url=new URL('https://beta.dkplaylist.com/api/admin?kind=additions'+extra);return ctx.adminApi(new Request(url),env,url)}
(async()=>{
 valid=false;assert.equal((await call()).status,401);valid=true;
 for(role of ['member','admin']){const r=await call('&role=owner');assert.equal(r.status,403);assert(!r.data.rows)}
 role='owner';let first=await call();assert.equal(first.status,200);assert.equal(first.data.total,53);assert.equal(first.data.rows.length,50);assert.equal(first.data.rows[0].id,'new-052');
 assert(first.data.rows.every(r=>r.creator==='사용자'&&!('created_by' in r)&&!('google_sub' in r)));
 assert(!first.data.rows.some(r=>r.id==='g0-qR2pggPX_Sc'));
 // An insertion ahead of the cursor must not duplicate or skip existing rows.
 insert.run('new-latest','latest','Latest gear','이어폰','qR2pggPX_Sc','Latest','Artist','2026-10-27','member','2026-10-27 13:00:00');
 const second=await call('&cursor='+encodeURIComponent(first.data.nextCursor));assert.equal(second.data.rows.length,3);assert.equal(second.data.nextCursor,null);
 assert.equal(new Set([...first.data.rows,...second.data.rows].map(r=>r.id)).size,53);
 for(const cursor of ['broken','{}','["2026-10-27 12:00:00"]','["bad","id"]','["2026-10-27 12:00:00",8]'])assert.equal((await call('&cursor='+encodeURIComponent(cursor))).status,400);
 db.exec("DELETE FROM entries WHERE created_by IS NOT NULL");assert.equal((await call()).data.total,0);assert.equal((await call()).data.rows.length,0);
 // UI: visitors cannot trigger the API, and an in-flight owner response is ignored after logout.
 const h=JSON.parse(source.split('\n')[0].slice(13,-1));const nodes=new Map();const $=id=>{if(!nodes.has(id))nodes.set(id,{innerHTML:'',textContent:'',hidden:false,disabled:false});return nodes.get(id)};
 let calls=0,resolve;const ui={$ ,location:{hash:'#user-additions'},signedIn:null,request:()=>{calls++;return new Promise(r=>resolve=r)},Date,Intl};vm.createContext(ui);
 vm.runInContext(h.slice(h.indexOf('let additionsRequest='),h.indexOf("let currentPage=''")),ui);
 await ui.showUserAdditions();assert.equal(calls,0);assert.match($('#additionsRows').innerHTML,/원장 계정/);
 ui.signedIn={id:'owner',role:'owner'};const pending=ui.showUserAdditions();assert.equal(calls,1);
 ui.signedIn=null;await ui.showUserAdditions();resolve({rows:[{title:'secret'}],total:1,nextCursor:null});await pending;assert(!$('#additionsRows').innerHTML.includes('secret'));assert($('#refreshAdditions').hidden);
 assert(h.includes("$('#userAdditionsLink').hidden=signedIn?.role!=='owner'"));
 console.log('PASS owner-only API, denied member/admin, user-created filtering, cursor pagination with concurrent insert, empty state, stale UI response after logout');
})().catch(e=>{console.error(e);process.exitCode=1});
