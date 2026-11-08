"""Original balance and content; reference schemas inform structure only."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
heroes=[dict(id='eira',name='Eira',title='Dawn Swordswoman',element='light',hp=210,atk=20,defense=3,crit=.12,color='#a9b9ed',unlock=1,passive='Lightblade: +12% Skill Damage',skill_bonus=1.12),dict(id='ryn',name='Ryn',title='Flamefeather Lancer',element='fire',hp=240,atk=23,defense=2,crit=.18,color='#efaa87',unlock=2,passive='Reckless: 18% Critical Rate',skill_bonus=1.0),dict(id='mira',name='Mira',title='Tidal Mage',element='water',hp=190,atk=25,defense=4,crit=.10,color='#88d6d1',unlock=3,passive='Flow: healing increased by 25%',skill_bonus=1.0)]
for hero in heroes: hero['rarity']=5
items=[]
for cat,names in [('sword',['Frost Sword','Sunlight Sword']),('spear',['Ember Spear','Phoenix Spear']),('staff',['Dewdrop Staff','Starlight Staff'])]:
 for i,name in enumerate(names):
  items.append(dict(id=f'{cat}_{i+1}',name=name,slot='weapon',category=cat,rarity=3,summon_group=1 if i==0 else 2,cooldown_scale=1.0 if i==0 else .92,atk=6+i*6,hp=0,defense=0,color=['#b6dcec','#edc58a'][i]))
for i,name in enumerate(['Leaf Cloak','Twilight Armor','Moon Seal']):
 items.append(dict(id=f'armor_{i+1}',name=name,slot='armor',category='all',rarity=3,summon_group=1 if i==0 else 2,atk=0,hp=30+i*20,defense=2+i,color=['#86baa5','#dba886','#a9a4e6'][i]))
skills=[dict(id='slash',name='Lightblade',kind='damage',power=2.5,cd=5.0,cost=20,hit=.25,duration=.65),dict(id='heal',name='Restoration',kind='heal',power=.34,cd=9.,cost=25,hit=.35,duration=.75),dict(id='burst',name='Spirit',kind='damage',power=4.2,cd=12.,cost=35,hit=.5,duration=.95)]
items.append(dict(id='armor_uncommon',name='Morning Mist Cloak',slot='armor',category='all',rarity=3,summon_group=1,atk=0,hp=40,defense=2,color='#69b875'))
for tier,name,hp,defense in [(4,'Nebula Armor',90,5),(5,'Heavenlight Armor',115,6),(6,'Ancient Deity Armor',145,7),(7,'Divine Armor',180,9)]:
 items.append(dict(id=f'armor_{tier}',name=name,slot='armor',category='all',rarity=tier,atk=0,hp=hp,defense=defense,color={4:'#aa70ff',5:'#efa52c',6:'#ef5555',7:'#e5c569'}[tier],summon_only=True))
stages=[]
for i,(name,zone,boss,mechanic) in enumerate([('Forest Entrance','forest','Awakened Elder Tree','smash'),('Ember Ruins','ruins','Ember Guardian','shield'),('Mirror Lake','lake','Tidal Mirage','counter'),('Star Summit','mountain','Thunderbird','smash'),('Dawn Tower','tower','Lightkeeper','shield')]):
 stages.append(dict(id=i+1,name=name,zone=zone,enemy_hp=55+i*38,enemy_atk=14+i*6,boss_hp=250+i*145,boss_atk=35+i*12,boss=boss,mechanic=mechanic,gold=35+i*15,xp=30+i*10,first_gold=35+i*10,drops=['sword_2','spear_2','staff_2','armor_2','armor_3'],before=['Eira: That light is calling us.','Ryn: The ashes are still warm. Be careful.','Mira: The lake reflects what has not happened yet.','Eira: Up above, the bells no longer ring.','Mira: The final door has opened.'][i],after=['Spirit: A spark of light has returned to the forest.','Ryn: We can light this place again.','Mira: Darkness is only part of the truth.','Eira: I can hear the bells now.','Eira: Dawn never comes alone. Thank you, everyone.'][i]))
quests=[dict(id='first',name='First Light',metric='wins',target=1,gold=40,shards=2),dict(id='hunter',name='Forest Keeper',metric='kills',target=12,gold=70,shards=3),dict(id='smith',name='Forgefire',metric='enhances',target=3,gold=80,shards=4),dict(id='traveler',name='Through the Mist',metric='clears',target=3,gold=100,shards=5),dict(id='master',name='Tower of Dawn',metric='clears',target=5,gold=180,shards=8)]
for item in items:
 item.setdefault('summon_group',3)
 item.setdefault('cooldown_scale',1.0)
 if item['rarity']==3: item['color']='#608dff'
 item['element']={'sword':'light','spear':'fire','staff':'water','all':'none'}[item['category']]
 item['passive']='Skill cooldowns are 8% shorter' if item['rarity']==2 and item['slot']=='weapon' else 'No additional passive'
for stage,element in zip(stages,['nature','fire','water','nature','dark']):
 stage['element']=element
data=dict(version=1,heroes=heroes,items=items,skills=skills,stages=stages,quests=quests,assists=[dict(id='lumi',name='Lumi',rarity='SR',role='Restoration',unlock=1,power=.09,interval=4.),dict(id='ash',name='Ash',rarity='SSR',role='Archer',unlock=2,power=.9,interval=2.2)],opponents=[dict(id=id,name=name,rarity=rank) for id,name,rank in [('slime','Forest Slime',1),('wolf','Forest Wolf',2),('golem','Elder Tree',3),('guardian','Guardian',4),('bird','Thunderbird',4)]])

# Additive roster expansion: preserve existing hero IDs and append Lyra.
data['heroes'].append(dict(id='lyra',name='Lyra',title='Twilight Lancer',element='fire',hp=225,atk=22,defense=3,crit=.15,color='#dca58b',unlock=4,passive='Embers: +8% Skill Damage',skill_bonus=1.08,rarity=5,age=24))
from build_equipment import extend
extend(data)
(root/'game/data/catalog.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
