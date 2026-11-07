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
var section_buttons: Array[Button] = []

func _ready() -> void:
	custom_minimum_size = Vector2(492, 720)
	var roster := VBoxContainer.new()
	roster.position = Vector2.ZERO
	roster.size = Vector2(58, 720)
	roster.add_theme_constant_override("separation", 10)
	add_child(roster)
	for row in game.catalog.data.heroes:
		var face_button: Button = game._button(roster, "", Vector2.ZERO, Vector2(58, 76), game._inspect_character.bind(row.id))
		face_button.tooltip_text = row.name
		var face := Face.new()
		face.frames = game.frames
		face.hero = row.id
		face.dimmed = not game.store.available_hero(row.id)
		face.position = Vector2(3, 3)
		face.size = Vector2(52, 52)
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		face_button.add_child(face)
		var name_label: Label = game._label(face_button, row.name, Vector2(0, 57), 11)
		name_label.size.x = 58
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if row.id == hero:
			face_button.add_theme_stylebox_override("normal", game._style(Color("304339"), Color("dcc28a"), 10))
		faces.append(face_button)
	var menu := VBoxContainer.new()
	menu.position = Vector2(66, 0)
	menu.size = Vector2(104, 720)
	menu.add_theme_constant_override("separation", 8)
	add_child(menu)
	for i in range(SECTIONS.size()):
		var b: Button = game._button(menu, SECTIONS[i], Vector2.ZERO, Vector2(104, 72), game._character_section.bind(i))
		game.icons.tab(b, ICONS[i])
		b.custom_minimum_size = Vector2(104, 72)
		b.size = Vector2(104, 72)
		b.get_child(0).position.x = 36
		b.get_child(1).position.y = 43
		b.get_child(1).size.x = 104
		if section == i:
			b.add_theme_stylebox_override("normal", game._style(Color("304339"), Color("dcc28a"), 10))
		section_buttons.append(b)
	var frame := PanelContainer.new()
	frame.position = Vector2(178, 0)
	frame.size = Vector2(314, 720)
	frame.add_theme_stylebox_override("panel", game._style(Color("111f2c"), Color("3b505c"), 12))
	add_child(frame)
	detail_scroll = ScrollContainer.new()
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	frame.add_child(detail_scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	detail_scroll.add_child(body)
	var p: Dictionary = game.store.profile
	var row: Dictionary = game.catalog.find_row("heroes", hero)
	text(row.name + " · " + SECTIONS[section], 19, Color("e5cd9e"))
	var stars: int = Recruitment.state(p).awakening[hero]
	var native_stars: int = Recruitment.rarity("hero", hero, game.catalog)
	text("★".repeat(native_stars) + " · LV %d · Tiến hóa %d" % [p.heroes[hero].level, HeroEvolution.rank(p, hero)], 13, Color("e5cd9e"))
	text("Sao mở rộng: %d/5" % stars, 12)
	if not game.store.available_hero(hero):
		text("Chưa mở. Vượt chương %d hoặc nhận từ triệu hồi." % (row.unlock - 1), 13)
		button("Đến Shop →", game._select_tab.bind(20))
	match section:
		0: info()
		1: equipment()
		2: levels()
		3: stars_panel()
		4: evolution()
		5: skills()
		6: outfits()

func text(value: String, font_size: int = 14, color: Color = Color("c0d0cb")) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size.x = 260
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	body.add_child(label)
	return label

func button(title: String, action: Callable, disabled: bool = false) -> Button:
	var b: Button = game._button(body, title, Vector2.ZERO, Vector2(268, 46), action)
	b.add_theme_font_size_override("font_size", 13)
	b.clip_text = true
	b.tooltip_text = title
	b.disabled = disabled
	game.icons.action(b, action)
	return b

func locked() -> bool:
	return game._locked() or not game.store.available_hero(hero)

func portrait() -> void:
	var view := HeroPortrait.new()
	view.library = game.frames
	view.hero = hero
	view.weapon = game.catalog.stats(game.store.profile, hero).weapon
	view.interactive = game.store.available_hero(hero) and Recruitment.rarity("hero", hero, game.catalog) == 5
	view.palette_tint = Wardrobe.tint(game.store.profile, hero)
	if section == 6 and game.character_outfit_preview in Wardrobe.LOOKS:
		view.palette_tint = Wardrobe.LOOKS[game.character_outfit_preview].tint
	view.custom_minimum_size = Vector2(260, 350 if hero == "ryn" else 205)
	body.add_child(view)
	text("Chạm hoặc kéo nhẹ để tương tác" if view.interactive else "Tạo hình tĩnh", 11)
	if hero == "ryn": button("Xem Ryn phóng lớn →", game._show_ryn_portrait)

func stats_line(p: Dictionary) -> void:
	var stats: Dictionary = game.catalog.stats(p, hero)
	text("HP %.0f\nTấn công %.1f\nPhòng thủ %.2f\nChí mạng %.0f%%" % [stats.hp, stats.atk, stats.defense, stats.crit * 100], 15)

func preview(next: Dictionary) -> void:
	var current: Dictionary = game.catalog.stats(game.store.profile, hero)
	var after: Dictionary = game.catalog.stats(next, hero)
	text("Chỉ số sau nâng", 15, Color("a2e5d6"))
	text("HP %.0f → %.0f\nATK %.1f → %.1f\nThủ %.2f → %.2f" % [current.hp, after.hp, current.atk, after.atk, current.defense, after.defense])

func info() -> void:
	var p: Dictionary = game.store.profile
	var row: Dictionary = game.catalog.find_row("heroes", hero)
	portrait()
	text(game._rarity("hero", hero) + " · " + row.title, 14, Recruitment.color("hero", hero, game.catalog, p))
	stats_line(p)
	text(row.passive, 13)
	button("Đang ra trận" if p.hero == hero else "Chọn ra trận", game._hero.bind(hero), locked() or p.hero == hero)
	if p.hero == hero:
		button("ĐIỂM THUỘC TÍNH →", game._select_tab.bind(9))
		button("Kỹ năng →", game._character_section.bind(5))
		button("Cây kỹ năng tinh linh →", game._select_tab.bind(13))

func equipment() -> void:
	var p: Dictionary = game.store.profile
	text("Trang bị riêng cho " + game.catalog.find_row("heroes", hero).name, 14)
	for slot in ["weapon", "armor"]:
		var uid: String = p.heroes[hero].equipment[slot]
		var current: Dictionary = {}
		for item in p.items:
			if item.uid == uid: current = item
		text("VŨ KHÍ" if slot == "weapon" else "GIÁP", 14, Color("e5cd9e"))
		if current.is_empty(): text("Chưa trang bị", 13)
		else:
			text(game.catalog.find_row("items", current.base).name + " +%d" % current.enhance, 14)
			button("Tháo trang bị", game._character_unequip.bind(uid, hero), locked())
	text("Có thể trang bị", 15, Color("a2e5d6"))
	var found := false
	for item in p.items:
		var row: Dictionary = game.catalog.find_row("items", item.base)
		if row.slot == "weapon" and row.category != game.catalog.category(hero): continue
		if item.uid in p.heroes[hero].equipment.values(): continue
		found = true
		button(row.name + " +%d · Mặc" % item.enhance, game._character_equip.bind(item.uid, hero), locked())
	if not found: text("Không có món phù hợp khác. Xem thêm trong Túi đồ.", 13)
	text("Mỗi món chỉ có một bản; các nhân vật có thể dùng chung trong cấu hình riêng.", 12)
	button("Mở kho trang bị →", game._bag_open.bind("equipment"))

func levels() -> void:
	var p: Dictionary = game.store.profile
	var level: int = p.heroes[hero].level
	portrait()
	if level >= 100:
		text("Đã đạt LV tối đa 100", 16, Color("e5cd9e"))
		stats_line(p)
		return
	var next: Dictionary = p.duplicate(true)
	next.heroes[hero].level += 1
	preview(next)
	text("Mỗi LV nhận thêm 2 điểm thuộc tính.", 13)
	text("Vàng %d / %d\nXP %d / %d" % [p.gold, level * 30, p.xp, level * 15])
	button("Tăng 1 LV", game._character_level.bind(hero, 1), locked() or p.gold < level * 30 or p.xp < level * 15)
	var count := mini(5, 100 - level)
	var total: int = count * level + count * (count - 1) / 2
	text("Tăng %d LV: %d vàng + %d XP" % [count, total * 30, total * 15], 13)
	button("Tăng %d LV" % count, game._character_level.bind(hero, count), locked() or p.gold < total * 30 or p.xp < total * 15)

func stars_panel() -> void:
	var p: Dictionary = game.store.profile
	var r := Recruitment.state(p)
	var stars: int = r.awakening[hero]
	portrait()
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
	portrait()
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
	var p: Dictionary = game.store.profile
	var unit: Dictionary = p.heroes[hero]
	var build: Dictionary = p.expansion.builds[hero]
	text("CÂY KỸ NĂNG", 16, Color("a2e5d6"))
	text("Mỗi kỹ năng chọn một nhánh. Học một lần; đổi hoặc bỏ chọn miễn phí ngoài trận.", 13)
	for i in range(2):
		text("◆ %s · LV %d/10" % [game.catalog.data.skills[i].name, unit.skills[i]], 16, Color("e5cd9e"))
		button("Nâng kỹ năng · %d vàng" % (unit.skills[i] * 25), game._character_skill_level.bind(hero, i), locked() or unit.skills[i] >= 10 or p.gold < unit.skills[i] * 25)
		for row in game.catalog.data.talents:
			if row.slot != i: continue
			text("└ " + row.name + " · " + row.description, 13)
			var learned: bool = row.id in build.learned
			var chosen: bool = build.selected[i] == row.id
			if not learned: text("Cần LV%d · %d vàng + %d tinh thạch" % [row.level, row.gold, row.shards], 12)
			button(("✓ Bỏ chọn · " if chosen else ("Chọn · " if learned else "Học · ")) + row.name, game._character_talent.bind(hero, row.id), locked() or unit.level < row.level or (not learned and (p.gold < row.gold or p.shards < row.shards)))
	button("Cây kỹ năng tinh linh →", game._select_tab.bind(13))

func outfits() -> void:
	var p: Dictionary = game.store.profile
	var current := Wardrobe.selected(p, hero)
	var preview_id: String = game.character_outfit_preview if game.character_outfit_preview in Wardrobe.LOOKS else current
	portrait()
	text("TRANG PHỤC", 16, Color("e5cd9e"))
	text("Bản hiện tại có trang phục gốc và các phối màu. Miễn phí, không đổi chỉ số. Đây chưa phải quần áo có thiết kế mới.", 13)
	text("Đang dùng: " + Wardrobe.LOOKS[current].name, 13)
	for id in Wardrobe.LOOKS:
		button(("● " if preview_id == id else "") + Wardrobe.LOOKS[id].name, game._preview_character_outfit.bind(id))
	button("Đang sử dụng" if current == preview_id else "Áp dụng phối màu", game._apply_character_outfit.bind(hero, preview_id), locked() or current == preview_id)

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
