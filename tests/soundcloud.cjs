const fs=require('fs'),vm=require('vm'),assert=require('assert');
const source=fs.readFileSync('worker.js','utf8'),html=JSON.parse(source.split('\n')[0].slice(13,-1));
const ctx={URL,console};vm.createContext(ctx);vm.runInContext(source.slice(source.indexOf('\nfunction mediaId'),source.indexOf('const CLIENT_ID')),ctx);
for(const input of ['https://soundcloud.com/4delight/no-one-else','https://www.soundcloud.com/4delight/no-one-else/?utm_source=x'])assert.equal(ctx.mediaId(input),'https://soundcloud.com/4delight/no-one-else');
for(const input of ['javascript:alert(1)','https://soundcloud.com.evil/a/b','https://evil@ soundcloud.com/a/b','https://user@soundcloud.com/a/b','https://soundcloud.com/a/sets/b','https://soundcloud.com/a','https://soundcloud.com/sets/test'])assert.equal(ctx.mediaId(input),null);
assert.equal(ctx.mediaId('https://youtu.be/qR2pggPX_Sc?t=1'),'qR2pggPX_Sc');
assert.equal(ctx.mediaUrl('https://soundcloud.com/a/b'),'https://soundcloud.com/a/b');
const elements=new Map();let widgets=[],ytLoads=[],paused=0,seeked=0;
const el=id=>{if(!elements.has(id))elements.set(id,{style:{},after(f){elements.set(f.id,f)},remove(){elements.delete(id)}});return elements.get(id)};
function Widget(frame){const events={};const w={events,bind(e,cb){events[e]=cb},pause(){paused++},play(){},getDuration(cb){cb(120000)},seekTo(ms){seeked=ms}};widgets.push(w);return w}
Widget.Events={READY:'ready',PLAY:'play',PAUSE:'pause',PLAY_PROGRESS:'progress',SEEK:'seek',FINISH:'finish',ERROR:'error'};
Object.assign(ctx,{$:s=>el(s.slice(1)),document:{getElementById:id=>elements.get(id),createElement:()=>({style:{},remove(){elements.delete(this.id)}})},window:{SC:{Widget}},SC:{Widget},paintState(){},activePlaylist:[{video:'qR2pggPX_Sc',title:'YouTube'},{video:'https://soundcloud.com/4delight/no-one-else',title:'SC'},{video:'NNiie_zmSr8',title:'YT2'}]});
vm.runInContext(html.slice(html.indexOf('let pendingQueue=null;'),html.indexOf('function paintState()')),ctx);
vm.runInContext("ytReady=true;yt={stopVideo(){},loadVideoById(id){ytLoads.push(id)},getDuration(){return 60},getCurrentTime(){return 5},seekTo(){},playVideo(){},pauseVideo(){}}",Object.assign(ctx,{ytLoads}));
(async()=>{
 await ctx.startMedia(0);assert.equal(ytLoads.at(-1),'qR2pggPX_Sc');
 await ctx.startMedia(1);const first=widgets[0];first.events.ready();first.events.play();assert.equal(ctx.duration(),120);first.events.progress({currentPosition:9000});assert.equal(ctx.position(),9);ctx.seek(20);assert.equal(seeked,20000);ctx.pause();assert(paused>0);
 first.events.finish();assert.equal(ytLoads.at(-1),'NNiie_zmSr8');const n=ytLoads.length;first.events.finish();assert.equal(ytLoads.length,n,'stale SC end must not advance');
 ctx.moveTrack(1);assert.equal(ytLoads.length,n,'end of queue does not wrap');
 await ctx.startMedia(1);ctx.stopMedia();widgets[1].events.ready();assert.equal(ctx.mediaReady(),false,'closed player must not restart');
 // A provider change before the SDK resolves must not create a stale widget.
 vm.runInContext('scScript=null',ctx);delete ctx.window.SC;let script;ctx.document.head={appendChild(s){script=s}};const pending=ctx.startMedia(1);await ctx.startMedia(0);const count=widgets.length;script.onload();await pending;assert.equal(widgets.length,count);
 console.log('PASS media URL validation, mixed queue, transport, milliseconds, stale events, cancellation and end-of-queue');
})().catch(e=>{console.error(e);process.exit(1)});
