"""Metadata and provenance for preserved generated equipment frame art."""
from pathlib import Path
import hashlib,json,struct
root=Path(__file__).resolve().parents[1]
path=root/'art/equipment/frames.png'
raw=path.read_bytes()
w,h=struct.unpack('>II',raw[16:24])
assert (w,h)==(1536,1024), 'Review new frame regions before changing source layout'
# Divine crown crosses the nominal512px row boundary. Use reviewed row bounds
# so Epic never includes the next row's golden crest.
frames={str(i+3):dict(region=[i%3*512,0 if i<3 else 480,512,480 if i<3 else 544]) for i in range(6)}
(path.parent/'manifest.json').write_text(json.dumps(dict(atlas='equipment/frames.png',frames=frames),indent=2)+'\n')
(path.parent/'provenance.json').write_text(json.dumps(dict(date='2026-11-07',method='Original image generation in the project fantasy style. Six reviewed ornamental panels: five equipment rarity frames and one set decoration. PNG retained byte-for-byte; no source pixel edits.',sources=[dict(file='art/equipment/frames.png',size=[w,h],sha256=hashlib.sha256(raw).hexdigest())]),indent=2)+'\n')
