"""Reviewed atlas regions/sockets. Does not edit or regenerate source images."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
# Rectangles are explicitly recorded after viewing each source cell, not inferred
# from alphabetical names, an alpha bounding box or an unverified uniform grid.
rects=[[0,0,314,314],[314,0,313,314],[627,0,313,314],[940,0,314,314],
       [0,314,314,313],[314,314,313,313],[627,314,313,313],[940,314,314,313],
       [0,627,314,313],[314,627,313,313],[627,627,313,313],[940,627,314,313],
       [0,940,314,314],[314,940,313,314],[627,940,313,314],[940,940,314,314]]
hands=[[223,195],[230,195],[216,159],[248,136],[235,143],[236,139],
       [117,28],[88,96],[285,133],[235,173],[229,116],[248,64],
       [220,126],[225,209],[207,219],[240,260]]
anchors=[[174,303],[177,303],[160,301],[194,299],[171,299],[194,293],
         [174,301],[181,303],[174,301],[174,303],[174,303],[174,303],
         [174,298],[174,298],[174,296],[174,298]]
angles=[18,18,55,60,55,60,-55,-70,90,30,25,25,25,30,0,0]
def frame(index,duration):
 x,y=hands[index]
 return dict(file=f'painted/eira_{index:02}',atlas='painted/eira_atlas.png',region=rects[index],
             size=rects[index][2:],anchor=anchors[index],hand=[x,y],angle=angles[index],
             grip_rect=[x-7,y-7,14,14],render_scale=.64,duration=duration)
clips={
 'idle':dict(loop=True,frames=[frame(0,.32),frame(1,.38),frame(0,.32),frame(1,.38)]),
 'run':dict(loop=True,frames=[frame(i,.10) for i in [2,3,4,5]]),
 'attack':dict(loop=False,frames=[frame(6,.12),frame(7,.10),frame(8,.12),frame(9,.18),frame(0,.10)]),
 'skill':dict(loop=False,frames=[frame(10,.25),frame(11,.30),frame(9,.15),frame(0,.25)]),
 'hurt':dict(loop=False,frames=[frame(12,.13),frame(13,.13)]),
 'death':dict(loop=False,frames=[frame(14,.28),frame(15,.72)])}
painted=dict(version=1,heroes={'eira':clips},weapons={
 'sword_1':dict(file='painted/dawnveil.png',anchor=[512,1225],scale=.14,tint=[.82,.94,1,1]),
 'sword_2':dict(file='painted/dawnveil.png',anchor=[512,1225],scale=.14,tint=[1,1,.93,1])},
 enemies={
 'slime':dict(atlas='painted/forest_enemies.png',region=[100,200,400,280],anchor=[200,264],scale=.34),
 'wolf':dict(atlas='painted/forest_enemies.png',region=[640,70,590,420],anchor=[300,400],scale=.30),
 'golem':dict(atlas='painted/forest_enemies.png',region=[24,590,580,605],anchor=[276,582],scale=.35),
 'golem_charge':dict(atlas='painted/forest_enemies.png',region=[615,580,620,620],anchor=[340,592],scale=.35)},
 backgrounds={'forest':'painted/forest.png','ruins':'painted/ruins.png','lake':'painted/lake.png'},companions={'lumi':'painted/lumi.png','ash':'painted/ash.png'})
# Ryn 0.18: new coherent painted design; retired raw files are not referenced.
ryn_edges=[0,314,627,940,1254]
ryn_regions=[[ryn_edges[c],ryn_edges[r],ryn_edges[c+1]-ryn_edges[c],ryn_edges[r+1]-ryn_edges[r]] for r in range(4) for c in range(4)]
ryn_hands=[[220,194],[228,194],[211,160],[230,139],[209,145],[211,142],[103,35],[82,98],[263,125],[134,161],[185,140],[123,212],[219,132],[215,205],[129,278],[236,279]]
ryn_anchors=[[172,304],[172,304],[166,303],[188,303],[170,303],[188,303],[172,303],[172,303],[172,303],[172,303],[172,303],[172,303],[172,303],[172,303],[172,303],[172,303]]
ryn_angles=[18,18,55,60,55,60,-55,-70,90,30,25,25,25,30,0,0]
def ryn_frame(i,d):
 region=ryn_regions[i][:]
 if i in [2,4,13,14]:region[2]=280
 x,y=ryn_hands[i]
 return dict(file=f'ryn/pose_{i:02}',atlas='ryn/atlas.png',region=region,size=region[2:],anchor=ryn_anchors[i],source_size=[512,512],source_anchor=[256,460],trim_offset=[256-ryn_anchors[i][0],460-ryn_anchors[i][1]],hand=[x,y],angle=ryn_angles[i],grip_rect=[x-7,y-7,14,14],render_scale=.64,duration=d,embedded_weapon=False)
def ryn_clip(loop,seq,**extra):return dict(loop=loop,frames=[ryn_frame(i,d) for i,d in seq],**extra)
painted['heroes']['ryn']={
 'idle':ryn_clip(True,[(0,.6),(1,.6)]),
 'run':ryn_clip(True,[(i,.1) for i in [2,3,4,5]]),
 'attack':ryn_clip(False,[(6,.12),(7,.1),(8,.12),(9,.1),(0,.08)],hit_time=.22),
 'skill':ryn_clip(False,[(10,.25),(11,.25),(11,.15),(9,.15),(0,.15)],hit_time=.5),
 'guard':ryn_clip(False,[(7,.7)]),
 'hurt':ryn_clip(False,[(12,.125),(13,.125)]),
 'death':ryn_clip(False,[(14,.28),(15,.72)])}
painted['portraits']={'ryn':dict(file='ryn/portrait.png',face=[460,245,220,220],adult_age=27,layers={'body':'ryn/body.png','hair':'ryn/hair.png','cloth':'ryn/cloth.png'})}
(root/'art/painted/manifest.json').write_text(json.dumps(painted,indent=2)+'\n')
