class_name EquipmentDetailScreen
extends VBoxContainer

var game
var item: Dictionary
var definition: Dictionary
var content: VBoxContainer
var target := ""

func label(parent: Node, value: String, font_size: int = 15, tint: Color = Color("dce1d8")) -> Label:
	var node := Label.new()
	node.text = value
	node.add_theme_font_size_override("font_size", font_size)
	node.modulate = tint
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(node)
	return node

func stat_row(title: String, value: String) -> void:
	var row := HBoxContainer.new()
	content.add_child(row)
	label(row, title, 15, Color("a9bcb6"))
	var amount := label(row, value, 16, Color("f4e6c7"))
	amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _ready() -> void:
	target = game.equipment_target if not game.equipment_target.is_empty() else game.store.profile.hero
	custom_minimum_size = Vector2(492, 720)
	add_theme_constant_override("separation", 10)
	game._button(self, "← Kho trang bị", Vector2.ZERO, Vector2(492, 40), game._bag_open.bind("equipment"))
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	add_child(header)
	EquipmentArt.add_to(header, game, definition.id, definition.rarity, 126)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_child(words)
	label(words, game._rarity("item", definition.id).to_upper(), 14, Recruitment.color("item", definition.id, game.catalog))
	label(words, definition.name + " +%d" % item.enhance, 23)
	var role: String = {"sword": "Kiếm sĩ", "spear": "Thương thủ", "staff": "Pháp sư", "all": "Mọi nhân vật"}[definition.category]
	label(words, EquipmentSystem.SLOT_NAMES[definition.slot] + " · " + role, 13, Color("a9bcb6"))
	var owners: Array[String] = []
	for hero in game.catalog.data.heroes:
		if item.uid in game.store.profile.heroes[hero.id].equipment.values(): owners.append(hero.name)
	label(words, "Đang trang bị: " + ", ".join(owners) if not owners.is_empty() else "Chưa trang bị", 12, Color("cbb88b"))
	var scroll := SwipeScroll.new()
	scroll.name = "EquipmentDetailScroll"
	scroll.custom_minimum_size = Vector2(492, 408)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)
	content.add_child(HSeparator.new())
	var multiplier := EquipmentSystem.multiplier(item)
	for key in ["atk", "hp", "defense"]:
		if definition[key] > 0: stat_row({"atk":"Tấn công", "hp":"HP", "defense":"Phòng thủ"}[key], "+%d" % (definition[key] * multiplier))
	if definition.get("haste", 0) > 0: stat_row("Tốc độ đánh", "+%.0f%%" % (definition.haste * 100))
	for key in definition.secondary:
		var value: float = definition.secondary[key]
		if value == 0: continue
		stat_row({"crit":"Tỷ lệ chí mạng", "dodge":"Né tránh", "sp_regen":"Hồi năng lượng", "damage_reduction":"Giảm sát thương"}[key], "+%.2f SP/s" % value if key == "sp_regen" else "+%.0f%%" % (value * 100))
	stat_row("Cường hóa", "+%d / +15" % item.enhance)
	stat_row("Tiến bậc", "%d / 3" % item.rank)
	if not definition.effect.is_empty():
		label(content, "✦ Hiệu ứng · " + {"radiance":"Ánh sáng bảo hộ", "burn":"Hỏa vũ thiêu đốt", "tide":"Nguồn thủy triều", "aegis":"Thiên dực bảo hộ"}[definition.effect], 17, Color("e4bd6d"))
		label(content, definition.effect_description, 14, Color("b9c9c4"))
	elif game.catalog.data.traits.has(definition.id):
		label(content, "Đặc tính vũ khí", 16, Color("bda4df"))
		label(content, definition.passive, 14, Color("b9c9c4"))
	if not definition.set_id.is_empty(): add_set()
	stat_row("Mảnh " + definition.name, str(game.store.profile.collection_fragments.items[definition.id]))
	var locked: bool = game._locked()
	game._button(content, "Tiến bậc · %d vàng + %d tinh thạch" % [item.rank * 80, item.rank * 4], Vector2.ZERO, Vector2(460, 42), game._enhance.bind(item.uid, true)).disabled = locked or item.rank >= 3 or game.store.profile.gold < item.rank * 80 or game.store.profile.shards < item.rank * 4
	game._button(content, "Phân giải · +%d tinh thạch" % (1 + item.rank), Vector2.ZERO, Vector2(460, 42), game._dismantle_confirm.bind(item.uid)).disabled = locked or not owners.is_empty()
	var cost := (int(item.enhance) + 1) * 20
	var stone: Button = game._button(content,"Dùng1 Đá Rèn Sáng +%d vàng · Còn%d" % [cost,Supplies.count(game.store.profile,"forge_stone")],Vector2.ZERO,Vector2(460,44),game._supply_confirm.bind("stone",item.uid,0))
	stone.disabled = locked or item.enhance>=15 or game.store.profile.gold<cost or Supplies.count(game.store.profile,"forge_stone")<1
	stone.icon = Supplies.icon("forge_stone")
	stone.expand_icon = true
	stone.add_theme_constant_override("icon_max_width",30)
	label(self, "Đã đạt cường hóa tối đa" if item.enhance >= 15 else "Nâng tiếp: %d vàng  ·  1 tinh thạch" % cost, 14, Color("e2c58f"))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	add_child(actions)
	var active: String = target
	var equipped: bool = item.uid in game.store.profile.heroes[active].equipment.values()
	var equip_button: Button = game._button(actions, "Tháo về túi" if equipped else "Trang bị", Vector2.ZERO, Vector2(154, 48), game._character_unequip.bind(item.uid, active) if equipped else game._character_equip.bind(item.uid, active))
	equip_button.disabled = locked or (definition.slot == "weapon" and definition.category != game.catalog.category(active))
	var upgrade: Button = game._button(actions, "Cường hóa +%d" % mini(15, item.enhance + 1), Vector2.ZERO, Vector2(330, 48), game._enhance.bind(item.uid, false))
	upgrade.add_theme_stylebox_override("normal", game._style(Color("70562e"), Color("d8b45d"), 12))
	upgrade.disabled = locked or item.enhance >= 15 or game.store.profile.gold < cost or game.store.profile.shards < 1

func add_set() -> void:
	var set_def: Dictionary = game.catalog.find_row("sets", definition.set_id)
	var count: int = EquipmentSystem.set_counts(game.catalog, game.store.profile, target).get(set_def.id, 0)
	var heading := HBoxContainer.new()
	content.add_child(heading)
	var emblem := TextureRect.new()
	emblem.texture = game.icons.textures[set_def.icon]
	emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	emblem.custom_minimum_size = Vector2(38, 38)
	heading.add_child(emblem)
	label(heading, "BỘ " + set_def.name.to_upper() + " · %d/4" % count, 17, Color("d9c78e"))
	for bonus in set_def.bonuses:
		label(content, ("✓ " if count >= bonus.pieces else "○ ") + "%d món · %s" % [bonus.pieces, bonus.description], 14, Color("88d1b4") if count >= bonus.pieces else Color("83918f"))
	var members: Array[String] = []
	for def in game.catalog.data.items:
		if def.set_id == set_def.id: members.append(def.name)
	label(content, "Món cùng bộ: " + ", ".join(members), 12, Color("9aaea9"))
