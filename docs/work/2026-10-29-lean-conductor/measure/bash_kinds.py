# Usage: python3 -I bash_kinds.py <transcript.jsonl>
# Counts Bash, Edit and Write calls by kind; the last line totals the bookkeeping calls.
import json,sys,re,collections
f=sys.argv[1];idmap={};cat=collections.Counter();sz=collections.Counter()
BOOK='bookkeeping (writes under docs/work)'
ELSE='edits elsewhere'
def work_write(cmd):
    # redirection > or >> to a docs/work path (not 2> or &>)
    if re.search(r'(?<![0-9&>])>>?\s*\S*docs/work/',cmd): return True
    if re.search(r'\btee\b[^|;&\n]*docs/work/',cmd): return True
    if re.search(r'\b(sed|perl)\s+(-\w+\s+)*-\w*i\b[^|;&\n]*docs/work/',cmd): return True
    if re.search(r'\.write\(|write_text\(',cmd) and 'docs/work/' in cmd: return True
    # after a cd into the work folder, a write to any path counts
    if re.search(r'\bcd\s+\S*docs/work/',cmd):
        if re.search(r'(?<![0-9&>])>>?\s*[^\s&>]',cmd): return True
        if re.search(r'\btee\b',cmd): return True
        if re.search(r'\b(sed|perl)\s+(-\w+\s+)*-\w*i\b',cmd): return True
    return False
def kind(cmd):
    if re.search(r'\bgit\b',cmd): return 'git'
    if work_write(cmd): return BOOK
    if 'plugins/cache' in cmd: return 'plugin reads (skill/shared)'
    if re.search(r'STATUS\.md|docs/work',cmd): return 'work reads'
    if 'pen ' in cmd or '.pen' in cmd: return 'pencil'
    if re.search(r'npm|node|test|electron',cmd): return 'build/test/app'
    return 'other'
def file_kind(path):
    return BOOK if 'docs/work/' in path else ELSE
for line in open(f):
    try:d=json.loads(line)
    except:continue
    m=d.get('message') or {}
    if d.get('type')=='assistant':
        for c in m.get('content',[]) or []:
            if c.get('type')!='tool_use': continue
            i=c.get('input') or {}
            if c['name']=='Bash': idmap[c['id']]=kind(i.get('command',''))
            elif c['name'] in ('Edit','Write'): idmap[c['id']]=file_kind(i.get('file_path',''))
    if d.get('type')=='user' and isinstance(m.get('content'),list):
        for c in m['content']:
            if c.get('type')=='tool_result' and c['tool_use_id'] in idmap:
                k=idmap[c['tool_use_id']];cat[k]+=1;sz[k]+=len(json.dumps(c.get('content')))
for k,v in cat.most_common(): print(f'{k:38} {v:4} calls  {sz[k]//1000} k char')
print(f'bookkeeping calls: {cat[BOOK]}')
