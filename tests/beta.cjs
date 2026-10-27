const fs=require('fs'),vm=require('vm'),assert=require('node:assert/strict');
const ctx={URL,Request,Response,Headers,crypto:require('crypto').webcrypto,TextEncoder,TextDecoder,Uint8Array,atob};
vm.createContext(ctx);vm.runInContext(fs.readFileSync('worker.js','utf8').replace('export default','globalThis.worker='),ctx);
(async()=>{
 const request=host=>new Request('https://'+host+'/');
 const beta=await ctx.worker.fetch(request('beta.dkplaylist.com'),{APP_ENV:'beta'});
 assert.equal(beta.status,200);assert.match(beta.headers.get('x-robots-tag'),/noindex/);
 const html=await beta.text();assert.match(html,/v0.10.1-beta.1/);assert.match(html,/베타 테스트/);
 assert.equal((await ctx.worker.fetch(request('dkplaylist.com'),{APP_ENV:'beta'})).status,403);
 assert.equal((await ctx.worker.fetch(request('beta.dkplaylist.com'),{})).status,403);
 const prod=await ctx.worker.fetch(request('dkplaylist.com'),{});assert.equal(prod.status,200);assert.equal(prod.headers.get('x-robots-tag'),null);assert.match(await prod.text(),/v0.10.0/);
 const robots=await ctx.worker.fetch(new Request('https://beta.dkplaylist.com/robots.txt'),{APP_ENV:'beta'});assert.equal(robots.status,200);assert.match(await robots.text(),/Disallow: \//);
 const config=JSON.parse(fs.readFileSync('wrangler.jsonc'));assert.equal(config.name,'dkplaylist-beta');assert.equal(config.d1_databases[0].database_id,'c5fa57e9-a29c-49c3-9009-99bc7e4ca59b');assert.equal(config.vars.APP_ENV,'beta');
 console.log('PASS beta host isolation, shared DB binding, beta banner/version, noindex and unchanged production rendering');
})().catch(e=>{console.error(e);process.exitCode=1});
