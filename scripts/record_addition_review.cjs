// Prepare parameterized D1 batch statements after a human/agent has checked sources.
// This script never claims to perform an AI review or contacts a model itself.
const fs=require('fs');
function statements(item){
 const {entryId,eventId,before,after,verdict,note,sources}=item;
 if(typeof entryId!=='string'||!Number.isSafeInteger(eventId)||eventId<1||!['verified','needs_attention'].includes(verdict)||typeof note!=='string'||!note.trim()||!Array.isArray(sources)||!sources.length)throw Error('Incomplete review evidence');
 for(const s of sources){if(!s.label||new URL(s.url).protocol!=='https:')throw Error('Invalid evidence URL')}
 for(const state of [before,after])for(const key of ['title','artist','video'])if(typeof state?.[key]!=='string'||!state[key].trim())throw Error('Incomplete snapshot');
 if(before.video!==after.video)throw Error('Review cannot replace the recording');
 if(verdict==='needs_attention'&&(before.title!==after.title||before.artist!==after.artist))throw Error('Uncertain review cannot auto-correct');
 const changed=before.title!==after.title||before.artist!==after.artist;
 const batch=[];
 if(changed)batch.push({sql:`UPDATE entries SET title=?,artist=? WHERE id=? AND title=? AND artist=? AND video=?
 AND EXISTS(SELECT 1 FROM addition_events v WHERE v.id=? AND v.entry_id=entries.id AND v.title=entries.title AND v.artist=entries.artist AND v.video=entries.video
 AND NOT EXISTS(SELECT 1 FROM addition_events n WHERE n.entry_id=v.entry_id AND n.id>v.id))`,params:[after.title,after.artist,entryId,before.title,before.artist,before.video,eventId]});
 // Only the exact checked revision (or its immediate correction successor) is eligible.
 // If another edit intervenes, insert zero rows. Never overwrite newer reviews.
 const version=changed?`v.id>? AND v.previous_title=? AND v.previous_artist=? AND v.previous_video=?
 AND (SELECT count(*) FROM addition_events x WHERE x.entry_id=v.entry_id AND x.id>?)=1
 AND EXISTS(SELECT 1 FROM addition_events old WHERE old.id=? AND old.entry_id=v.entry_id AND old.title=? AND old.artist=? AND old.video=?)`:'v.id=?';
 batch.push({sql:`INSERT INTO addition_ai_reviews(event_id,verdict,note,sources_json)
 SELECT v.id,?,?,? FROM addition_events v JOIN entries e ON e.id=v.entry_id
 WHERE v.entry_id=? AND v.title=? AND v.artist=? AND v.video=? AND e.title=v.title AND e.artist=v.artist AND e.video=v.video
 AND NOT EXISTS(SELECT 1 FROM addition_events n WHERE n.entry_id=v.entry_id AND n.id>v.id)
 AND NOT EXISTS(SELECT 1 FROM addition_ai_reviews a WHERE a.event_id=v.id)
 AND ${version}`,params:[verdict,note,JSON.stringify(sources),entryId,after.title,after.artist,after.video,...changed?[eventId,before.title,before.artist,before.video,eventId,eventId,before.title,before.artist,before.video]:[eventId]]});
 return batch;
}
module.exports={statements};
if(require.main===module){const manifest=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));process.stdout.write(JSON.stringify({batch:manifest.reviews.flatMap(statements)},null,2)+'\n')}
