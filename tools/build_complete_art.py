"""Build reviewed presentation metadata; never edits source artwork."""
from pathlib import Path
import json,hashlib,runpy
root=Path(__file__).resolve().parents[1]
base=runpy.run_path(str(root/'tools/build_combat_manifest.py'))
p=json.loads((root/'art/painted/manifest.json').read_text())
rects=base['rects']
hands=base['base']['hands'];anchors=base['base']['anchors'];angles=base['base']['angles']
for hero in ['lyra','mira']:
 def frame(i,d):
  hero_hands = hands if hero == 'lyra' else [[120,185],[120,185],[139,162],[140,164],[132,168],[208,142],[111,33],[81,89],[264,122],[119,160],[145,153],[254,64],[139,154],[186,197],[128,280],[242,280]]
  x,y=hero_hands[i]
  region=rects[i][:]
  if i in [13,14]: region[2]=280 # Exclude cape/boot fragments from adjacent pose.
  return dict(file=f'complete/{hero}_{i:02}',atlas=f'complete/{hero}.png',region=region,size=region[2:],anchor=anchors[i],hand=[x,y],angle=angles[i],grip_rect=[x-7,y-7,14,14],render_scale=.64,duration=d)
 def clip(loop,seq,**extra):return dict(loop=loop,frames=[frame(i,d) for i,d in seq],**extra)
 p['heroes'][hero]={
  'idle':clip(True,[(0,.6),(1,.6)]),
  'run':clip(True,[(i,.1) for i in [2,3,4,5]]),
  'attack':clip(False,[(6,.12),(7,.10),(8,.12),(9,.10),(0,.08)],hit_time=.22),
  'skill':clip(False,[(10,.25),(11,.25),(11,.15),(9,.15),(0,.15)],hit_time=.5),
  'guard':clip(False,[(0,.7)]),
  'hurt':clip(False,[(12,.125),(13,.125)]),
  'death':clip(False,[(14,.28),(15,.72)])}
# Source size 1261x1247; boundaries reviewed against each painted icon.
ix=[0,315,630,946,1261];iy=[0,312,624,936,1247]
item_names=['sword_1','sword_2','spear_1','spear_2','staff_1','staff_2','armor_1','armor_2','armor_3','slash','heal','burst','gold','shards','xp','cores']
icons={name:dict(region=[ix[i%4],iy[i//4],ix[i%4+1]-ix[i%4],iy[i//4+1]-iy[i//4]]) for i,name in enumerate(item_names)}
for name,region,x in zip(['spear_1','spear_2','staff_1','staff_2'],[[0,0,444,887],[444,0,443,887],[887,0,443,887],[1330,0,444,887]],[251,224,220,219]):
 p['weapons'][name]=dict(atlas='complete/weapons.png',region=region,anchor=[x,650],scale=.38,tint=[1,1,1,1])
p['backgrounds'].update({zone:dict(atlas='complete/worlds.png',region=region) for zone,region in zip(['mountain','tower'],[[0,512,768,512],[768,512,768,512]])})
p['enemy_clips']={}
for row,key,anchor,scale in [(0,'guardian',[156,304],.63),(1,'mirror',[156,264],.65),(2,'bird',[156,260],.66),(0,'sentinel',[156,304],.65)]:
 def ef(i,d):return dict(file=f'complete/{key}_{i}',atlas='complete/enemies.png',region=rects[row*4+i],anchor=anchor,scale=scale,duration=d)
 p['enemies'][key]=ef(0,1)
 p['enemy_clips'][key]={'idle':dict(loop=True,frames=[ef(0,1)]),'charge':dict(loop=False,frames=[ef(1,.55),ef(2,.45)]),'slam':dict(loop=False,frames=[ef(3,.22),ef(0,.3)])}
p['companion_clips']={}
for icon in icons.values():
 icon['region'][3]-=12 # Exclude faint tips belonging to the next icon row.
p['icons']=dict(atlas='complete/items.png',regions=icons)
armor_names=['armor_uncommon','armor_4','armor_5','armor_6','armor_7','victory','training','fragments']
ax=[0,444,887,1330,1774];ay=[0,443,887]
for i,name in enumerate(armor_names):
 p['icons']['regions'][name]=dict(atlas='complete/armor.png',region=[ax[i%4],ay[i//4],ax[i%4+1]-ax[i%4],ay[i//4+1]-ay[i//4]])
# The shared UI/item registry is regenerated from preserved source PNGs.
icon_registry=runpy.run_path(str(root/'tools/build_icon_manifest.py'))['build']()
p['icons']=dict(atlas='icons/resources.png',regions=icon_registry['regions'])
for new,old in [('sword_dawn','sword_2'),('spear_ember','spear_2'),('staff_tide','staff_2')]:
 p['weapons'][new]=p['weapons'][old].copy()
p['version']=4
(root/'art/painted/manifest.json').write_text(json.dumps(p,indent=2)+'\n')
(root/'art/complete/provenance.json').write_text(json.dumps(dict(method='Original image generation with existing Eira/forest as style reference. Reviewed regions and sockets; source PNG unchanged.',date='2026-11-07',sources=[dict(file=f.name,sha256=hashlib.sha256(f.read_bytes()).hexdigest()) for f in sorted((root/'art/complete').glob('*.png'))]),indent=2)+'\n')
print('Complete painted roster, weapons, environments, enemies, companion and UI icons')
runpy.run_path(str(root/'tools/build_equipment_art.py'))

# Inventory illustrations remain original; register dimensions/provenance only.
runpy.run_path(str(root/'tools/build_bag_art.py'))
