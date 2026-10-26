const fs=require('fs'),vm=require('vm'),assert=require('assert');
const h=JSON.parse(fs.readFileSync('worker.js','utf8').split('\n')[0].slice(13,-1));
const ctx={};vm.createContext(ctx);
vm.runInContext(h.match(/const GEAR_CATEGORIES=\[.*?\];/)[0]+h.slice(h.indexOf('function categoryParts('),h.indexOf("$('.workspace').innerHTML")),ctx);
const groups=ctx.categoryGroups([{category:'스피커'},{category:'DAP'},{category:'DAC / 앰프'},{category:'DDC / 클럭'},{category:'전원장치'}]);
for(const c of ['전체','스피커','DAP','DAC','앰프','DDC / 클럭','전원장치','미분류'])assert(groups.includes(c));
assert(ctx.categoryGroups([]).includes('미분류'));
assert(!groups.includes('DAC / 앰프'));
assert(ctx.matchesCategory('DAC / 앰프','DAC'));assert(ctx.matchesCategory('DAC / 앰프','앰프'));
assert(!ctx.matchesCategory('DDC / 클럭','DAC'));assert(!ctx.matchesCategory('DAC / 앰프','헤드폰'));
assert(ctx.matchesCategory('미분류','미분류'));assert(!ctx.matchesCategory('스피커','미분류'));
console.log('PASS data-driven category filters, always-visible unclassified, combined DAC/amp and exact categories');

for(const c of ['DAC','앰프','DDC / 클럭'])assert(ctx.matchesCategory('DAC · 앰프 · DDC / 클럭',c));
for(const c of ['DAP','이어폰'])assert(ctx.matchesCategory('DAP · 이어폰',c));
assert(!ctx.matchesCategory('DAP · 이어폰','헤드폰'));
const multi=ctx.categoryGroups([{category:'DAC · 앰프 · DDC / 클럭'},{category:'DAP · 이어폰'}]);assert(!multi.includes('오디오 세트'));assert(!multi.includes('DAP · 이어폰'));assert(multi.includes('DAP')&&multi.includes('이어폰')&&multi.includes('DDC / 클럭'));
console.log('PASS shared device in multiple categories without a set category');
