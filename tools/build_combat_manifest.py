"""Reviewed combat atlas metadata; keeps PNG sources byte-for-byte unchanged."""
from pathlib import Path
import json,runpy,hashlib
root=Path(__file__).resolve().parents[1]
base=runpy.run_path(str(root/'tools/build_painted_manifest.py'))
old_frame=base['frame']
p=json.loads((root/'art/painted/manifest.json').read_text())
rects=base['rects']
hands=[[223,128],[217,128],[219,126],[226,127],[222,144],[119,63],[257,125],[252,143],[224,122],[217,111],[219,162],[120,170],[211,190],[230,188],[199,170],[221,132]]
anchors=[[162,304],[160,304],[195,303],[196,303],[174,301],[174,301],[181,301],[181,301],[174,302],[174,302],[174,302],[174,302],[163,304],[174,304],[174,304],[174,304]]
angles=[55,55,60,55,16,-45,65,100,20,35,18,30,18,18,35,25]
def new(i,d):
 x,y=hands[i]
 return dict(file=f'combat/eira_motion_{i:02}',atlas='combat/eira_motion.png',region=rects[i],size=rects[i][2:],anchor=anchors[i],hand=hands[i],angle=angles[i],grip_rect=[x-7,y-7,14,14],render_scale=.66,duration=d)
def clip(loop,frames,**kwargs):return dict(loop=loop,frames=frames,**kwargs)
p['heroes']['eira']={
 'idle':clip(True,[old_frame(0,.32),new(12,.25),old_frame(1,.30),new(13,.25)]),
 'run':clip(True,[old_frame(2,.055),new(0,.045),old_frame(3,.055),new(1,.045),old_frame(4,.055),new(2,.045),old_frame(5,.055),new(3,.045)]),
 'attack':clip(False,[new(4,.045),old_frame(6,.045),new(5,.05),old_frame(7,.045),new(6,.035),old_frame(8,.045),new(7,.055),old_frame(9,.07),new(4,.06),old_frame(0,.07)],hit_time=.22),
 'skill':clip(False,[new(10,.12),old_frame(10,.16),new(11,.12),old_frame(10,.10),old_frame(11,.15),new(11,.10),old_frame(9,.12),old_frame(0,.08)],hit_time=.5),
 'guard':clip(False,[new(8,.12),new(9,.10),new(8,.48)]),
 'hurt':clip(False,[new(14,.06),old_frame(12,.07),old_frame(13,.06),new(15,.06)]),
 'death':clip(False,[old_frame(14,.28),old_frame(15,.72)])}
boss_rects=[[0,0,444,443],[444,0,443,443],[887,0,443,443],[1330,0,444,443],[0,443,420,444],[420,443,467,444],[887,443,443,444],[1330,443,444,444]]
boss_anchors=[[230,393],[235,393],[230,393],[238,393],[237,393],[260,393],[230,393],[230,393]]
def guardian(i,d):
 return dict(file=f'combat/guardian_{i:02}',atlas='combat/guardian_motion.png',region=boss_rects[i],anchor=boss_anchors[i],scale=.55,duration=d)
p['guardian_clips']={
 'idle':clip(True,[guardian(0,.7),guardian(1,.7)]),
 'charge':clip(False,[guardian(2,.28),guardian(3,.36),guardian(4,.36)]),
 'slam':clip(False,[guardian(5,.11),guardian(6,.13),guardian(7,.18),guardian(0,.10)])}
p['version']=2
(root/'art/painted/manifest.json').write_text(json.dumps(p,indent=2)+'\n')
vfx_names=['slash_gold','slash_teal','slash_double','impact','burst','heal_ring','petals','motes','guard_arc','shield_crack','shards','shockwave','dust','telegraph','cast_orb','heal_ribbon']
vfx_regions=[r[:] for r in rects]
vfx_regions[4]=[0,314,330,313]
(root/'art/combat/manifest.json').write_text(json.dumps({'version':1,'atlas':'combat/effects.png','effects':{name:{'region':r} for name,r in zip(vfx_names,vfx_regions)}},indent=2)+'\n')
(root/'art/combat/provenance.json').write_text(json.dumps({'method':'Original image generation; reviewed source rectangles, sockets and baselines. No original game assets or rig.','date':'2026-11-07','sources':[{'file':f,'sha256':hashlib.sha256((root/'art/combat'/f).read_bytes()).hexdigest()} for f in ['eira_motion.png','guardian_motion.png','effects.png']],'rejected':'First intermediate Eira sheet had oversized head proportions; corrected by image generation before integration.'},indent=2)+'\n')
print('Eira: 32 source poses, 7 states; guardian: 8 poses; VFX: 16 textures')
