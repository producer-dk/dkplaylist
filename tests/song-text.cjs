const fs=require('fs'),vm=require('vm'),assert=require('assert');
const s=fs.readFileSync('worker.js','utf8'),ctx={};vm.createContext(ctx);
vm.runInContext(s.slice(s.indexOf('const SONG_CORRECTIONS'),s.indexOf('function songKey')),ctx);
const samples=[['Eye in the Sky<br>','Eye in the Sky'],['One<BR />Two','One Two'],['A&lt;br /&gt;B','A B'],['A&nbsp;B','A B'],['Love <3','Love <3'],['A < B > C','A < B > C'],['<br>','']];
for(const [raw,want]of samples)assert.equal(ctx.cleanSongText(raw),want);
const track=ctx.correctedSong({video:'NNiie_zmSr8',title:'Eye in the Sky<br>',artist:'Artist<BR/>',votes:3,id:'entry'});
assert.equal(track.title,'Eye in the Sky');assert.equal(track.artist,'Artist');assert.equal(track.votes,3);assert.equal(track.id,'entry');
console.log('PASS break-tag cleanup, encoded breaks, literal angle brackets and track identity');
