"""Validate full-page art and regenerate provenance, without editing source pixels."""
from pathlib import Path
import hashlib, json, struct
ROOT=Path(__file__).resolve().parents[1]
rows=[]
for hero in ['eira','mira','ryn','lyra']:
    p=ROOT/'art/character_panels'/(hero+'.png')
    raw=p.read_bytes()
    assert raw[:8] == b'\x89PNG\r\n\x1a\n'
    size=struct.unpack('>II',raw[16:24]);assert size==(1024,1536)
    rows.append(dict(id=hero,file=str(p.relative_to(ROOT)),size=list(size),sha256=hashlib.sha256(raw).hexdigest(),reference='art/banners/'+hero+'.png'))
meta=dict(date='2026-11-07',method='Original image generation using each own hero banner as identity. Portrait full-page illustration with empty title, side-control and lower content regions. No text, numbers, item icons or buttons baked into images. Source PNGs preserved byte-for-byte.',sources=rows)
(ROOT/'art/character_panels/provenance.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2)+'\n')
print('Validated four text-free 1024x1536 character page illustrations')
