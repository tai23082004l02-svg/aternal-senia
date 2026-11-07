"""Validate preserved banner sources and regenerate provenance without editing pixels."""
from pathlib import Path
import hashlib, json, struct
ROOT = Path(__file__).resolve().parents[1]
folder = ROOT / 'art/banners'
refs = {'eira':['art/painted/eira_atlas.png'], 'mira':['art/complete/mira.png'], 'ryn':['art/ryn/portrait.png'], 'lyra':['art/complete/lyra.png']}
rows = []
for hero, reference in refs.items():
    path = folder / (hero + '.png')
    raw = path.read_bytes()
    assert raw[:8] == b'\x89PNG\r\n\x1a\n'
    size = struct.unpack('>II', raw[16:24])
    assert size == (1536, 1024), 'Review runtime framing before replacing banner dimensions'
    rows.append(dict(id=hero, file=str(path.relative_to(ROOT)), size=list(size), sha256=hashlib.sha256(raw).hexdigest(), references=reference + (['art/banners/mira.png'] if hero != 'mira' else [])))
meta = dict(date='2026-11-07', method='Original image generation, identity referenced from project art; Mira inspired by user-supplied banner composition. Landscape waist-up detailed anime illustrations. Source PNGs copied byte-for-byte; no pixel edits.', sources=rows)
(folder / 'provenance.json').write_text(json.dumps(meta, ensure_ascii=False, indent=2) + '\n')
print('Validated four original 1536x1024 banners; source pixels unchanged')
