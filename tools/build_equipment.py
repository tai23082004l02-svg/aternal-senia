"""Original four-slot equipment and modest two/four-piece bonuses."""
def extend(data):
    data['sets'] = [
        dict(id='dawn', name='Bình Minh', icon='set_dawn', bonuses=[
            dict(pieces=2, description='+8% HP tối đa', stats=dict(hp_pct=.08)),
            dict(pieces=4, description='+12% sát thương kỹ năng', stats=dict(skill_pct=.12))]),
        dict(id='ember', name='Hỏa Vũ', icon='set_ember', bonuses=[
            dict(pieces=2, description='+6% tấn công', stats=dict(atk_pct=.06)),
            dict(pieces=4, description='+5% chí mạng', stats=dict(crit=.05))]),
        dict(id='tide', name='Thủy Triều', icon='set_tide', bonuses=[
            dict(pieces=2, description='+8% phòng thủ', stats=dict(defense_pct=.08)),
            dict(pieces=4, description='+1 SP mỗi giây', stats=dict(sp_regen=1.0))])]
    sets = {'sword_2':'dawn','spear_2':'ember','staff_2':'tide',
            'armor_1':'tide','armor_uncommon':'tide','armor_3':'tide',
            'armor_2':'ember','armor_4':'ember','armor_5':'dawn','armor_6':'dawn','armor_7':'dawn'}
    for item in data['items']:
        item['set_id'] = sets.get(item['id'], '')
        item['secondary'] = {}
        if item['slot']=='armor' and item['rarity']>=5:
            item['secondary'] = dict(damage_reduction=.02+(item['rarity']-5)*.01)
        item['effect'] = ''
        item['effect_description'] = ''
        if item['id'] == 'armor_3': item['slot'] = 'accessory'
    colors = {3:'#608dff',4:'#aa70ff',5:'#efa52c',6:'#ef5555',7:'#e5c569'}
    for tier, name in [(3,'Giày thủy triều'),(4,'Giày hỏa vũ'),(5,'Giày bình minh'),(6,'Giày cổ thần'),(7,'Giày thiên dực')]:
        data['items'].append(dict(id=f'boots_{tier}',name=name,slot='boots',category='all',rarity=tier,
            atk=0,hp=10+(tier-3)*5,defense=1+(tier-3)//2,haste=.03+(tier-3)*.01,
            secondary={} if tier==3 else dict(dodge=(tier-3)*.01),
            set_id='tide' if tier==3 else ('ember' if tier==4 else 'dawn'),
            effect='',effect_description='',passive='Không có nội tại phụ',
            color=colors[tier],summon_group=1 if tier==3 else 3,summon_only=tier>=4,cooldown_scale=1.0,element='none'))
    for tier, name in [(4,'Bùa hỏa vũ'),(5,'Ấn bình minh'),(6,'Ấn cổ thần'),(7,'Ấn thiên dực')]:
        data['items'].append(dict(id=f'accessory_{tier}',name=name,slot='accessory',category='all',rarity=tier,
            atk=0,hp=80+(tier-4)*10,defense=0,secondary=dict(crit=.03+(tier-4)*.01,sp_regen=(tier-4)*.25),
            set_id='ember' if tier==4 else 'dawn',effect='aegis' if tier==7 else '',
            effect_description='Kỹ năng Tinh linh tạo khiên bằng 8% HP trong 5 giây.' if tier==7 else '',
            passive='Không có nội tại phụ',color=colors[tier],summon_group=3,summon_only=True,cooldown_scale=1.0,element='none'))
    for category,name,set_id,effect,description in [
        ('sword','Kiếm thiên quang','dawn','radiance','Kiếm quang tạo khiên bằng 5% HP trong 5 giây.'),
        ('spear','Thương hỏa vũ','ember','burn','Đòn thường có 15% cơ hội thiêu đốt 3 giây; mỗi giây gây 12% ATK. Không cộng dồn.'),
        ('staff','Trượng thủy triều','tide','tide','Kỹ năng Hồi phục hoàn lại 5 SP khi thi triển thành công.')]:
        data['items'].append(dict(id=category+'_'+set_id,name=name,slot='weapon',category=category,rarity=5,
            atk=18,hp=0,defense=0,secondary=dict(crit=.05),set_id=set_id,effect=effect,effect_description=description,
            passive=description,color=colors[5],summon_group=3,summon_only=True,cooldown_scale=.92,
            element={'sword':'light','spear':'fire','staff':'water'}[category]))
