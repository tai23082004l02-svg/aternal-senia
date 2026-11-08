"""Register reviewed selection-avatar regions; never modify generated PNG pixels."""
from pathlib import Path
import hashlib
import json
import struct

ROOT = Path(__file__).resolve().parents[1]


def build():
    path = ROOT / 'art/avatars/selection.png'
    raw = path.read_bytes()
    assert raw[:8] == b'\x89PNG\r\n\x1a\n'
    width, height = struct.unpack('>II', raw[16:24])
    assert width == height and width % 2 == 0
    cell = width // 2
    # Artwork bindings only: runtime roster membership always comes from catalogue.
    order = ['eira', 'mira', 'ryn', 'lyra']
    manifest = {'source': 'art/avatars/selection.png', 'size': [width, height],
                'regions': {hero: [(i % 2) * cell + 12, (i // 2) * cell + 12,
                                   cell - 24, cell - 24] for i, hero in enumerate(order)}}
    (path.parent / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    provenance = {
        'date': '2026-11-08',
        'method': 'Original image generation and image-generation pose refinement, referenced current character banners. Eira faces left, Mira frontal, Ryn over-shoulder, Lyra smiling with a tilted head. Source retained byte-for-byte; no pixel edits. Labels and selection frames are runtime controls.',
        'file': str(path.relative_to(ROOT)), 'size': [width, height],
        'sha256': hashlib.sha256(raw).hexdigest(),
        'references': ['art/banners/' + hero + '.png' for hero in order],
    }
    (path.parent / 'provenance.json').write_text(json.dumps(provenance, indent=2) + '\n')
    print('PASS: four avatar regions, original source dimensions and SHA256')


if __name__ == '__main__':
    build()
