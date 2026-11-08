"""Record original settings art without changing any source pixels."""
from pathlib import Path
import hashlib, json, struct
root = Path(__file__).resolve().parents[1]
p = root / 'art/settings/window.png'
raw = p.read_bytes()
assert raw[:8] == b'\x89PNG\r\n\x1a\n'
size = struct.unpack('>II', raw[16:24])
assert size[0] > 500 and size[1] > size[0]
meta = dict(date='2026-11-08', method='Original image generation, referenced art/character_panels/mira.png for forest/navy/gold palette only. Empty modal background, no character, text, icons or controls. Copied byte-for-byte; builder validates metadata only.', sources=[dict(file='art/settings/window.png', size=list(size), sha256=hashlib.sha256(raw).hexdigest())])
(p.parent / 'provenance.json').write_text(json.dumps(meta, ensure_ascii=False, indent=2) + '\n')
print('Validated original text-free settings window', size)
