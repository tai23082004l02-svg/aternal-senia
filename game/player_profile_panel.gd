class_name PlayerProfilePanel
extends RefCounted

static func layout(column: VBoxContainer) -> void:
	var box: PanelContainer = column.get_parent().get_parent()
	box.position.y = 135
	box.set_deferred("size", Vector2(472, 690))

static func show_profile(game) -> void:
	var identity := PlayerIdentity.state(game.store.profile)
	var column: VBoxContainer = game._dialog("HỒ SƠ", "Avatar và tên hiển thị của bạn", [])
	layout(column)
	var avatar := RoundAvatar.new()
	avatar.custom_minimum_size = Vector2(76, 76)
	avatar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(avatar)
	avatar.update_avatar(game.frames, identity.avatar)
	var name_input := LineEdit.new()
	name_input.name = "PlayerNameInput"
	name_input.text = identity.name
	name_input.max_length = 20
	name_input.placeholder_text = "Tên người chơi (1–20 ký tự)"
	name_input.custom_minimum_size.y = 44
	name_input.editable = not game.store.read_only
	column.add_child(name_input)
	var chosen := {"avatar": identity.avatar}
	var choices := GridContainer.new()
	choices.columns = 2
	choices.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(choices)
	var group := ButtonGroup.new()
	for hero in game.catalog.data.heroes:
		var id: String = hero.id
		var button: Button = game._button(choices, hero.name, Vector2.ZERO, Vector2(125, 46), func():
			chosen.avatar = id
			avatar.update_avatar(game.frames, id))
		button.toggle_mode = true
		button.button_group = group
		button.button_pressed = id == identity.avatar
		button.disabled = game.store.read_only or not game.store.available_hero(id)
		button.tooltip_text = "Chọn avatar" if not button.disabled else "Cần sở hữu nhân vật"
	var notice: Label = game._label(column, "VIP · Chưa kích hoạt", Vector2.ZERO, 18, Color("e5cd9e"))
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game._button(column, "Lưu hồ sơ", Vector2.ZERO, Vector2(400, 46), func():
		if PlayerIdentity.save(game.store, name_input.text, chosen.avatar):
			game._refresh_hud()
			game._close_modal()
		else:
			notice.text = game.store.error).disabled = game.store.read_only
	game._button(column, "Xem VIP 1–10  →", Vector2.ZERO, Vector2(400, 46), game._show_vip.bind(1))
	game._button(column, "Đóng", Vector2.ZERO, Vector2(400, 46), game._close_modal)

static func show_vip(game, tier: int) -> void:
	tier = clampi(tier, 1, PlayerIdentity.VIP_TIERS)
	var column: VBoxContainer = game._dialog("ĐẶC QUYỀN VIP", "VIP hiện tại · Chưa kích hoạt", [])
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
	body.text = "Tích lũy VIP qua nạp tiền.\n\nMốc nạp và quyền lợi của bậc này sẽ được công bố khi cửa hàng nạp mở.\n\nHiện chưa hỗ trợ thanh toán."
	column.add_child(body)
	var topup: Button = game._button(column, "Nạp tiền · Sắp ra mắt", Vector2.ZERO, Vector2(400, 46), func(): pass)
	topup.disabled = true
	game._button(column, "Về hồ sơ", Vector2.ZERO, Vector2(400, 46), game._show_player_profile)
	game._button(column, "Đóng", Vector2.ZERO, Vector2(400, 46), game._close_modal)

class RoundAvatar extends Control:
	var face: Control
	var current := ""
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
		draw_circle(size * .5, minf(size.x, size.y) * .5, Color("cfb373"))
