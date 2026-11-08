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

    # Three additional sidegrades: six class-compatible pieces per set.
    additions = [
        ('grove','Lâm Vệ',3,9,55,3,[
            dict(pieces=2,description='+8% HP tối đa',stats=dict(hp_pct=.08)),
            dict(pieces=4,description='+6% giảm sát thương',stats=dict(damage_reduction=.06))]),
        ('storm','Lôi Ảnh',4,15,90,4,[
            dict(pieces=2,description='+6% tốc độ đánh',stats=dict(haste=.06)),
            dict(pieces=4,description='+5% chí mạng',stats=dict(crit=.05))]),
        ('moon','Nguyệt Tinh',5,17,110,6,[
            dict(pieces=2,description='+0,5 năng lượng mỗi giây',stats=dict(sp_regen=.5)),
            dict(pieces=4,description='+10% sát thương kỹ năng',stats=dict(skill_pct=.10))])]
    for set_id,name,tier,atk,hp,defense,bonuses in additions:
        data['sets'].append(dict(id=set_id,name=name,icon='accessory_'+set_id,bonuses=bonuses))
        for kind,label,slot,category in [('sword','Kiếm','weapon','sword'),('spear','Thương','weapon','spear'),('staff','Trượng','weapon','staff'),('armor','Giáp','armor','all'),('boots','Giày','boots','all'),('accessory','Ấn','accessory','all')]:
            secondary = {}
            if kind in ['sword','spear','staff'] and set_id=='storm': secondary=dict(crit=.02)
            if kind in ['sword','spear','staff','accessory'] and set_id=='moon': secondary=dict(sp_regen=.25)
            if kind=='armor' and set_id=='moon': secondary=dict(damage_reduction=.02)
            if kind=='accessory' and set_id=='storm': secondary=dict(crit=.02)
            item=dict(id=kind+'_'+set_id,name=label+' '+name,slot=slot,category=category,rarity=tier,
                atk=atk if slot=='weapon' else 0,hp=hp if kind=='armor' else (50 if set_id=='grove' else (70 if set_id=='storm' else 90)) if kind=='accessory' else (10 if tier==3 else 15 if tier==4 else 20) if kind=='boots' else 0,
                defense=defense if kind=='armor' else (1 if tier<5 else 2) if kind=='boots' else 0,
                secondary=secondary,set_id=set_id,effect='',effect_description='',passive='Không có nội tại phụ',
                color=colors[tier],summon_group=2 if tier==3 else 3,summon_only=tier>=4,
                cooldown_scale=.98 if slot=='weapon' and tier==3 else .96 if slot=='weapon' and tier==4 else .94 if slot=='weapon' else 1.0,
                element='nature' if set_id=='grove' else 'light' if set_id=='storm' else 'water')
            if kind=='boots': item['haste']=.02 if tier==3 else .04 if tier==4 else .03
            data['items'].append(item)
