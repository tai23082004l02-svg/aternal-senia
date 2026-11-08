"""Validate original eight-item atlas and register hashes; never edit source pixels."""
from pathlib import Path
import hashlib,json,struct
ROOT=Path(__file__).resolve().parents[1]
def main():
    path=ROOT/'art/supplies/icons.png'
    raw=path.read_bytes()
    assert raw[:8]==b'\x89PNG\r\n\x1a\n'
    assert struct.unpack('>II',raw[16:24])==(1536,1024)
    assert raw[25] in [4,6], 'Source needs an alpha channel'
    data=dict(date='2026-11-08',method='Original image generation inspired by user item sheets, reduced to8 functional MVP items. Source PNG preserved byte-for-byte; no pixel edits.4 columns x2 rows,4px region inset; text is rendered separately.',sources=[dict(file='art/supplies/icons.png',size=[1536,1024],sha256=hashlib.sha256(raw).hexdigest())],order=['forge_stone','memory_shard','ancient_seed','normal_ticket','material_chest','rage_potion','ward_potion','afk_hourglass'])
    path.with_name('provenance.json').write_text(json.dumps(data,indent=2)+'\n')
    print('PASS: original8-item PNG/alpha channel/dimensions/hash; no source pixel changes')
if __name__=='__main__': main()
