class_name PlayerProfilePanel
extends RefCounted

static func layout(column: VBoxContainer) -> void:
	var box: PanelContainer = column.get_parent().get_parent()
	box.position.y = 135
	box.set_deferred("size", Vector2(472, 690))

const GOLD := Color("e7c77e")
const IVORY := Color("f8f0d9")

static func label(parent: Node, value: String, font_size: int, color: Color = IVORY) -> Label:
	var text := Label.new()
	text.text = TranslationServer.translate(value)
	text.add_theme_font_size_override("font_size", font_size)
	if font_size >= 18:
		var serif := SystemFont.new()
		serif.font_names = PackedStringArray(["Noto Serif", "Georgia", "serif"])
		text.add_theme_font_override("font", serif)
	text.add_theme_color_override("font_color", color)
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(text)
	return text

static func style_button(game, button: Button, primary := false) -> void:
	for state in ["normal", "hover", "pressed", "disabled"]:
		var fill := Color("b68536") if primary else Color("0b2935")
		if state == "hover": fill = fill.lightened(.13)
		if state == "pressed": fill = fill.darkened(.15)
		if state == "disabled": fill = Color("263538")
		button.add_theme_stylebox_override(state, game._style(fill, GOLD if state != "disabled" else Color("68716c"), 12))
	button.add_theme_color_override("font_color", IVORY)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 19)

static func show_profile(game) -> void:
	var identity := PlayerIdentity.state(game.store.profile)
	game._close_modal()
	game.modal = Control.new()
	game.modal.size = Vector2(540, 960)
	game.ui.add_child(game.modal)
	var shade := ColorRect.new()
	shade.color = Color(.015, .035, .055, .75)
	shade.size = game.modal.size
	game.modal.add_child(shade)
	var box := Panel.new()
	box.position = Vector2(28, 112)
	box.size = Vector2(484, 744)
	box.add_theme_stylebox_override("panel", game._style(Color("071f2b"), GOLD, 28))
	game.modal.add_child(box)
	var trim := ProfileTrim.new()
	trim.size = box.size
	trim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(trim)
	var heading := label(box, "✧  HỒ SƠ LỮ HÀNH", 24, GOLD)
	heading.position = Vector2(30, 17)
	var close: Button = game._button(box, "×", Vector2(426, 12), Vector2(40, 40), game._close_modal)
	close.name = "ProfileClose"
	style_button(game, close)
	var scroll := SwipeScroll.new()
	scroll.position = Vector2(18, 63)
	scroll.size = Vector2(448, 597)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 7)
	scroll.add_child(column)
	var scene := Control.new()
	scene.custom_minimum_size.y = 157
	column.add_child(scene)
	var background := TextureRect.new()
	background.texture = game.frames.textures["bg_forest"]
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(.65, .8, .8, .8)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var avatar := RoundAvatar.new()
	avatar.name = "ProfilePortrait"
	avatar.background = Color("123643")
	avatar.position = Vector2(154, 6)
	avatar.size = Vector2(140, 140)
	scene.add_child(avatar)
	avatar.update_avatar(game.frames, identity.avatar)
	var crest := ProfileTrim.new()
	crest.portrait = true
	crest.position = Vector2(148, 0)
	crest.size = Vector2(152, 152)
	crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene.add_child(crest)
	var display_name := label(column, identity.name, 27)
	display_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	display_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var subtitle := label(column, "Danh tính trong thế giới Aternal Senia", 14, Color("a9c1c2"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label(column, "✧  Tên hiển thị", 18, GOLD)
	var name_input := LineEdit.new()
	name_input.name = "PlayerNameInput"
	name_input.text = identity.name
	name_input.max_length = 20
	name_input.placeholder_text = TranslationServer.translate("Tên người chơi (1–20 ký tự)")
	name_input.custom_minimum_size.y = 40
	name_input.editable = not game.store.read_only
	name_input.add_theme_font_size_override("font_size", 20)
	name_input.add_theme_stylebox_override("normal", game._style(Color("061a24"), GOLD, 10))
	column.add_child(name_input)
	label(column, "Tối đa 20 ký tự", 12, Color("a9c1c2"))
	var owned := 0
	for hero in game.catalog.data.heroes:
		if game.store.available_hero(hero.id): owned += 1
	label(column, "✧  Chọn ảnh đại diện                 %s %d/%d" % [TranslationServer.translate("Sở hữu"), owned, game.catalog.data.heroes.size()], 17, GOLD)
	var chosen := {"avatar": identity.avatar}
	var choices := HBoxContainer.new()
	choices.add_theme_constant_override("separation", 8)
	column.add_child(choices)
	var group := ButtonGroup.new()
	for hero in game.catalog.data.heroes:
		var id: String = hero.id
		var button: Button = game._button(choices, "", Vector2.ZERO, Vector2(0, 112), func():
			chosen.avatar = id
			avatar.update_avatar(game.frames, id))
		button.name = "ProfileAvatar_" + id
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.button_group = group
		button.button_pressed = id == identity.avatar
		button.disabled = game.store.read_only or not game.store.available_hero(id)
		button.tooltip_text = TranslationServer.translate("Chọn avatar" if not button.disabled else "Cần sở hữu nhân vật")
		style_button(game, button)
		var selected: StyleBoxFlat = game._style(Color("164b53"), Color("ffe5a1"), 12)
		selected.set_border_width_all(3)
		selected.shadow_color = Color(1, .72, .23, .25)
		selected.shadow_size = 4
		button.add_theme_stylebox_override("pressed", selected)
		var face := CharacterScreen.Face.new()
		face.frames = game.frames
		face.hero = id
		face.dimmed = not game.store.available_hero(id)
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(face)
		face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		face.offset_left = 5
		face.offset_top = 5
		face.offset_right = -5
		face.offset_bottom = -27
		var caption := label(button, hero.name, 17, GOLD)
		caption.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		caption.offset_top = -27
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if not game.store.available_hero(id):
			var locked := LockBadge.new()
			locked.position = Vector2(35, 34)
			locked.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(locked)
	var vip := PanelContainer.new()
	vip.add_theme_stylebox_override("panel", game._style(Color("10343f"), GOLD, 15))
	column.add_child(vip)
	var vip_column := VBoxContainer.new()
	vip_column.add_theme_constant_override("separation", 2)
	vip.add_child(vip_column)
	label(vip_column, "♛  Đặc quyền VIP       ·  Chưa kích hoạt", 18, GOLD)
	var notice := label(vip_column, "VIP EXP tích lũy                         %d" % MissionBoard.state(game.store.profile).vip_exp, 16)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var vip_button: Button = game._button(vip_column, "Xem VIP 1–10                         ›", Vector2.ZERO, Vector2(0, 34), game._show_vip.bind(1))
	style_button(game, vip_button)
	var save: Button = game._button(box, "✧   LƯU HỒ SƠ   ✧", Vector2(36, 678), Vector2(412, 48), func():
		if PlayerIdentity.save(game.store, name_input.text, chosen.avatar):
			game._refresh_hud()
			game._close_modal()
		else:
			notice.text = game.store.error)
	save.name = "ProfileSave"
	save.disabled = game.store.read_only
	style_button(game, save, true)

class LockBadge extends Control:
	func _draw() -> void:
		draw_arc(Vector2(10, 7), 7, PI, TAU, 24, GOLD, 3, true)
		draw_style_box(_body(), Rect2(0, 7, 20, 18))
		draw_circle(Vector2(10, 14), 2, Color("1b3037"))
		draw_line(Vector2(10, 14), Vector2(10, 20), Color("1b3037"), 2)
	func _body() -> StyleBoxFlat:
		var body := StyleBoxFlat.new()
		body.bg_color = GOLD
		body.set_corner_radius_all(3)
		return body

class ProfileTrim extends Control:
	var portrait := false
	func diamond(center: Vector2, radius: float) -> void:
		var points := PackedVector2Array([center + Vector2(0,-radius), center + Vector2(radius*.6,0), center + Vector2(0,radius), center - Vector2(radius*.6,0), center + Vector2(0,-radius)])
		draw_polyline(points, GOLD, 1.5, true)
	func _draw() -> void:
		if portrait:
			var center := size*.5
			for radius in [size.x*.48, size.x*.5]: draw_arc(center,radius,0,TAU,96,GOLD,1.5,true)
			diamond(Vector2(center.x, 4), 10)
			diamond(Vector2(center.x, size.y-4), 10)
			for side in [-1,1]:
				for i in range(5):
					var point := center + Vector2(side*(43+i*6), 62-i*9)
					draw_line(point, point+Vector2(side*9,-14), GOLD, 2, true)
			return
		var border := StyleBoxFlat.new()
		border.bg_color = Color.TRANSPARENT
		border.border_color = Color("8b845f")
		border.set_border_width_all(1)
		border.set_corner_radius_all(24)
		draw_style_box(border, Rect2(Vector2(5,5),size-Vector2(10,10)))
		for y in [58.0,size.y-77]:
			draw_line(Vector2(22,y),Vector2(size.x-22,y),Color("8b845f"),1,true)
		for y in [4.0,size.y-4]:
			diamond(Vector2(size.x*.5,y),9)
		for x in [14.0,size.x-14]:
			for y in [24.0,size.y-24]: diamond(Vector2(x,y),9)

static func show_vip(game, tier: int) -> void:
	tier = clampi(tier, 1, PlayerIdentity.VIP_TIERS)
	var column: VBoxContainer = game._dialog("ĐẶC QUYỀN VIP", "VIP EXP: %d · Chưa xếp hạng" % MissionBoard.state(game.store.profile).vip_exp, [])
	layout(column)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 8)
	column.add_child(grid)
	for level in range(1, PlayerIdentity.VIP_TIERS + 1):
		var button: Button = game._button(grid, "VIP %d" % level, Vector2.ZERO, Vector2(80, 48), game._show_vip.bind(level))
		button.name = "VipTier%d" % level
		button.add_theme_font_size_override("font_size", 14)
		if level == tier: button.modulate = Color("f6d48a")
	var title: Label = game._label(column, "VIP %d · Chưa mở" % tier, Vector2.ZERO, 24, Color("e5cd9e"))
	title.name = "VipTierTitle"
	var body := Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(400, 148)
	body.add_theme_font_size_override("font_size", 18)
	body.text = "Tích lũy VIP EXP qua nhiệm vụ ngày/tuần.\n\nMốc EXP và quyền lợi của bậc này đang chờ cấu hình.\n\nHiện chưa hỗ trợ thanh toán."
	column.add_child(body)
	var topup: Button = game._button(column, "Nạp tiền · Sắp ra mắt", Vector2.ZERO, Vector2(400, 46), func(): pass)
	topup.disabled = true
	game._button(column, "Về hồ sơ", Vector2.ZERO, Vector2(400, 46), game._show_player_profile)
	game._button(column, "Đóng", Vector2.ZERO, Vector2(400, 46), game._close_modal)

class RoundAvatar extends Control:
	var face: Control
	var current := ""
	var background := Color("cfb373")
	func _ready() -> void:
		clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func update_avatar(frames: FrameLibrary, hero: String) -> void:
		if current == hero and is_instance_valid(face): return
		current = hero
		if is_instance_valid(face):
			remove_child(face)
			face.queue_free()
		face = CharacterScreen.Face.new()
		face.frames = frames
		face.hero = hero
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(face)
		face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		queue_redraw()
	func _draw() -> void:
		draw_circle(size * .5, minf(size.x, size.y) * .5, background)
