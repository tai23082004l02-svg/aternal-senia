class_name FormationScreen
extends VBoxContainer
var game
var slot := 0
var slot_buttons: Array[Button] = []
var roster_buttons: Dictionary = {}
var spirit_button: Button

func _ready() -> void:
	custom_minimum_size.x = 492
	add_theme_constant_override("separation", 8)
	var p: Dictionary = game.store.profile
	var f := Formation.state(p, game.catalog)
	var filled: int = f.slots.filter(func(id): return not id.is_empty()).size()
	var header := HBoxContainer.new()
	add_child(header)
	var title := label(header, "ĐỘI HÌNH", 23, Color("e5cd9e"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label(header, "%d/3 tướng · 1 tinh linh" % filled, 13)
	center_label("HÀNG TRƯỚC")
	var front := HBoxContainer.new()
	front.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(front)
	slot_buttons.append(slot_card(front, 0, f.slots[0], 210))
	center_label("HÀNG SAU")
	var back := HBoxContainer.new()
	back.add_theme_constant_override("separation", 8)
	add_child(back)
	for i in [1, 2]: slot_buttons.append(slot_card(back, i, f.slots[i], 242))
	spirit_button = game._button(self, "Tinh linh: " + game.catalog.find_row("assists", p.assist).name + "  ›", Vector2.ZERO, Vector2(492, 42), game._formation_spirits)
	game.icons.apply(spirit_button, "spirit", 24)
	spirit_button.tooltip_text = "Chọn tinh linh hỗ trợ · Không chiếm ô tướng"
	var roster_header := HBoxContainer.new()
	add_child(roster_header)
	var heading := label(roster_header, "Danh sách nhân vật", 18, Color("e5cd9e"))
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var owned := 0
	for hero in game.catalog.data.heroes:
		if game.store.available_hero(hero.id): owned += 1
	label(roster_header, "Sở hữu %d/%d" % [owned, game.catalog.data.heroes.size()], 13)
	var roster := GridContainer.new()
	roster.columns = 4
	roster.add_theme_constant_override("h_separation", 8)
	roster.add_theme_constant_override("v_separation", 8)
	add_child(roster)
	for hero in game.catalog.data.heroes:
		var available: bool = game.store.available_hero(hero.id)
		var button := portrait_card(roster, hero.id, 117, 94, false, not available)
		button.pressed.connect(game._on_button.bind(game._formation_assign.bind(slot, hero.id)))
		button.disabled = not available or game._locked()
		button.tooltip_text = "Đưa vào vị trí đang chọn; tự hoán đổi nếu đã trong đội" if available else "Chưa sở hữu nhân vật"
		roster_buttons[hero.id] = button
	var actions := HBoxContainer.new()
	add_child(actions)
	var hint := label(actions, "Chọn ô rồi chọn tướng · Không khóa nghề", 12)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var remove: Button = game._button(actions, "Bỏ khỏi ô", Vector2.ZERO, Vector2(108, 32), game._formation_assign.bind(slot, ""))
	remove.add_theme_font_size_override("font_size", 12)
	remove.disabled = game._locked() or f.slots[slot].is_empty() or filled <= 1
	for key in ["auto_ult", "auto_next"]:
		var check := CheckButton.new()
		check.name = key
		check.text = "Tự dùng Ultimate" if key == "auto_ult" else "Tự vượt ải · Dừng trước Boss chương"
		check.add_theme_font_size_override("font_size", 14)
		check.custom_minimum_size.y = 32
		check.button_pressed = f[key]
		check.disabled = game._locked()
		check.toggled.connect(game._formation_option.bind(key))
		add_child(check)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 8)
	add_child(navigation)
	game._button(navigation, "Nâng cấp", Vector2.ZERO, Vector2(242, 44), game._select_tab.bind(1))
	game._button(navigation, "Hành trình", Vector2.ZERO, Vector2(242, 44), game._select_tab.bind(0))

func slot_card(parent: Control, index: int, id: String, width: int) -> Button:
	var button := portrait_card(parent, id, width, 96, index == slot, false)
	button.pressed.connect(game._on_button.bind(game._formation_slot.bind(index)))
	button.tooltip_text = ["Hàng trước", "Hàng sau trái", "Hàng sau phải"][index] + " · Chọn để thay nhân vật"
	return button

func portrait_card(parent: Control, id: String, width: int, height: int, selected: bool, dimmed: bool) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(width, height)
	button.add_theme_stylebox_override("normal", game._style(Color("2b4037") if selected else Color("142c38"), Color("d9bd7d") if selected else Color("42545c"), 12))
	parent.add_child(button)
	if not id.is_empty():
		var face := CharacterScreen.Face.new()
		face.frames = game.frames
		face.hero = id
		face.dimmed = dimmed
		face.position = Vector2((width - 45) * .5, 4)
		face.size = Vector2(45, 45)
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(face)
	var name_text: String = game.catalog.find_row("heroes", id).get("name", "Ô trống")
	var name_label := label(button, name_text, 15, Color("e5cd9e"))
	name_label.position = Vector2(0, 51)
	name_label.size = Vector2(width, 22)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var level := label(button, "Khóa" if dimmed else ("LV%d" % game.store.profile.heroes[id].level if not id.is_empty() else "Chọn nhân vật"), 12)
	level.position = Vector2(0, 75)
	level.size = Vector2(width, 18)
	level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return button

func center_label(value: String) -> void:
	var item := label(self, value, 12)
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func label(parent: Node, value: String, font_size: int, color: Color = Color("afc2bb")) -> Label:
	var item := Label.new()
	item.text = value
	item.add_theme_font_size_override("font_size", font_size)
	item.modulate = color
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item
