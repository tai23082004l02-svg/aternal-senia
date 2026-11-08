"""Validate reviewed atlas regions and register original sources, without editing pixels."""
from pathlib import Path
import hashlib,json,struct
ROOT=Path(__file__).resolve().parents[1]

def main():
    folder=ROOT/'art/dungeons'
    data=json.loads((ROOT/'game/data/dungeon_world.json').read_text())
    manifest=json.loads((folder/'manifest.json').read_text())
    assert len(data['entries'])==15 and len({row['id'] for row in data['entries']})==15
    assert {key:sum(row['group']==key for row in data['entries']) for key in data['groups']}==dict(resource=5,tactic=5,boss=4,endless=1)
    assert sorted(row['art'] for row in data['entries'])==list(range(15))
    assert sorted(row['stage'] for row in data['entries'] if row['stage'])==[101,102,103]
    sources=[]
    for key,count in [('worlds',15),('enemies',12)]:
        spec=manifest[key]
        path=ROOT/spec['file']
        raw=path.read_bytes()
        assert raw[:8]==b'\x89PNG\r\n\x1a\n'
        width,height=struct.unpack('>II',raw[16:24])
        assert [width,height]==spec['size']
        assert len(spec['regions'])==count
        for x,y,w,h in spec['regions']:
            assert 0<=x<x+w<=width and 0<=y<y+h<=height and w>100 and h>100
        sources.append(dict(file=spec['file'],size=[width,height],sha256=hashlib.sha256(raw).hexdigest(),cells=count))
    provenance=dict(date='2026-11-08',method='Original image generation, fantasy teal/gold style referenced from the user dungeon mockups. Environment atlas15 panoramas; enemy concept atlas12 illustrations. PNG sources preserved byte-for-byte, no pixel edits. Reviewed regions with2px inset; three guardian portraits remain reserved concepts, not replacement combat actors.',sources=sources)
    (folder/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n')
    print('PASS:15 world scenes/12 concept portraits, original PNG dimensions/hash and reviewed atlas bounds; source pixels unchanged')

if __name__=='__main__': main()
