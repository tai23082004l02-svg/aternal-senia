class_name SummonScreen
extends Control

var game
var draw_one: Button
var draw_ten: Button
var kind_buttons: Array[Button] = []
var pity_counter: PanelContainer
var featured: Array[Dictionary] = []
var featured_buttons: Array[Button] = []
var body: VBoxContainer

func words(parent: Node,value: String,font_size: int = 14,color: Color = Color("e4e8dc"),center: bool = false) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if center: label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label

func style(active: bool = false) -> StyleBoxFlat:
	var box: StyleBoxFlat = game._style(Color(.025,.13,.17,.96),Color("d6b877") if active else Color("8b927b"),16)
	box.set_content_margin_all(8)
	if active:
		box.bg_color = Color("37432e")
		box.shadow_color = Color(1,.66,.14,.35)
		box.shadow_size = 6
	return box

func button(parent: Node,value: String,callback: Callable,dimension: Vector2,active: bool = false) -> Button:
	var result: Button = game._button(parent,value,Vector2.ZERO,dimension,callback)
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.add_theme_font_size_override("font_size",14)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_stylebox_override("normal",style(active))
	var trim := GoldTrim.new()
	trim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.add_child(trim)
	trim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return result

func _ready() -> void:
	custom_minimum_size = Vector2(480,610)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",8)
	add_child(body)
	body.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	body.resized.connect(func(): custom_minimum_size.y = body.size.y)
	var active: bool = game.summon_kind == 0
	words(body,tr("✦ CỔNG TRIỆU HỒI ✦"),26,Color("f2d18b"),true)
	words(body,tr("Chọn banner để bắt đầu"),13,Color("ded2ae"),true)
	var kinds := HBoxContainer.new()
	kinds.add_theme_constant_override("separation",8)
	body.add_child(kinds)
	for i in range(3):
		var choice := button(kinds,tr(["Thường","Cao cấp","Sự kiện"][i]),game._select_summon_kind.bind(i),Vector2(140,36),game.summon_kind == i)
		game.icons.apply(choice,["summon","vip","event"][i],23)
		kind_buttons.append(choice)
	var banner := Control.new()
	banner.custom_minimum_size = Vector2(0,218)
	banner.clip_contents = true
	body.add_child(banner)
	var art := TextureRect.new()
	art.texture = load("res://art/summon/gateway.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_child(art)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := VBoxContainer.new()
	banner.add_child(title)
	title.anchor_right = .43
	title.offset_left = 18
	title.offset_right = -4
	title.offset_top = 35
	title.add_theme_constant_override("separation",8)
	words(title,tr(["CỔNG\nBÌNH MINH","CỔNG\nCAO CẤP","CỔNG\nSỰ KIỆN"][game.summon_kind]),27,Color("f7d68c"))
	words(title,tr("Nhân vật · Tinh linh · Trang bị") if active else tr("Đang chuẩn bị"),12,Color("eee1be"))
	var badge := PanelContainer.new()
	badge.add_theme_stylebox_override("panel",style())
	banner.add_child(badge)
	badge.anchor_left = .68
	badge.anchor_right = .97
	badge.offset_top = 10
	words(badge,tr("Minh họa Ryn") if active else tr("Sắp ra mắt"),11,Color("f3d28c"),true)
	if not active:
		pity_counter = PanelContainer.new()
		pity_counter.name = "BannerPityCounter"
		pity_counter.add_theme_stylebox_override("panel",style())
		banner.add_child(pity_counter)
		pity_counter.anchor_left = .04
		pity_counter.anchor_right = .96
		pity_counter.anchor_top = .77
		pity_counter.offset_bottom = 0
		var key := "premium" if game.summon_kind == 1 else "event"
		words(pity_counter,tr("Bảo hiểm: %d lượt · Mốc chưa cấu hình") % Recruitment.banner_pity(game.store.profile,key),12,Color("f3d28c"),true)
	var fit_banner := func():
		var reserved: float = pity_counter.get_combined_minimum_size().y+20 if pity_counter != null else 16.0
		banner.custom_minimum_size.y = maxf(218,title.offset_top+title.get_combined_minimum_size().y+reserved)
		if pity_counter != null:
			pity_counter.anchor_top = 0
			pity_counter.offset_top = banner.size.y-pity_counter.get_combined_minimum_size().y-12
	title.minimum_size_changed.connect(fit_banner)
	banner.resized.connect(fit_banner)
	if pity_counter != null: pity_counter.minimum_size_changed.connect(fit_banner)
	var reward_box := PanelContainer.new()
	reward_box.add_theme_stylebox_override("panel",style())
	body.add_child(reward_box)
	var reward_col := VBoxContainer.new()
	reward_col.add_theme_constant_override("separation",5)
	reward_box.add_child(reward_col)
	words(reward_col,tr("✦ Một số phần thưởng trong pool ✦") if active else tr("Pool phần thưởng chưa cấu hình"),13,Color("ead19a"),true)
	var items := HBoxContainer.new()
	items.add_theme_constant_override("separation",8)
	reward_col.add_child(items)
	if active:
		var pool: Array = []
		for tier in [1,2,3]: pool.append_array(Recruitment.pool(game.catalog,tier))
		for id in ["ryn","ash","spear_ember","armor_7","staff_tide"]:
			for entry in pool:
				if entry.id == id:
					featured.append(entry)
					feature(items,entry)
	else:
		words(items,tr("Tỷ lệ và phần thưởng sẽ được công bố khi mở banner."),12,Color("bacdcb"),true)
	var wallet := HBoxContainer.new()
	body.add_child(wallet)
	words(wallet,tr("Vàng: %d") % game.store.profile.gold,14,Color("e9cc82"),true)
	words(wallet,tr("Túi đồ: %d/%d") % [game.store.profile.items.size(),ProgressStore.BAG_CAP],13,Color("b9d4d0"),true)
	var draws := HBoxContainer.new()
	draws.add_theme_constant_override("separation",10)
	body.add_child(draws)
	draw_one = button(draws,tr("Triệu hồi ×1\n%d vàng") % Recruitment.PRICE if active else tr("Triệu hồi ×1\nChưa mở"),game._summon_confirm.bind(1),Vector2(220,60))
	draw_ten = button(draws,tr("Triệu hồi ×10\n%d vàng") % (Recruitment.PRICE*10) if active else tr("Triệu hồi ×10\nChưa mở"),game._summon_confirm.bind(10),Vector2(220,60),true)
	var ten_style := style(true)
	ten_style.bg_color = Color("654824")
	ten_style.border_color = Color("f6d18a")
	ten_style.shadow_size = 8
	draw_ten.add_theme_stylebox_override("normal",ten_style)
	for draw in [draw_one,draw_ten]:
		draw.add_theme_font_size_override("font_size",18)
		game.icons.apply(draw,"gold",26)
	draw_one.disabled = not active or game._locked() or game.store.profile.gold < Recruitment.PRICE
	draw_ten.disabled = not active or game._locked() or game.store.profile.gold < Recruitment.PRICE*10
	if active:
		var tickets := button(body,tr("Vé Thường: %d · Chọn dùng vé →") % Supplies.count(game.store.profile,"normal_ticket"),game._supply_open.bind("normal_ticket"),Vector2(440,44))
		game.icons.apply(tickets,"normal_ticket",26)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation",7)
	body.add_child(actions)
	var rates := button(actions,tr("Tỷ lệ & quy tắc"),game._summon_rates,Vector2(140,36))
	rates.disabled = not active
	button(actions,tr("Lịch sử triệu hồi"),game._summon_history,Vector2(140,36))
	button(actions,tr("Xem phần thưởng"),preview_rewards,Vector2(140,36))
	var note := PanelContainer.new()
	note.add_theme_stylebox_override("panel",style())
	body.add_child(note)
	words(note,tr("Banner minh họa Ryn · Không tăng tỷ lệ riêng. Xem quy tắc trước khi quay.") if active else tr("Banner chưa mở · Mốc bảo hiểm chờ cấu hình. Chưa tiêu tài nguyên."),12,Color("c7d5ca"),true)

func feature(parent: Node,entry: Dictionary) -> void:
	var tile := button(parent,"",show_feature.bind(entry),Vector2(64,60),entry.kind == "hero")
	featured_buttons.append(tile)
	tile.tooltip_text = game._entity_name(entry.kind,entry.id)
	var frame := style(entry.kind == "hero")
	frame.border_color = Recruitment.color(entry.kind,entry.id,game.catalog)
	tile.add_theme_stylebox_override("normal",frame)
	if entry.kind == "hero":
		var face := CharacterScreen.Face.new()
		face.frames = game.frames
		face.hero = entry.id
		face.size = Vector2(46,46)
		face.position = Vector2(10,6)
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(face)
		center_art(face,46)
	elif entry.kind == "item":
		var image := EquipmentArt.add_to(tile,game,entry.id,entry.rarity,54)
		center_art(image,54)
	else:
		var icon := TextureRect.new()
		icon.texture = game.frames.textures["companion_"+entry.id]
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size = Vector2(46,46)
		icon.position = Vector2(10,6)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(icon)
		center_art(icon,46)

func center_art(control: Control,dimension: float) -> void:
	control.set_anchors_preset(Control.PRESET_CENTER)
	control.offset_left = -dimension*.5
	control.offset_top = -dimension*.5
	control.offset_right = dimension*.5
	control.offset_bottom = dimension*.5

func show_feature(entry: Dictionary) -> void:
	SummonScreen.show_text(game,tr("XEM PHẦN THƯỞNG"),tr("%s · %s\n\nCó trong pool triệu hồi Thường. Hình minh họa không tăng tỷ lệ hoặc bảo đảm nhận món này.") % [tr(game._entity_name(entry.kind,entry.id)),tr(game._rarity(entry.kind,entry.id))])

func preview_rewards() -> void:
	if game.summon_kind != 0:
		SummonScreen.show_text(game,tr("PHẦN THƯỞNG"),tr("Pool phần thưởng chưa được cấu hình cho banner này."))
		return
	var lines: Array[String] = []
	for tier in [1,2,3]:
		lines.append(tr("NHÓM %s") % tr(Recruitment.GROUP_NAMES[tier]))
		for entry in Recruitment.pool(game.catalog,tier): lines.append("• %s · %s" % [tr(game._entity_name(entry.kind,entry.id)),tr(game._rarity(entry.kind,entry.id))])
	SummonScreen.show_text(game,tr("POOL PHẦN THƯỞNG"),"\n".join(lines))

class GoldTrim extends Control:
	func _draw() -> void:
		var color := Color(.91,.74,.4,.65)
		for x in [4.0,size.x-4]:
			var c := Vector2(x,size.y*.5)
			draw_polyline(PackedVector2Array([c+Vector2(0,-7),c+Vector2(3,0),c+Vector2(0,7),c+Vector2(-3,0),c+Vector2(0,-7)]),color,1,true)

static func show_text(game, title: String, text: String) -> void:
	var column: VBoxContainer = game._dialog(title, "", [{"text": "Đóng", "call": game._close_modal}])
	var box: PanelContainer = column.get_parent().get_parent()
	box.position.y = 150
	box.set_deferred("size", Vector2(472, 650))
	var scroll := SwipeScroll.new()
	scroll.custom_minimum_size = Vector2(400, 420)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var body := Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size", 16)
	body.text = text
	scroll.add_child(body)
	column.add_child(scroll)
	column.move_child(scroll, 1)

static func show_results(game, title: String, entries: Array) -> void:
	var lines: Array[String] = []
	for i in range(entries.size()):
		var entry: Dictionary = entries[i]
		var suffix := CollectionFragments.reward_suffix(entry)
		lines.append("%d. %s · %s%s" % [i + 1, game._rarity(entry.kind, entry.id), game._entity_name(entry.kind, entry.id), suffix])
	show_text(game, title, "Mới nhất ở trên · Lưu tối đa 100 lượt\n\n" + ("\n\n".join(lines) if not lines.is_empty() else "Chưa có lịch sử triệu hồi."))
