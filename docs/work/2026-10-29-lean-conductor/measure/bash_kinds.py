import json,sys,re,collections
f=sys.argv[1];idmap={};cat=collections.Counter();sz=collections.Counter()
def kind(cmd):
    if 'plugins/cache' in cmd: return 'plugin reads (skill/shared)'
    if re.search(r'STATUS\.md|docs/work',cmd): return 'work state (STATUS/plan)'
    if re.search(r'\bgit\b',cmd): return 'git'
    if 'pen ' in cmd or '.pen' in cmd: return 'pencil'
    if re.search(r'npm|node|test|electron',cmd): return 'build/test/app'
    return 'other'
for line in open(f):
    try:d=json.loads(line)
    except:continue
    m=d.get('message') or {}
    if d.get('type')=='assistant':
        for c in m.get('content',[]) or []:
            if c.get('type')=='tool_use' and c['name']=='Bash': idmap[c['id']]=kind(c['input'].get('command',''))
    if d.get('type')=='user' and isinstance(m.get('content'),list):
        for c in m['content']:
            if c.get('type')=='tool_result' and c['tool_use_id'] in idmap:
                k=idmap[c['tool_use_id']];cat[k]+=1;sz[k]+=len(json.dumps(c.get('content')))
for k,v in cat.most_common(): print(f'{k:32} {v:4} calls  {sz[k]//1000} k char')
