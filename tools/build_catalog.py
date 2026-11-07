"""Original balance and content; reference schemas inform structure only."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
heroes=[dict(id='eira',name='Eira',title='Kiếm sĩ bình minh',element='light',hp=210,atk=20,defense=3,crit=.12,color='#a9b9ed',unlock=1,passive='Kiếm quang: +12% sát thương kỹ năng',skill_bonus=1.12),dict(id='ryn',name='Ryn',title='Thương thủ hỏa vũ',element='fire',hp=240,atk=23,defense=2,crit=.18,color='#efaa87',unlock=2,passive='Liều lĩnh: chí mạng 18%',skill_bonus=1.0),dict(id='mira',name='Mira',title='Pháp sư thủy triều',element='water',hp=190,atk=25,defense=4,crit=.10,color='#88d6d1',unlock=3,passive='Dòng chảy: hồi phục mạnh hơn 25%',skill_bonus=1.0)]
for hero in heroes: hero['rarity']=5
items=[]
for cat,names in [('sword',['Kiếm sương','Kiếm nhật quang']),('spear',['Thương than hồng','Thương phượng']),('staff',['Trượng giọt sương','Trượng tinh tú'])]:
 for i,name in enumerate(names):
  items.append(dict(id=f'{cat}_{i+1}',name=name,slot='weapon',category=cat,rarity=1 if i==0 else 3,atk=6+i*6,hp=0,defense=0,color=['#b6dcec','#edc58a'][i]))
for i,name in enumerate(['Áo choàng lá','Giáp hoàng hôn','Ấn mặt trăng']):
 items.append(dict(id=f'armor_{i+1}',name=name,slot='armor',category='all',rarity=1 if i==0 else 3,atk=0,hp=30+i*20,defense=2+i,color=['#86baa5','#dba886','#a9a4e6'][i]))
skills=[dict(id='slash',name='Kiếm quang',kind='damage',power=2.5,cd=5.0,cost=20,hit=.25,duration=.65),dict(id='heal',name='Hồi phục',kind='heal',power=.34,cd=9.,cost=25,hit=.35,duration=.75),dict(id='burst',name='Tinh linh',kind='damage',power=4.2,cd=12.,cost=35,hit=.5,duration=.95)]
items.append(dict(id='armor_uncommon',name='Áo choàng sương sớm',slot='armor',category='all',rarity=2,atk=0,hp=40,defense=2,color='#69b875'))
for tier,name,hp,defense in [(4,'Giáp tinh vân',90,5),(5,'Giáp thiên quang',115,6),(6,'Giáp cổ thần',145,7),(7,'Giáp thần thánh',180,9)]:
 items.append(dict(id=f'armor_{tier}',name=name,slot='armor',category='all',rarity=tier,atk=0,hp=hp,defense=defense,color={4:'#aa70ff',5:'#efa52c',6:'#ef5555',7:'#e5c569'}[tier],summon_only=True))
stages=[]
for i,(name,zone,boss,mechanic) in enumerate([('Lối vào rừng','forest','Cổ thụ thức tỉnh','smash'),('Tàn tích lửa','ruins','Hộ vệ than hồng','shield'),('Hồ gương','lake','Ảo ảnh thủy triều','counter'),('Đỉnh sao','mountain','Chim sấm','smash'),('Tháp bình minh','tower','Người giữ ánh sáng','shield')]):
 stages.append(dict(id=i+1,name=name,zone=zone,enemy_hp=55+i*38,enemy_atk=14+i*6,boss_hp=250+i*145,boss_atk=35+i*12,boss=boss,mechanic=mechanic,gold=35+i*15,xp=30+i*10,first_gold=35+i*10,drops=['sword_2','spear_2','staff_2','armor_2','armor_3'],before=['Eira: Ánh sáng ấy đang gọi chúng ta.','Ryn: Tro tàn vẫn còn ấm. Hãy cẩn thận.','Mira: Mặt hồ phản chiếu điều chưa xảy ra.','Eira: Trên cao, tiếng chuông không còn vang.','Mira: Cánh cửa cuối cùng đã mở.'][i],after=['Tinh linh: Một hạt sáng đã trở về rừng.','Ryn: Chúng ta có thể thắp lại nơi này.','Mira: Bóng tối chỉ là một phần của sự thật.','Eira: Mình nghe thấy tiếng chuông rồi.','Eira: Bình minh không đến một mình. Cảm ơn mọi người.'][i]))
quests=[dict(id='first',name='Ánh sáng đầu tiên',metric='wins',target=1,gold=40,shards=2),dict(id='hunter',name='Người giữ rừng',metric='kills',target=12,gold=70,shards=3),dict(id='smith',name='Lửa lò rèn',metric='enhances',target=3,gold=80,shards=4),dict(id='traveler',name='Qua miền sương',metric='clears',target=3,gold=100,shards=5),dict(id='master',name='Ngọn tháp bình minh',metric='clears',target=5,gold=180,shards=8)]
for item in items:
 item['element']={'sword':'light','spear':'fire','staff':'water','all':'none'}[item['category']]
 item['passive']='Kỹ năng hồi nhanh hơn 8%' if item['rarity']==2 and item['slot']=='weapon' else 'Không có nội tại phụ'
for stage,element in zip(stages,['nature','fire','water','nature','dark']):
 stage['element']=element
data=dict(version=1,heroes=heroes,items=items,skills=skills,stages=stages,quests=quests,assists=[dict(id='lumi',name='Lumi',rarity='SR',role='Hồi phục',unlock=1,power=.09,interval=4.),dict(id='ash',name='Ash',rarity='SSR',role='Xạ thủ',unlock=2,power=.9,interval=2.2)],opponents=[dict(id=id,name=name,rarity=rank) for id,name,rank in [('slime','Slime rừng',1),('wolf','Sói rừng',2),('golem','Cổ thụ',3),('guardian','Hộ vệ',4),('bird','Chim sấm',4)]])
(root/'game/data/catalog.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
