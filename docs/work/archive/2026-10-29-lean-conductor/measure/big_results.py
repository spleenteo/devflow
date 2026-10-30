import json,sys
f=sys.argv[1];idmap={};res=[]
for line in open(f):
    try:d=json.loads(line)
    except:continue
    m=d.get('message') or {}
    if d.get('type')=='assistant':
        for c in m.get('content',[]) or []:
            if c.get('type')=='tool_use': idmap[c['id']]=(c['name'],json.dumps(c['input'])[:110])
    if d.get('type')=='user' and isinstance(m.get('content'),list):
        for c in m['content']:
            if c.get('type')=='tool_result':
                cc=c.get('content'); kinds=[x.get('type') for x in cc] if isinstance(cc,list) else ['text']
                res.append((len(json.dumps(cc)),d.get('timestamp','')[5:16],kinds,idmap.get(c['tool_use_id'])))
    if d.get('type')=='user' and isinstance(m.get('content'),str) and len(m['content'])>8000:
        res.append((len(m['content']),d.get('timestamp','')[5:16],['USERTEXT'],m['content'][:100]))
for r in sorted(res,reverse=True)[:25]: print(r[0]//1000,'k',r[1],r[2],r[3])
