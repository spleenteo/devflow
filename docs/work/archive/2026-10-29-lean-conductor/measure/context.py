import json,sys,collections
f=sys.argv[1]
seen=set();calls=[];tools=collections.Counter();toolsize=collections.Counter();skills=collections.Counter()
compact=0;idmap={}
for line in open(f):
    try:d=json.loads(line)
    except:continue
    if d.get('type')=='system' and 'compact' in json.dumps(d)[:500].lower(): compact+=1
    m=d.get('message') or {}
    if d.get('type')=='assistant':
        mid=m.get('id')
        for c in m.get('content',[]) or []:
            if c.get('type')=='tool_use':
                n=c['name']; tools[n]+=1; idmap[c['id']]=n
                if n=='Skill': skills[c['input'].get('skill')]+=1
                if n=='Agent': skills['AGENT:'+str(c['input'].get('subagent_type'))]+=1
        if mid in seen: continue
        seen.add(mid); u=m.get('usage') or {}
        ctx=u.get('input_tokens',0)+u.get('cache_read_input_tokens',0)+u.get('cache_creation_input_tokens',0)
        calls.append((d.get('timestamp'),ctx,u.get('cache_read_input_tokens',0),u.get('cache_creation_input_tokens',0),u.get('output_tokens',0)))
    if d.get('type')=='user' and isinstance(m.get('content'),list):
        for c in m['content']:
            if c.get('type')=='tool_result':
                s=len(json.dumps(c.get('content')))
                toolsize[idmap.get(c.get('tool_use_id'),'?')]+=s
print('calls',len(calls),'compact-ish',compact)
print('sum read',sum(c[2] for c in calls)/1e6,'write',sum(c[3] for c in calls)/1e6)
ctxs=[c[1] for c in calls]
import statistics
print('ctx mean',statistics.mean(ctxs)//1000,'max',max(ctxs)//1000,'first',ctxs[0]//1000)
for q in range(0,len(calls),max(1,len(calls)//20)): print(calls[q][0][:16],calls[q][1]//1000,'k')
# big drops = compaction
for i in range(1,len(ctxs)):
    if ctxs[i]<ctxs[i-1]*0.6: print('drop',calls[i][0][:16],ctxs[i-1]//1000,'->',ctxs[i]//1000)
# cache rewrites (big creation)
big=[c for c in calls if c[3]>50000]; print('big cache writes',len(big),[ (c[0][5:16],c[3]//1000) for c in big][:20])
print('tools',tools.most_common(20))
print('result chars',[(k,v//1000) for k,v in toolsize.most_common(12)])
print('skills/agents',skills.most_common(30))
