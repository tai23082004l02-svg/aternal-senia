class_name CharacterScreen
extends Control

const SECTIONS := ["Thông tin", "Trang bị", "Cường hóa", "Mở rộng", "Tiến hóa", "Kỹ năng", "Trang phục"]
const ICONS := ["hero", "equipment", "training", "awakening", "evolution", "talents", "wardrobe"]
var game
var hero := "eira"
var section := 0
var body: VBoxContainer
var detail_scroll: ScrollContainer
var faces: Array[Button] = []
var face_buttons: Dictionary = {}
var section_buttons: Array[Button] = []

const TAB_NAMES := ["Thông tin", "Trang bị", "Phát triển", "Kỹ năng", "Trang phục"]
const TAB_PAGES := [0, 1, 2, 5, 6]
const TAB_ICONS := ["journal", "equipment", "evolution", "talents", "wardrobe"]
var development_buttons: Array[Button] = []

func _ready() -> void:
	custom_minimum_size = Vector2(492, 720)
	var roster := VBoxContainer.new()
	roster.position = Vector2.ZERO
	roster.size = Vector2(66, 640)
	roster.add_theme_constant_override("separation", 10)
	add_child(roster)
	var roster_rows: Array = game.catalog.data.heroes.duplicate()
	var order := ["eira","mira","ryn","lyra"]
	roster_rows.sort_custom(func(a,b): return (order.find(a.id) if a.id in order else 99) < (order.find(b.id) if b.id in order else 99))
	for row in roster_rows:
		var face_button: Button = game._button(roster, "", Vector2.ZERO, Vector2(66, 96), game._inspect_character.bind(row.id))
		var owned: bool = game.store.available_hero(row.id)
		face_button.tooltip_text = row.name + ("" if owned else " · Chưa sở hữu")
		var face := Face.new()
		face.frames = game.frames
		face.hero = row.id
		face.dimmed = not owned
		face.position = Vector2(6, 3)
		face.size = Vector2(54, 54)
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		face_button.add_child(face)
		var name_label: Label = game._label(face_button, row.name, Vector2(0, 59), 12, Color("e8d7ac"))
		name_label.size.x = 66
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var level: Label = game._label(face_button, "LV%d" % game.store.profile.heroes[row.id].level if owned else "Chưa có", Vector2(0, 77), 11)
		level.size.x = 66
		level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if row.id == hero: face_button.add_theme_stylebox_override("normal", gold_style(true))
		faces.append(face_button)
		face_buttons[row.id] = face_button
	var menu := HBoxContainer.new()
	menu.position = Vector2(0, 654)
	menu.size = Vector2(492, 66)
	menu.add_theme_constant_override("separation", 6)
	add_child(menu)
	for i in range(TAB_NAMES.size()):
		var b: Button = game._button(menu, TAB_NAMES[i], Vector2.ZERO, Vector2(93, 66), game._character_section.bind(TAB_PAGES[i]))
		game.icons.tab(b, TAB_ICONS[i])
		b.custom_minimum_size = Vector2(93, 66)
		b.size = Vector2(93, 66)
		b.get_child(1).position.y = 39
		b.get_child(1).add_theme_font_size_override("font_size", 11)
		if section == TAB_PAGES[i] or i == 2 and section in [2,3,4]: b.add_theme_stylebox_override("normal", gold_style(true))
		section_buttons.append(b)
	var frame := PanelContainer.new()
	frame.position = Vector2(76, 0)
	frame.size = Vector2(416, 642)
	frame.add_theme_stylebox_override("panel", game._style(Color(.035,.1,.14,.87), Color("69715f"), 13))
	add_child(frame)
	detail_scroll = ScrollContainer.new()
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	frame.add_child(detail_scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	detail_scroll.add_child(body)
	var p: Dictionary = game.store.profile
	var row: Dictionary = game.catalog.find_row("heroes", hero)
	var heading := HBoxContainer.new()
	body.add_child(heading)
	var element := TextureRect.new()
	element.texture = game.icons.textures.get(row.element, game.icons.textures.light)
	element.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	element.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	element.custom_minimum_size = Vector2(30, 39)
	heading.add_child(element)
	var title := VBoxContainer.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	game._label(title, row.name, Vector2.ZERO, 24, Color("f1dfb0"))
	game._label(title, row.title, Vector2.ZERO, 12, Color("a8c6c8"))
	game._button(heading, "?", Vector2.ZERO, Vector2(30, 30), game._character_help).add_theme_font_size_override("font_size", 13)
	text("★".repeat(Recruitment.rarity("hero", hero, game.catalog)), 18, Color("efbf67"))
	if not game.store.available_hero(hero):
		text("Chưa sở hữu · Vượt chương %d hoặc triệu hồi để mở." % (row.unlock - 1), 12)
		button("Đến Shop →", game._select_tab.bind(20))
	if section in [2,3,4]:
		var development := HBoxContainer.new()
		development.add_theme_constant_override("separation", 6)
		body.add_child(development)
		for pair in [["Nâng cấp",2],["Tiến hóa",4],["Thức tỉnh",3]]:
			var b: Button = game._button(development, pair[0], Vector2.ZERO, Vector2(116, 37), game._character_section.bind(pair[1]))
			b.add_theme_font_size_override("font_size", 13)
			if section == pair[1]: b.add_theme_stylebox_override("normal", gold_style(true))
			development_buttons.append(b)
	match section:
		0: info()
		1: equipment()
		2: levels()
		3: stars_panel()
		4: evolution()
		5: skills()
		6: outfits()

func gold_style(active: bool = false) -> StyleBoxFlat:
	var style = game._style(Color("493c25") if active else Color("142e3a"), Color("dfbc72") if active else Color("60716b"), 11)
	if active:
		style.shadow_color = Color(1,.66,.2,.25)
		style.shadow_size = 6
	return style

func text(value: String, font_size: int = 14, color: Color = Color("c0d0cb")) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size.x = 350
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	body.add_child(label)
	return label

func button(title: String, action: Callable, disabled: bool = false) -> Button:
	var b: Button = game._button(body, title, Vector2.ZERO, Vector2(350, 44), action)
	b.add_theme_font_size_override("font_size", 13)
	b.clip_text = true
	b.tooltip_text = title
	b.disabled = disabled
	game.icons.action(b, action)
	return b

func locked() -> bool:
	return game._locked() or not game.store.available_hero(hero)

func portrait(height: int = 245) -> void:
	var stage := Control.new()
	stage.custom_minimum_size = Vector2(350, height)
	body.add_child(stage)
	make_portrait(stage, height)

func make_portrait(parent: Control, height: int) -> HeroPortrait:
	var backdrop := MagicBackdrop.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(backdrop)
	var view := HeroPortrait.new()
	view.library = game.frames
	view.hero = hero
	view.weapon = game.catalog.stats(game.store.profile, hero).weapon
	view.interactive = game.store.available_hero(hero) and Recruitment.rarity("hero", hero, game.catalog) == 5
	view.fit_actor = true
	view.palette_tint = Wardrobe.tint(game.store.profile, hero)
	if section == 6 and game.character_outfit_preview in Wardrobe.LOOKS: view.palette_tint = Wardrobe.LOOKS[game.character_outfit_preview].tint
	view.custom_minimum_size = Vector2(230, height)
	parent.add_child(view)
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view.tooltip_text = "Chạm hoặc kéo nhẹ để tương tác" if view.interactive else "Nhân vật chưa sở hữu"
	return view

func stats_line(p: Dictionary) -> void:
	var stats: Dictionary = game.catalog.stats(p, hero)
	text("HP %.0f\nTấn công %.1f\nPhòng thủ %.2f\nChí mạng %.0f%%" % [stats.hp, stats.atk, stats.defense, stats.crit * 100], 15)

func preview(next: Dictionary) -> void:
	var current: Dictionary = game.catalog.stats(game.store.profile, hero)
	var after: Dictionary = game.catalog.stats(next, hero)
	text("CHỈ SỐ SAU NÂNG", 14, Color("e5cd9e"))
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", gold_style())
	body.add_child(panel)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 10)
	panel.add_child(grid)
	for pair in [["HP","hp"],["Tấn công","atk"],["Phòng thủ","defense"]]:
		for value in [pair[0], str(snappedf(current[pair[1]], .01)), "→  " + str(snappedf(after[pair[1]], .01))]:
			var label := Label.new()
			label.text = value
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.add_theme_font_size_override("font_size", 14)
			if value.begins_with("→"): label.modulate = Color("a4dfa5")
			grid.add_child(label)

func resource_tiles(entries: Array) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	body.add_child(row)
	for entry in entries:
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.add_theme_stylebox_override("panel", gold_style())
		row.add_child(panel)
		var column := VBoxContainer.new()
		panel.add_child(column)
		var image := TextureRect.new()
		image.texture = game.icons.textures[entry[0]]
		image.custom_minimum_size = Vector2(46,46)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		column.add_child(image)
		var label := Label.new()
		label.text = "%d / %d" % [entry[1],entry[2]]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 12)
		label.modulate = Color("b6ddb4") if entry[1] >= entry[2] else Color("dfb895")
		column.add_child(label)

func info() -> void:
	var p: Dictionary = game.store.profile
	var row: Dictionary = game.catalog.find_row("heroes", hero)
	portrait(245)
	var stats: Dictionary = game.catalog.stats(p, hero)
	text("✦ Lực chiến ước tính %d" % int(stats.hp + stats.atk*10 + stats.defense*6), 18, Color("edcc81")).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var chips := HBoxContainer.new()
	chips.add_theme_constant_override("separation", 6)
	body.add_child(chips)
	for value in ["LV %d/100" % p.heroes[hero].level, "Tiến hóa %d/3" % HeroEvolution.rank(p, hero), "Thức tỉnh %d/5" % Recruitment.state(p).awakening[hero]]:
		var chip := Label.new()
		chip.text = value
		chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		chip.add_theme_font_size_override("font_size", 11)
		chip.add_theme_stylebox_override("normal", gold_style())
		chips.add_child(chip)
	stat_tiles(stats)
	var passive := PanelContainer.new()
	passive.add_theme_stylebox_override("panel", gold_style())
	body.add_child(passive)
	var description := Label.new()
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.text = "ĐẶC TÍNH\n" + row.passive
	description.add_theme_font_size_override("font_size", 12)
	passive.add_child(description)
	button("Xếp vào đội hình →", game._select_tab.bind(22))
	if hero == "ryn": button("Xem Ryn phóng lớn →", game._show_ryn_portrait)
	if p.hero == hero: button("Điểm thuộc tính →", game._select_tab.bind(9))

func stat_tiles(stats: Dictionary) -> void:
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	body.add_child(grid)
	for pair in [["HP",str(int(stats.hp)),"heal"],["Tấn công",str(int(stats.atk)),"slash"],["Phòng thủ",str(snappedf(stats.defense,.01)),"guard"],["Chí mạng","%d%%" % (stats.crit*100),"talents"]]:
		var box := PanelContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_theme_stylebox_override("panel", gold_style())
		grid.add_child(box)
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 2)
		box.add_child(col)
		var image := TextureRect.new()
		image.texture = game.icons.textures[pair[2]]
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(23,23)
		col.add_child(image)
		for value in [pair[0],pair[1]]:
			var label := Label.new()
			label.text = value
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 10 if value == pair[0] else 14)
			col.add_child(label)

func equipment() -> void:
	var p: Dictionary = game.store.profile
	var stage := Control.new()
	stage.custom_minimum_size = Vector2(350, 290)
	body.add_child(stage)
	var view := make_portrait(stage, 290)
	view.offset_left = 62
	view.offset_right = -62
	for index in range(EquipmentSystem.SLOTS.size()):
		var slot_name: String = EquipmentSystem.SLOTS[index]
		var current := EquipmentSystem.item_for(p, p.heroes[hero].equipment[slot_name])
		var action: Callable = game._character_gear_picker.bind(hero, slot_name) if current.is_empty() else game._character_item_detail.bind(current.uid, hero)
		var card: Button = game._button(stage, "", Vector2(0 if index % 2 == 0 else 290, 25 if index < 2 else 165), Vector2(68, 105), action)
		card.name = "EquipmentSlot_" + slot_name
		card.tooltip_text = EquipmentSystem.SLOT_NAMES[slot_name]
		card.add_theme_stylebox_override("normal", gold_style())
		if not current.is_empty():
			var definition: Dictionary = game.catalog.find_row("items",current.base)
			var art := EquipmentArt.add_to(card,game,current.base,definition.rarity,66)
			art.position = Vector2(1,0)
		else:
			var empty: Label = game._label(card,"+",Vector2(0,12),26,Color("8aa6aa"))
			empty.size.x = 68
			empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var detail: Label = game._label(card, EquipmentSystem.SLOT_NAMES[slot_name] + ("\nChưa mặc" if current.is_empty() else "\nBậc%d · +%d" % [current.rank,current.enhance]), Vector2(0,65), 11, Color("e5ce95"))
		detail.size.x = 68
		detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var counts := EquipmentSystem.set_counts(game.catalog,p,hero)
	var has_set := false
	for set_def in game.catalog.data.sets:
		if not counts.has(set_def.id): continue
		has_set = true
		text("BỘ " + set_def.name.to_upper() + " · %d/4" % counts[set_def.id],15,Color("e5cd9e"))
		for bonus in set_def.bonuses:
			text(("✓ " if counts[set_def.id] >= bonus.pieces else "○ ") + "%d món: %s" % [bonus.pieces,bonus.description],12)
	if not has_set: text("Chưa kích hoạt bộ trang bị.",13)
	text("Chạm món để xem chỉ số và cường hóa; chạm ô trống để chọn đồ. Các nhân vật phù hợp có thể dùng chung trang bị.",12)
	button("Mở kho trang bị →", game._bag_open.bind("equipment"))

func levels() -> void:
	var p: Dictionary = game.store.profile
	var level: int = p.heroes[hero].level
	text("LV %d/100" % level, 26, Color("f0ddb2")).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var experience := ProgressBar.new()
	experience.value = minf(100, float(p.xp) / maxi(1, level*15) * 100)
	experience.show_percentage = false
	experience.custom_minimum_size.y = 14
	var background := StyleBoxFlat.new()
	background.bg_color = Color("203d49")
	background.set_corner_radius_all(6)
	var fill := background.duplicate()
	fill.bg_color = Color("b5a265")
	experience.add_theme_stylebox_override("background",background)
	experience.add_theme_stylebox_override("fill",fill)
	body.add_child(experience)
	text("XP khả dụng: %d / %d cần cho LV tiếp" % [p.xp, level*15], 12)
	if level >= 100:
		text("Đã đạt LV tối đa 100", 16, Color("e5cd9e"))
		stats_line(p)
		return
	var next: Dictionary = p.duplicate(true)
	next.heroes[hero].level += 1
	preview(next)
	text("Mỗi LV nhận thêm 2 điểm thuộc tính.", 13)
	resource_tiles([["xp",p.xp,level*15],["gold",p.gold,level*30]])
	button("Tăng 1 LV", game._character_level.bind(hero, 1), locked() or p.gold < level * 30 or p.xp < level * 15)
	var count := mini(5, 100 - level)
	var total: int = count * level + count * (count - 1) / 2
	text("Tăng %d LV: %d vàng + %d XP" % [count, total * 30, total * 15], 13)
	button("Tăng %d LV" % count, game._character_level.bind(hero, count), locked() or p.gold < total * 30 or p.xp < total * 15)

func stars_panel() -> void:
	var p: Dictionary = game.store.profile
	var r := Recruitment.state(p)
	var stars: int = r.awakening[hero]
	text("MỞ RỘNG · TĂNG SAO", 16, Color("e5cd9e"))
	text("Dùng mảnh đúng nhân vật để tăng sao mở rộng. Mỗi sao thêm 30 HP, 3 ATK, 1 phòng thủ; tách biệt độ hiếm gốc và tương tác đã thiết kế sẵn.", 13)
	if stars >= 5:
		text("Đã đạt 5 sao mở rộng tối đa.", 15)
		return
	var next: Dictionary = p.duplicate(true)
	Recruitment.ensure(game.store, next)
	next.recruitment.awakening[hero] += 1
	preview(next)
	text("Cần LV %d · hiện tại %d\nMảnh %d / %d\nVàng %d / %d" % [stars * 10, p.heroes[hero].level, r.fragments[hero], stars * 20, p.gold, stars * 200])
	button("Sao mở rộng %d → %d" % [stars, stars + 1], game._character_stars.bind(hero), locked() or p.heroes[hero].level < stars * 10 or r.fragments[hero] < stars * 20 or p.gold < stars * 200)

func evolution() -> void:
	var p: Dictionary = game.store.profile
	var tier := HeroEvolution.rank(p, hero)
	text("TIẾN HÓA · BẬC %d/3" % tier, 16, Color("a2e5d6"))
	text("Mỗi bậc tăng 8% HP, ATK, phòng thủ. Tách biệt với tăng sao, dùng tinh thạch và lõi tinh linh.", 13)
	if tier >= 3:
		text("Đã tiến hóa tối đa.")
		return
	var next: Dictionary = p.duplicate(true)
	if not next.has("evolution"): next.evolution = HeroEvolution.fresh()
	next.evolution[hero] += 1
	preview(next)
	text("Cần LV %d · hiện tại %d\nSao mở rộng %d · hiện tại %d\nVàng %d / %d\nTinh thạch %d / %d\nLõi %d / %d" % [tier * 15, p.heroes[hero].level, tier + 1, Recruitment.state(p).awakening[hero], p.gold, tier * 250, p.shards, tier * 10, p.expansion.cores, tier * 3])
	button("Tiến hóa lên bậc %d" % (tier + 1), game._character_evolve.bind(hero), locked() or not HeroEvolution.eligible(game.store, hero))

func skills() -> void:
	var switch := HBoxContainer.new()
	switch.add_theme_constant_override("separation", 6)
	body.add_child(switch)
	for key in ["overview","tree"]:
		var b: Button = game._button(switch, "Kỹ năng" if key == "overview" else "Thiên phú", Vector2.ZERO, Vector2(175,37), game._character_skill_view.bind(key))
		if game.character_skill_view == key: b.add_theme_stylebox_override("normal", gold_style(true))
	if game.character_skill_view == "tree":
		talents_tree()
		return
	var p: Dictionary = game.store.profile
	var unit: Dictionary = p.heroes[hero]
	for entry in [["Đánh thường","Tự đánh mục tiêu ưu tiên, tích lũy nộ khi ra đòn.","slash","Đánh thường"],["Kỹ năng cơ bản", "Phép tấn công; chuyển sang trị liệu khi đồng đội dưới 85% HP." if hero == "mira" else "Tự dùng kỹ năng gây sát thương theo hồi chiêu.","heal_spell" if hero == "mira" else "slash_spell","Kỹ năng"],["Ultimate", "Hồi phục và tạo khiên cho đồng đội còn sống. Cần 100 nộ." if hero == "mira" else "Gây sát thương nhiều mục tiêu, hồi phục bản thân; Ryn thêm khiên. Cần 100 nộ.","burst","Ultimate"],["Đặc tính", game.catalog.find_row("heroes",hero).passive,"water" if hero == "mira" else "talents","Bị động"]]:
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", gold_style())
		body.add_child(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		panel.add_child(row)
		var image := TextureRect.new()
		image.texture = game.icons.textures[entry[2]]
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(46,46)
		row.add_child(image)
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(col)
		var name_label := Label.new()
		name_label.text = entry[0] if entry[0] == entry[3] else entry[0] + " · " + entry[3]
		name_label.add_theme_font_size_override("font_size", 15)
		name_label.modulate = Color("ead29d")
		col.add_child(name_label)
		var description := Label.new()
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.text = entry[1]
		description.add_theme_font_size_override("font_size", 12)
		col.add_child(description)
	for i in range(2):
		button("Nâng %s · LV%d/10 · %d vàng" % ["kỹ năng tấn công" if i == 0 else "hồi phục/khiên",unit.skills[i],unit.skills[i]*25],game._character_skill_level.bind(hero,i),locked() or unit.skills[i]>=10 or p.gold<unit.skills[i]*25)
	button("Cây kỹ năng tinh linh →", game._select_tab.bind(13))

func talents_tree() -> void:
	var build: Dictionary = game.store.profile.expansion.builds[hero]
	var rows := []
	for row in game.catalog.data.talents:
		if row.slot < 2: rows.append(row)
	var tree := TalentMap.new()
	tree.custom_minimum_size = Vector2(350,280)
	tree.rows = rows
	tree.chosen = build.selected
	tree.learned = build.learned
	tree.game = game
	body.add_child(tree)
	var selected: Dictionary = {}
	for row in rows:
		if row.id == game.character_talent_focus: selected = row
	if selected.is_empty(): selected = rows[0]
	var owned: bool = selected.id in build.learned
	var chosen: bool = build.selected[selected.slot] == selected.id
	text(selected.name + (" · Đang chọn" if chosen else ""), 18, Color("e5cd9e"))
	text(selected.description, 14)
	text("Cần LV%d · %d vàng + %d tinh thạch" % [selected.level,selected.gold,selected.shards] if not owned else "Đã học · Chọn hoặc bỏ nhánh miễn phí ngoài trận", 12)
	button("Bỏ chọn" if chosen else ("Chọn nhánh" if owned else "Học thiên phú"),game._character_talent.bind(hero,selected.id),locked() or game.store.profile.heroes[hero].level < selected.level or not owned and (game.store.profile.gold<selected.gold or game.store.profile.shards<selected.shards))

func outfits() -> void:
	var p: Dictionary = game.store.profile
	var current := Wardrobe.selected(p, hero)
	var preview_id: String = game.character_outfit_preview if game.character_outfit_preview in Wardrobe.LOOKS else current
	portrait(300)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	body.add_child(row)
	for id in Wardrobe.LOOKS:
		var b: Button = game._button(row, "", Vector2.ZERO, Vector2(112,115),game._preview_character_outfit.bind(id))
		b.add_theme_stylebox_override("normal",gold_style(preview_id == id))
		var face := Face.new()
		face.frames = game.frames
		face.hero = hero
		face.modulate = Wardrobe.LOOKS[id].tint
		face.position = Vector2(30,4)
		face.size = Vector2(52,52)
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(face)
		var name_label: Label = game._label(b,{"original":"Mặc định","dawn":"Bình minh","moon":"Ánh trăng"}[id],Vector2(0,64),12,Color("e7d3a5"))
		name_label.size.x = 112
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var status: Label = game._label(b,"✓ Đang dùng" if id == current else "Xem trước",Vector2(0,87),10)
		status.size.x = 112
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text("Các phối màu miễn phí hiện có; không đổi chỉ số. Chưa có bộ quần áo mới.",12)
	button("Đang sử dụng" if current == preview_id else "Áp dụng phối màu", game._apply_character_outfit.bind(hero,preview_id),locked() or current == preview_id)
	if hero == "ryn": button("Xem Ryn phóng lớn →",game._show_ryn_portrait)

class Face extends Control:
	var frames: FrameLibrary
	var hero := "eira"
	var dimmed := false
	func _draw() -> void:
		if frames.painted.get("portraits", {}).has(hero):
			var rect: Array = frames.painted.portraits[hero].face
			draw_texture_rect_region(frames.textures["portrait_" + hero], Rect2(Vector2.ZERO, size), Rect2(rect[0], rect[1], rect[2], rect[3]), Color(.5, .5, .5, 1) if dimmed else Color.WHITE)
			return
		var frame := frames.frame_at(hero, "idle", 0)
		var region := Rect2(95, 0, 135, 135) if hero in ["eira", "mira", "lyra"] else Rect2(48, 25, 96, 100)
		draw_texture_rect_region(frames.textures[frame.file], Rect2(Vector2.ZERO, size), region, Color(.5, .5, .5, 1) if dimmed else Color.WHITE)

class MagicBackdrop extends Control:
	func _draw() -> void:
		var center := size * Vector2(.5,.52)
		var radius := minf(size.x*.4,size.y*.44)
		for r in [radius,radius*.86,radius*.68]: draw_arc(center,r,0,TAU,72,Color(.3,.62,.68,.23),1,true)
		for i in range(16):
			var direction := Vector2.from_angle(i*TAU/16)
			draw_line(center+direction*radius*.92,center+direction*radius,Color(.7,.65,.39,.25),1,true)

class TalentMap extends Control:
	var game
	var rows: Array
	var chosen: Array
	var learned: Array
	var nodes: Array[Button] = []
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		for row in rows:
			var button: Button = game._button(self,"",Vector2.ZERO,Vector2(48,48),game._character_talent_focus.bind(row.id))
			button.tooltip_text = row.name
			button.add_theme_stylebox_override("normal",game._style(Color("294237") if row.id in chosen else Color("173442"),Color("dabe7d") if row.id == game.character_talent_focus or row.id in learned else Color("52747a"),24))
			var icon := TextureRect.new()
			icon.texture = game.icons.textures[{"focus":"slash","breaker":"spirit","restoration":"heal","barrier":"guard"}[row.id]]
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.position = Vector2(9,7)
			icon.size = Vector2(30,30)
			icon.modulate = Color.WHITE if row.id in learned else Color(.6,.7,.75)
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(icon)
			if row.id in chosen:
				var check: Label = game._label(button,"✓",Vector2(30,29),12,Color("a8edba"))
				check.mouse_filter = Control.MOUSE_FILTER_IGNORE
			nodes.append(button)
		_layout()
		resized.connect(_layout)
	func _layout() -> void:
		for i in range(nodes.size()): nodes[i].position = size*.5 + Vector2.from_angle(-PI*.5+i*TAU/nodes.size())*100 - Vector2(24,24)
		queue_redraw()
	func _draw() -> void:
		var center := size*.5
		for radius in [76,100,122]: draw_arc(center,radius,0,TAU,80,Color(.55,.6,.36,.35),1,true)
		for i in range(rows.size()): draw_line(center,center+Vector2.from_angle(-PI*.5+i*TAU/rows.size())*100,Color(.32,.7,.85,.7),2,true)
		draw_circle(center,29,Color("153b4b"))
		draw_arc(center,30,0,TAU,40,Color("bba56b"),2,true)
		var element: String = game.catalog.find_row("heroes",game.character_inspected).element
		draw_texture_rect(game.icons.textures.get(element,game.icons.textures.talents),Rect2(center-Vector2(23,23),Vector2(46,46)),false)
