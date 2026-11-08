"""Validate the character-only Caelan source pack without changing image pixels."""
from pathlib import Path
import hashlib,json
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'art/caelan'
manifest=json.loads((ART/'manifest.json').read_text())
provenance=json.loads((ART/'provenance.json').read_text())
generation=json.loads((ART/'generation.json').read_text())
expected={'illustration.png':(1024,1536),'atlas.png':(1254,1254),'turnaround.png':(1536,1024),'props.png':(1536,1024)}
for name,size in expected.items():
    with Image.open(ART/name) as img:
        assert img.size==size,(name,img.size)
        if name in ['atlas.png','props.png']:
            assert img.mode=='RGBA' and img.getchannel('A').getextrema()[0]==0,name
for source in provenance['sources']:
    assert hashlib.sha256((ART/source['file']).read_bytes()).hexdigest()==source['sha256'],source['file']
for source in generation['outputs']:
    assert hashlib.sha256((ROOT/source['asset']).read_bytes()).hexdigest()==source['sha256'],source['asset']
assert set(s['file'] for s in provenance['sources'])==set(expected)
unique={}
for state,clip in manifest['heroes']['caelan'].items():
    for frame in clip['frames']:
        x,y,w,h=frame['region']
        assert 0<=x<x+w<=1254 and 0<=y<y+h<=1254
        assert 0<=frame['hand'][0]<w and 0<=frame['hand'][1]<h
        assert frame['duration']>0 and not frame['embedded_weapon']
        unique[frame['file']]=frame['region']
assert len(unique)==16
assert set(manifest['heroes']['caelan'])=={'idle','run','attack','skill','guard','hurt','death'}
for prop in manifest['signature_props'].values():
    x,y,w,h=prop['region']
    assert 0<=x<x+w<=1536 and 0<=y<y+h<=1024
assert manifest['delivery_status']=='CHARACTER_DESIGN_ONLY_NOT_RUNTIME'
print('PASS: four original PNG hashes/dimensions, alpha, provenance, sixteen source poses, seven states and prop bounds; character-only delivery')
