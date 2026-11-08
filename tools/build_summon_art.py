"""Validate original summon illustration; never edit source pixels."""
from pathlib import Path
import hashlib,json,struct
ROOT=Path(__file__).resolve().parents[1]
p=ROOT/'art/summon/gateway.png'
raw=p.read_bytes();assert raw[:8]==b'\x89PNG\r\n\x1a\n'
size=struct.unpack('>II',raw[16:24]);assert size==(1774,887)
meta=dict(date='2026-11-08',method='Original image generation referenced current Ryn banner identity. Empty left title area and lower overlay region; gilded forest sunrise gateway. No text, prices, countdowns, rate-up or guarantee claims baked in; source PNG copied byte-for-byte.',sources=[dict(file='art/summon/gateway.png',size=list(size),sha256=hashlib.sha256(raw).hexdigest(),reference='art/banners/ryn.png')])
(p.parent/'provenance.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2)+'\n')
print('Validated text-free 1774x887 summon gateway art')
