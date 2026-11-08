class_name SuppliesScreen
extends VBoxContainer
const GOLD := Color("ebce88")
var game

func words(parent: Node, text: String, font_size: int = 15, tint: Color = Color("d6e4db")) -> Label:
	var label := Label.new()
	label.text = tr(text)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size",font_size)
	label.modulate = tint
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func button(parent: Node, text: String, call: Callable, disabled: bool = false) -> Button:
	var action: Button = game._button(parent,tr(text),Vector2.ZERO,Vector2(458,44),call)
	action.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action.add_theme_font_size_override("font_size",14)
	action.disabled = disabled
	return action

func _ready() -> void:
	custom_minimum_size.x = 464
	add_theme_constant_override("separation",10)
	if game.supply_selected not in Supplies.ORDER:
		listing()
		return
	detail(game.supply_selected)

func listing() -> void:
	words(self,"VẬT PHẨM THIẾT YẾU",22,GOLD)
	words(self,"Cộng dồn riêng · Không chiếm40 ô trang bị",13)
	button(self,"Quà tiến trình · Xem điều kiện nhận →",game._supply_milestones)
	var selected: String = game.store.profile.supplies.selected
	if selected!="": words(self,"Đã chuẩn bị: "+Supplies.NAMES[selected]+" · Tiêu khi bắt đầu1 lượt",14,GOLD)
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation",5)
	add_child(filters)
	for pair in [["all","Tất cả"],["consumable","Tiêu hao"],["upgrade","Nâng cấp"],["spirit","Tinh linh"],["ticket","Vé / rương"]]:
		var action: Button = game._button(filters,pair[1],Vector2.ZERO,Vector2(88,44),game._supply_filter.bind(pair[0]))
		action.clip_text = true
		action.add_theme_font_size_override("font_size",12)
		if game.supply_group==pair[0]: action.modulate = GOLD
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation",10)
	grid.add_theme_constant_override("v_separation",10)
	add_child(grid)
	for id in Supplies.ORDER:
		if game.supply_group!="all" and Supplies.GROUPS[id]!=game.supply_group: continue
		var card: Button = game._button(grid,"",Vector2.ZERO,Vector2(224,184),game._supply_open.bind(id))
		card.name = "Supply_"+id
		card.add_theme_stylebox_override("normal",game._style(Color("102a35"),GOLD if Supplies.count(game.store.profile,id)>0 else Color("647b78"),18))
		var art := TextureRect.new()
		art.texture = Supplies.icon(id)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.position = Vector2(62,5)
		art.size = Vector2(100,100)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(art)
		var title: Label = game._label(card,Supplies.NAMES[id],Vector2(8,108),14,GOLD)
		title.size = Vector2(208,44)
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var count: Label = game._label(card,"×%d" % Supplies.count(game.store.profile,id),Vector2(8,155),18)
		count.size.x = 208
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count.mouse_filter = Control.MOUSE_FILTER_IGNORE

func detail(id: String) -> void:
	button(self,"‹ Danh sách vật phẩm",game._supply_open.bind(""))
	var art := TextureRect.new()
	art.texture = Supplies.icon(id)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.custom_minimum_size = Vector2(458,146)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	var title := words(self,Supplies.NAMES[id],24,GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words(self,"Đang có: %d" % Supplies.count(game.store.profile,id),19,GOLD)
	words(self,{"forge_stone":"Cường hóa1 cấp bằng1 đá + vàng theo cấp hiện tại, thay cho1 tinh thạch. Không đổi chi phí tiến bậc.",
	"memory_shard":"Tăng1 cấp một trong hai kỹ năng nhân vật bằng số mảnh bằng LV kỹ năng hiện tại. Không tốn vàng; tối đa LV10. Cách nâng bằng vàng vẫn giữ.",
	"ancient_seed":"Tinh luyện3 hạt thành1 Lõi tinh linh. Lõi dùng trong hệ tiến hóa hiện có.",
	"normal_ticket":"1 vé đổi1 lượt triệu hồi Thường theo pool và bảo hiểm hiện có. Không trừ vàng. Túi đầy hoặc lưu lỗi sẽ không mất vé.",
	"material_chest":"Mở1 rương và chọn đúng một phần thưởng:3 Đá Rèn Sáng,2 Mảnh Ký Ức hoặc3 Hạt Giống Cổ Thụ. Không ngẫu nhiên.",
	"rage_potion":"Chuẩn bị trước trận: +10% ATK cho đội trong1 lượt. Chỉ chọn1 loại thuốc. Tiêu khi bắt đầu, kể cả thua; tải lại trận không trừ thêm.",
	"ward_potion":"Chuẩn bị trước trận: +10% phòng thủ cho đội trong1 lượt. Chỉ chọn1 loại thuốc. Tiêu khi bắt đầu, kể cả thua; tải lại trận không trừ thêm.",
	"afk_hourglass":"Nhận ngay lượng vàng của2 giờ AFK theo mốc Hành trình hiện tại. Không làm mất thời gian AFK đang tích lũy; hiện AFK chỉ trả vàng."}[id],15)
	var busy := Supplies.busy(game.store)
	var owned := Supplies.count(game.store.profile,id)
	match id:
		"forge_stone":
			words(self,"Chọn đúng bản trang bị · Giữ UID và bậc",16,GOLD)
			for item in game.store.profile.items:
				var row: Dictionary = game.catalog.find_row("items",item.base)
				button(self,"%s +%d · %s\n%d vàng +1 đá" % [row.name,item.enhance,item.uid,(item.enhance+1)*20],game._supply_confirm.bind("stone",item.uid,0),busy or owned<1 or item.enhance>=15 or game.store.profile.gold<(item.enhance+1)*20)
		"memory_shard":
			var hero: String = game.supply_hero if not game.supply_hero.is_empty() else game.store.profile.hero
			var heroes := HBoxContainer.new()
			add_child(heroes)
			for row in game.catalog.data.heroes:
				var select: Button = game._button(heroes,row.name,Vector2.ZERO,Vector2(110,44),game._supply_hero.bind(row.id))
				select.disabled = not game.store.available_hero(row.id)
				if hero==row.id: select.modulate = GOLD
			for i in range(2):
				var level: int = game.store.profile.heroes[hero].skills[i]
				button(self,"%s · Kỹ năng%d · LV%d/10\nNâng1 cấp · %d mảnh" % [game.catalog.find_row("heroes",hero).name,i+1,level,level],game._supply_confirm.bind("train",hero,i),busy or level>=10 or owned<level or not game.store.available_hero(hero))
		"ancient_seed":
			button(self,"Tinh luyện3 hạt →1 Lõi tinh linh",game._supply_confirm.bind("seed","",0),busy or owned<3)
		"material_chest":
			for choice in Supplies.CHEST:
				button(self,"Chọn %d × %s" % [Supplies.CHEST[choice],Supplies.NAMES[choice]],game._supply_confirm.bind("chest",choice,0),busy or owned<1)
		"normal_ticket":
			for amount in [1,10]:
				button(self,"Triệu hồi ×%d · %d vé · Không trừ vàng" % [amount,amount],game._supply_confirm.bind("ticket","",amount),busy or owned<amount)
		"rage_potion","ward_potion":
			button(self,"Đã chuẩn bị" if game.store.profile.supplies.selected==id else "Chuẩn bị cho1 lượt",game._supply_confirm.bind("select",id,0),busy or owned<1 or game.store.profile.supplies.selected==id)
			if not game.store.profile.supplies.selected.is_empty(): button(self,"Bỏ vật phẩm chuẩn bị · Không mất thuốc",game._supply_confirm.bind("select","",0),busy)
			button(self,"Mua1 · %d vàng" % Supplies.SHOP[id],game._supply_confirm.bind("buy",id,0),busy or game.store.profile.gold<Supplies.SHOP[id])
		"afk_hourglass":
			button(self,"Dùng1 đồng hồ · +%d vàng" % game.store.offline_amount(7200),game._supply_confirm.bind("hourglass","",0),busy or owned<1)
	words(self,"✦ Nơi nhận",18,GOLD)
	match id:
		"forge_stone":
			words(self,"Thắng Tam Vệ:2 đá/lượt. Có trong rương lựa chọn. Hầm Rèn Cổ Đại sẽ bổ sung nguồn sau.",14)
			button(self,"Đến Tam Vệ Bình Minh →",game._supply_source.bind("dawn_wardens"))
		"memory_shard":
			words(self,"Thắng Tháp Sáu Đợt:2 mảnh/lượt. Có trong rương lựa chọn.",14)
			button(self,"Đến Tháp Sáu Đợt →",game._supply_source.bind("six_waves"))
		"ancient_seed":
			words(self,"Thắng Sân Cổ Thụ:1 hạt/lượt. Có trong rương lựa chọn.",14)
			button(self,"Đến Sân Cổ Thụ →",game._supply_source.bind("grove"))
		"material_chest","normal_ticket","afk_hourglass":
			words(self,"Quà tiến trình một lần sau khi vượt ải1/2/3, tương ứng rương/vé/đồng hồ. Người đã vượt vẫn nhận được nếu chưa nhận quà này.",14)
			button(self,"Xem quà tiến trình →",game._supply_milestones)
		_:
			words(self,"Có tại Cửa hàng vàng · 60 vàng/món.",14)
