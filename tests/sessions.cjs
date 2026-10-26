const fs=require('fs'),vm=require('vm'),assert=require('assert'),{DatabaseSync}=require('node:sqlite');
const source=fs.readFileSync('worker.js','utf8');const db=new DatabaseSync(':memory:');db.exec(fs.readFileSync('schema.sql','utf8'));db.exec("INSERT INTO users(id,google_sub,nickname) VALUES('u','google-u','tester')");
const env={DB:{prepare(sql){const st=db.prepare(sql);let args=[];return {bind(...a){args=a;return this},async first(){return st.get(...args)},async all(){return {results:st.all(...args)}},async run(){return st.run(...args)}}}}};
const ctx={crypto:require('crypto').webcrypto,TextEncoder,TextDecoder,URL,Request,Response,Date,Uint8Array,atob,HTML:''};vm.createContext(ctx);vm.runInContext(source.slice(source.indexOf('\n')+1).replace('export default','globalThis.app='),ctx);
async function call(path,token,method='GET',origin='https://dkplaylist.com'){return ctx.app.fetch(new Request('https://dkplaylist.com'+path,{method,headers:{cookie:'__Host-dk_session='+token,origin}}),env)}
(async()=>{
 const t=await ctx.newSession(env,'u');assert(/^s1_[a-f0-9]{64}$/.test(t));const row=db.prepare('SELECT * FROM sessions').get();assert(!JSON.stringify(row).includes(t));assert(row.expires_at>Date.now()+29*86400000);assert.equal((await ctx.verifySession(t,env)).sub,'google-u');
 const me=await call('/auth/me',t);assert.equal((await me.json()).user.nickname,'tester');
 assert.equal((await call('/auth/logout',t,'POST','https://evil.example')).status,403);assert.equal((await ctx.verifySession(t,env)).sub,'google-u');
 const out=await call('/auth/logout',t,'POST');assert(out.headers.get('set-cookie').includes('Max-Age=0'));await assert.rejects(()=>ctx.verifySession(t,env));assert.equal((await (await call('/auth/me',t)).json()).user,null);
 const expired=await ctx.newSession(env,'u');db.prepare('UPDATE sessions SET expires_at=0').run();await assert.rejects(()=>ctx.verifySession(expired,env));await assert.rejects(()=>ctx.verifySession('s1_bad',env));assert.equal((await call('/api/my-recommendations','s1_bad')).status,401);
 const cookie=vm.runInContext("sessionCookie('token',2592000)",ctx);assert(cookie.includes('HttpOnly'));assert(cookie.includes('Secure'));assert(cookie.includes('SameSite=Lax'));console.log('PASS 30-day hashed sessions, account lookup, expiration, logout revocation, origin rejection and cookie flags');
})().catch(e=>{console.error(e);process.exit(1)});
