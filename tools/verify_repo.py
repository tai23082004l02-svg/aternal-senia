"""Check tracked source links and keep generated output outside the repository."""
from pathlib import Path
import json,re,subprocess,sys
from urllib.parse import unquote,urlsplit
ROOT=Path(__file__).resolve().parents[1]
tracked=subprocess.check_output(['git','ls-files','-z'],cwd=ROOT).decode().split('\0')
tracked=[p for p in tracked if p]
errors=[]
for name in tracked:
    p=ROOT/name
    if not p.is_file():
        errors.append('Missing tracked file: '+name)
        continue
    if name.startswith(('work/','.godot/','exports/','dist/','build/','docs/previews/','docs/audio/')) or '__pycache__' in p.parts or p.suffix in ['.pyc','.tmp','.apk','.aab','.pck','.log']:
        errors.append('Generated output tracked: '+name)
    if name.startswith('art/painted/ryn_') or (name.startswith('art/ryn_') and p.suffix=='.svg'):
        errors.append('Retired Ryn source restored: '+name)
    if p.suffix in ['.gd','.tscn','.godot','.gdshader']:
        for reference in re.findall(r'["\']res://([^"\'\n]+)["\']',p.read_text()):
            if any(c in reference for c in ['%','{']):continue
            if not (ROOT/reference).exists():errors.append(name+': missing resource '+reference)
    if p.suffix=='.md':
        for target in re.findall(r'!?\[[^\]]*\]\(([^)\n]+)\)',p.read_text()):
            target=target.strip()
            if target.startswith('<'):target=target[1:target.index('>')]
            else:target=target.split()[0]
            url=urlsplit(target)
            if url.scheme or url.netloc or not url.path:continue
            dest=p.parent/unquote(url.path)
            if not dest.exists():errors.append(name+': broken local link '+target)
    if p.suffix=='.json':
        try:json.loads(p.read_text())
        except (ValueError,UnicodeError) as exc:errors.append(name+': invalid JSON '+str(exc))
catalog=json.loads((ROOT/'game/data/catalog.json').read_text())
expansion=json.loads((ROOT/'game/data/expansion.json').read_text())
world=json.loads((ROOT/'game/data/dungeon_world.json').read_text())
previews=json.loads((ROOT/'game/data/character_previews.json').read_text())
preview_ids=[]
hero_ids={row['id'] for row in catalog['heroes']}
for row in previews['characters']:
    if row['id'] in preview_ids or row['id'] in hero_ids:errors.append('Preview ID overlaps runtime or another preview: '+row['id'])
    preview_ids.append(row['id'])
    for path in [row['art']['banner']]:
        if not path.startswith('res://') or not (ROOT/path.removeprefix('res://')).is_file():errors.append('Missing character preview art: '+path)

summary={
    'tracked_files':len(tracked),
    'tracked_bytes':sum((ROOT/n).stat().st_size for n in tracked if (ROOT/n).is_file()),
    'heroes':len(catalog['heroes']),'character_previews':len(preview_ids),'equipment':len(catalog['items']),'sets':len(catalog['sets']),
    'playable_stages':len(catalog['stages'])+len(expansion['stages']),
    'dungeon_entries':len(world['entries']),
    'live_dungeon_entries':sum(bool(e['stage']) for e in world['entries']),
    'icons':len(json.loads((ROOT/'art/icons/manifest.json').read_text())['regions']),
}
out=ROOT/'work/checks'
out.mkdir(parents=True,exist_ok=True)
(out/'.gdignore').touch()
(out/'repository.json').write_text(json.dumps(dict(summary=summary,errors=errors),ensure_ascii=False,indent=2)+'\n')
for error in errors:print('FAIL: '+error)
print(json.dumps(summary,ensure_ascii=False))
if errors:sys.exit(1)
print('PASS: tracked resources, documentation links, JSON and generated-output policy')
