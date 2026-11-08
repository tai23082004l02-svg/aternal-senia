"""Reviewed Caelan regions/sockets only; source PNG bytes are never modified."""
from pathlib import Path
import json,hashlib
ROOT=Path(__file__).resolve().parents[1]
def build():
    # Source 1254x1254, uneven rounded quarter boundaries reviewed visually.
    edges=[0,314,627,940,1254]
    hands=[[112,193],[118,191],[144,164],[180,148],[120,178],[180,152],[100,48],[70,117],[146,134],[88,122],[114,194],[135,151],[92,204],[144,216],[116,270],[240,280]]
    anchors=[[167,304],[165,304],[164,304],[181,304],[166,304],[182,304],[166,304],[174,304],[167,304],[173,304],[167,304],[175,304],[168,304],[172,304],[168,304],[175,304]]
    angles=[10,12,65,65,65,65,-50,110,100,100,5,95,-15,65,35,80]
    def frame(i,d):
        x,y=edges[i%4],edges[i//4];w,h=edges[i%4+1]-x,edges[i//4+1]-y
        hx,hy=hands[i]
        return dict(file=f'caelan/pose_{i:02}',atlas='caelan/atlas.png',region=[x,y,w,h],size=[w,h],anchor=anchors[i],hand=[hx,hy],angle=angles[i],grip_rect=[hx-6,hy-6,12,12],render_scale=.64,duration=d,embedded_weapon=False)
    def clip(loop,seq,**kw):return dict(loop=loop,frames=[frame(i,d) for i,d in seq],**kw)
    clips=dict(idle=clip(True,[(0,.65),(1,.65)]),run=clip(True,[(i,.11) for i in [2,3,4,5]]),attack=clip(False,[(6,.12),(7,.10),(9,.12),(8,.10),(0,.08)],hit_time=.22),skill=clip(False,[(8,.25),(9,.25),(10,.2),(0,.25)],hit_time=.5),guard=clip(False,[(10,.35),(11,.35)]),hurt=clip(False,[(12,.12),(13,.13)]),death=clip(False,[(14,.28),(15,.72)]))
    manifest=dict(version=1,delivery_status='CHARACTER_DESIGN_ONLY_NOT_RUNTIME',signature_props=dict(sword=dict(atlas='caelan/props.png',region=[160,0,440,1024],grip=[196,842],recommended_scale=.25),shield=dict(atlas='caelan/props.png',region=[720,0,680,1024])),heroes=dict(caelan=clips),portraits=dict(caelan=dict(file='caelan/illustration.png',face=[390,60,260,260],adult_age=30)),presentation=dict(caelan=dict(banner='caelan/illustration.png',panel_region=[60,0,904,1120])))
    (ROOT/'art/caelan/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    provenance=dict(method='Original image generation; Eira banner and Ryn battle atlas as style references. Metadata regions/socket cropping only; original source PNGs preserved byte-for-byte.',date='2026-11-08',identity=dict(id='caelan',planning_id='H02',adult_age=30),references=['art/banners/eira.png','art/ryn/atlas.png'],sources=[dict(file=f.name,sha256=hashlib.sha256(f.read_bytes()).hexdigest()) for f in sorted((ROOT/'art/caelan').glob('*.png'))])
    (ROOT/'art/caelan/provenance.json').write_text(json.dumps(provenance,indent=2)+'\n')
    return manifest
if __name__=='__main__':build()
