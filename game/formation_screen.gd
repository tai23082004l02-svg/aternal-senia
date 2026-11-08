class_name FormationScreen
extends VBoxContainer
var game
var slot := 0
var slot_buttons: Array[Button] = []
var roster_buttons: Dictionary = {}
var spirit_button: Button
var roster_scroll: SwipeScroll
var roster_canvas: Control
var card_pool: Array[Button] = []
var first_row := -1
var saved_roster_offset := 0
var restoring_roster := true
const CARD_WIDTH := 148
const CARD_HEIGHT := 144
const ROW_HEIGHT := 152
const ROSTER_HEIGHT := 178
const GOLD := Color("d9b86a")
const IVORY := Color("f8f3e3")

func _ready() -> void:
	saved_roster_offset = game.formation_roster_offset
	custom_minimum_size.x = 492
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	add_theme_constant_override("separation", 6)
	var p: Dictionary = game.store.profile
	var f := Formation.state(p, game.catalog)
	var filled: int = f.slots.filter(func(id): return not id.is_empty()).size()
	var header := HBoxContainer.new()
	add_child(header)
	var title := label(header, "✧ ĐỘI HÌNH", 25, GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label(header, "%d/3 tướng · 1 tinh linh" % filled, 13)
	var stage := FormationStage.new()
	stage.texture = game.frames.textures["bg_" + game.catalog.find_row("stages", game.selected_stage).zone]
	stage.custom_minimum_size = Vector2(492, 240)
	add_child(stage)
	for i in range(3):
		var button := slot_card(stage, i, f.slots[i])
		button.position = [Vector2(166,14), Vector2(8,110), Vector2(324,110)][i]
		slot_buttons.append(button)
	spirit_button = game._button(self, "Tinh linh: " + game.catalog.find_row("assists", p.assist).name + "  ›", Vector2.ZERO, Vector2(492, 46), game._formation_spirits)
	style_button(spirit_button, false)
	spirit_button.icon = game.frames.textures["companion_" + p.assist]
	spirit_button.expand_icon = true
	spirit_button.add_theme_constant_override("icon_max_width", 44)
	spirit_button.tooltip_text = "Chọn tinh linh hỗ trợ · Không chiếm ô tướng"
	var roster_header := HBoxContainer.new()
	add_child(roster_header)
	var heading := label(roster_header, "Danh sách nhân vật", 18, GOLD)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var owned := 0
	for hero in game.catalog.data.heroes:
		if game.store.available_hero(hero.id): owned += 1
	label(roster_header, "Sở hữu %d/%d" % [owned, game.catalog.data.heroes.size()], 13)
	roster_scroll = SwipeScroll.new()
	roster_scroll.name = "FormationRosterScroll"
	roster_scroll.custom_minimum_size = Vector2(492, ROSTER_HEIGHT)
	roster_scroll.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	roster_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	roster_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	add_child(roster_scroll)
	roster_canvas = Control.new()
	roster_canvas.custom_minimum_size = Vector2(460, maxi(0, ceili(game.catalog.data.heroes.size() / 3.0) * ROW_HEIGHT - 8))
	roster_scroll.add_child(roster_canvas)
	# Only visible rows plus one row on either side have live controls.
	for i in range(mini(game.catalog.data.heroes.size(), (ceili(float(ROSTER_HEIGHT) / ROW_HEIGHT) + 2) * 3)):
		var card := Button.new()
		card.size = Vector2(CARD_WIDTH, CARD_HEIGHT)
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.pressed.connect(_card_pressed.bind(card))
		roster_canvas.add_child(card)
		card_pool.append(card)
	roster_scroll.get_v_scroll_bar().value_changed.connect(_roster_moved)
	_update_roster()
	_restore_roster.call_deferred()
	var actions := HBoxContainer.new()
	add_child(actions)
	var hint := label(actions, "Chọn vị trí → chọn tướng · Không khóa nghề", 12)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var remove: Button = game._button(actions, "Bỏ khỏi ô", Vector2.ZERO, Vector2(108, 30), game._formation_assign.bind(slot, ""))
	remove.add_theme_font_size_override("font_size", 12)
	remove.disabled = game._locked() or f.slots[slot].is_empty() or filled <= 1
	for key in ["auto_ult", "auto_next"]:
		var check := CheckButton.new()
		check.name = key
		check.text = "Tự dùng Ultimate" if key == "auto_ult" else "Tự vượt ải · Dừng trước Boss chương"
		check.add_theme_font_size_override("font_size", 14)
		check.add_theme_stylebox_override("normal", game._style(Color("12343e"), Color("617f80"), 14))
		check.custom_minimum_size.y = 34
		check.button_pressed = f[key]
		check.disabled = game._locked()
		check.toggled.connect(game._formation_option.bind(key))
		add_child(check)
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 8)
	add_child(navigation)
	for entry in [["Nâng cấp", 1], ["Hành trình  ›", 0]]:
		var button: Button = game._button(navigation, entry[0], Vector2.ZERO, Vector2(242, 46), game._select_tab.bind(entry[1]))
		style_button(button, entry[1] == 0)

func _restore_roster() -> void:
	roster_scroll.scroll_vertical = saved_roster_offset
	restoring_roster = false
	game.formation_roster_offset = roster_scroll.scroll_vertical
	_update_roster()

func _roster_moved(value: float) -> void:
	if not restoring_roster: game.formation_roster_offset = int(value)
	_update_roster()

func _update_roster() -> void:
	var row := maxi(0, int(roster_scroll.scroll_vertical / ROW_HEIGHT) - 1)
	if row == first_row: return
	first_row = row
	roster_buttons.clear()
	for i in range(card_pool.size()):
		var index := row * 3 + i
		var button := card_pool[i]
		button.visible = index < game.catalog.data.heroes.size()
		if not button.visible: continue
		var hero: Dictionary = game.catalog.data.heroes[index]
		button.position = Vector2((index % 3) * (CARD_WIDTH + 8), int(index / 3) * ROW_HEIGHT)
		_bind_card(button, hero)
		roster_buttons[hero.id] = button

func _card_pressed(button: Button) -> void:
	if not button.disabled: game._on_button(game._formation_assign.bind(slot, str(button.get_meta("hero_id"))))

func _bind_card(button: Button, hero: Dictionary) -> void:
	for child in button.get_children():
		button.remove_child(child)
		child.queue_free()
	var id: String = hero.id
	button.set_meta("hero_id", id)
	var available: bool = game.store.available_hero(id)
	var f := Formation.state(game.store.profile, game.catalog)
	var deployed: bool = id in f.slots
	var selected: bool = id == f.slots[slot]
	var frame: StyleBoxFlat = game._style(Color("1d4650") if selected else Color("102c38"), GOLD if selected or deployed else Color("61747c"), 12)
	frame.set_border_width_all(2 if selected else 1)
	if selected:
		frame.shadow_color = Color(.85,.65,.3,.3)
		frame.shadow_size = 3
	button.add_theme_stylebox_override("normal", frame)
	button.add_theme_stylebox_override("disabled", frame)
	button.add_theme_stylebox_override("hover", game._style(Color("23515c"), IVORY, 12))
	button.add_theme_stylebox_override("focus", game._style(Color(0,0,0,0), IVORY, 12))
	button.disabled = not available or game._locked()
	button.tooltip_text = "Đưa vào vị trí đang chọn; tự hoán đổi nếu đã trong đội" if available else "Chưa sở hữu nhân vật"
	var face := Portrait.new()
	face.frames = game.frames
	face.hero = id
	face.dimmed = not available
	var banner_path: String = hero.get("formation_portrait", "res://art/banners/" + id + ".png")
	if ResourceLoader.exists(banner_path):
		var cache_key := "formation_portrait_" + id
		if not game.frames.textures.has(cache_key): game.frames.textures[cache_key] = load(banner_path)
		face.banner = game.frames.textures[cache_key]
	face.position = Vector2(31, 5)
	face.size = Vector2(86, 80)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(face)
	var name_text := label(button, hero.name, 15, GOLD)
	name_text.position = Vector2(4,85)
	name_text.size = Vector2(140,21)
	name_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var level: int = game.store.profile.heroes.get(id, {}).get("level", 1)
	var status := label(button, ("LV%d · Sở hữu" % level) if available else "LV— · Chưa sở hữu", 11)
	status.position = Vector2(4,106)
	status.size = Vector2(140,16)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var state := label(button, "Đang ra trận" if deployed else ("Sẵn sàng" if available else "Khóa"), 11, Color("a8e0bc") if deployed else Color("9fb7bf"))
	state.position = Vector2(4,123)
	state.size = Vector2(140,17)
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if deployed:
		var mark := label(button, "✓", 18, IVORY)
		mark.position = Vector2(112,3)
		mark.add_theme_stylebox_override("normal", game._style(Color("246747"), GOLD, 12))

func slot_card(parent: Control, index: int, id: String) -> Button:
	var button := Button.new()
	button.size = Vector2(160, 124)
	button.flat = true
	button.mouse_filter = Control.MOUSE_FILTER_PASS
	button.pressed.connect(game._on_button.bind(game._formation_slot.bind(index)))
	button.tooltip_text = ["Hàng trước", "Hàng sau trái", "Hàng sau phải"][index] + " · Chọn để thay nhân vật"
	parent.add_child(button)
	var actor := SlotActor.new()
	actor.game = game
	actor.hero = id
	actor.selected = index == slot
	actor.size = button.size
	actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(actor)
	var row: Dictionary = game.catalog.find_row("heroes", id)
	var level: int = game.store.profile.heroes.get(id, {}).get("level", 1)
	var title := label(button, "%s · LV%d" % [row.get("name", "Ô trống"), level] if not id.is_empty() else "＋ Chọn tướng", 13, IVORY)
	title.position = Vector2(0,88)
	title.size = Vector2(160,20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_stylebox_override("normal", game._style(Color("0b2934"), GOLD if index == slot else Color("608d95"), 10))
	var rank := label(button, "HÀNG TRƯỚC" if index == 0 else "HÀNG SAU", 10, GOLD)
	rank.position = Vector2(0,116)
	rank.size.x = 160
	rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return button

func style_button(button: Button, primary: bool) -> void:
	button.add_theme_stylebox_override("normal", game._style(Color("bb8940") if primary else Color("154e58"), GOLD, 14))
	button.add_theme_stylebox_override("hover", game._style(Color("d3a655") if primary else Color("236773"), IVORY, 14))
	button.add_theme_font_size_override("font_size", 18)

func label(parent: Node, value: String, font_size: int, color: Color = Color("afc2bb")) -> Label:
	var item := Label.new()
	item.text = tr(value)
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item

class Portrait extends Control:
	var frames: FrameLibrary
	var hero: String
	var dimmed: bool
	var banner: Texture2D
	func _draw() -> void:
		var tint := Color(.35,.4,.45) if dimmed else Color.WHITE
		var spec: Dictionary = frames.painted.get("portraits", {}).get(hero, {})
		if not spec.is_empty():
			var region: Array = spec.face
			draw_texture_rect_region(frames.textures["portrait_" + hero], Rect2(Vector2.ZERO, size), Rect2(region[0],region[1],region[2],region[3]), tint)
		elif banner != null:
			var dimensions := banner.get_size()
			draw_texture_rect_region(banner, Rect2(Vector2.ZERO,size), Rect2(dimensions.x*.28,0,dimensions.y*.65,dimensions.y*.65),tint)
		elif frames.manifest.heroes.has(hero):
			var frame := frames.frame_at(hero, "idle", 0)
			draw_texture_rect(frames.textures[frame.file], Rect2(Vector2.ZERO, size), false, tint)
		else:
			draw_circle(size / 2, 26, Color("426471"))

class FormationStage extends Control:
	var texture: Texture2D
	func _ready() -> void: mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		draw_texture_rect(texture, Rect2(Vector2.ZERO,size), false)
		draw_line(Vector2(246,80),Vector2(88,182),Color(.3,.7,.8,.4),1,true)
		draw_line(Vector2(246,80),Vector2(404,182),Color(.3,.7,.8,.4),1,true)

class SlotActor extends Control:
	var game
	var hero: String
	var selected: bool
	var elapsed := 0.0
	func _process(delta: float) -> void:
		elapsed += delta
		queue_redraw()
	func _draw() -> void:
		var color := Color("f5d17b") if selected else Color("76cde5")
		var ring := PackedVector2Array()
		for i in range(65):
			var angle := TAU * i / 64
			ring.append(Vector2(80 + cos(angle)*66, 80 + sin(angle)*10))
		draw_polyline(ring, color, 2, true)
		if not hero.is_empty():
			var stats: Dictionary = game.catalog.stats(game.store.profile, hero)
			var look: Array = stats.get("look_tint",[1,1,1,1])
			game.frames.draw_actor(self, game.frames.frame_at(hero,"idle",elapsed),Vector2(80,81),stats.weapon,Color(look[0],look[1],look[2],look[3]),true,.29)
